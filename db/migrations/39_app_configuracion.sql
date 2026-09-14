-- =============================================================================
-- 39_app_configuracion.sql · Configuración por tenant (cap. 17)
--
-- Lo CONFIGURABLE y lo NO configurable están explícitos en el cap. 17. Este
-- módulo sólo expone lo primero. En particular NO se puede configurar:
--   · la secuencia Solicitud -> OT -> Diagnóstico -> Cotización -> Trabajo -> Cierre
--   · los estados operativos principales de la OT
--   · el concepto de emergencia y su obligación de regularización
--   · la relación estructural entre la OT y sus registros de trazabilidad
--   · la conservación de auditoría, versionado y eliminación lógica
-- =============================================================================
SET search_path = app, core, internal, public;

-- Claves reconocidas. Cualquier otra se rechaza para que la configuración no se
-- convierta en un cajón de sastre sin contrato.
CREATE OR REPLACE FUNCTION internal.claves_configurables()
RETURNS TEXT[] LANGUAGE sql IMMUTABLE AS $$
  SELECT ARRAY[
    'limites_adjunto',            -- tamaños máximos por tipo y total por OT (cap. 28.3)
    'sla_primera_revision',       -- minutos por prioridad (cap. 34.2)
    'umbral_muestra_costos',      -- mínimo de casos para publicar un promedio (cap. 32.4)
    'exige_evidencia_cierre',     -- si el cierre requiere evidencias finales (cap. 14.3)
    'exige_conformidad',          -- si se pide conformidad del solicitante (cap. 14.2)
    'permite_derivada_no_bloqueante', -- si una hija puede no bloquear el cierre (cap. 10)
    'notificaciones_obligatorias',-- eventos que el usuario no puede desactivar (cap. 34.1)
    'zona_horaria',               -- se muestra todo en la zona del tenant (regla 23.1)
    'moneda_base',
    'titulo_min_caracteres',      -- validación de calidad de la solicitud (cap. 24.3)
    'titulo_max_caracteres'
  ];
$$;

CREATE OR REPLACE FUNCTION app.fn_configuracion_obtener(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN)
RETURNS JSONB LANGUAGE plpgsql STABLE
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_object_agg(clave, valor), '{}'::jsonb) INTO v
    FROM core.tenant_configuracion WHERE tenant_id = p_tenant_id;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'configuracion', v,
    'claves_disponibles', to_jsonb(internal.claves_configurables()),
    -- Se devuelve explícitamente para que la interfaz no ofrezca cambiar lo que
    -- el documento declara no configurable (cap. 17).
    'no_configurable', jsonb_build_array(
      'Secuencia base Solicitud -> OT -> Diagnóstico -> Cotización -> Trabajo -> Cierre',
      'Estados operativos principales de la OT',
      'Concepto de emergencia y su obligación de regularización',
      'Relación estructural entre la OT y sus registros de trazabilidad',
      'Conservación de auditoría, versionado y eliminación lógica')));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;

CREATE OR REPLACE FUNCTION app.sp_configuracion_guardar(
  p_user_id UUID, p_tenant_id UUID, p_is_super_admin BOOLEAN,
  p_clave TEXT, p_valor JSONB, p_descripcion TEXT DEFAULT NULL)
RETURNS JSONB LANGUAGE plpgsql
SECURITY DEFINER SET search_path = core, app, internal, public AS $$
DECLARE v_antes JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'configuracion:editar');

  IF NOT (p_clave = ANY (internal.claves_configurables())) THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION',
      format('"%s" no es una clave configurable. El cap. 17 delimita qué varía por cliente.', p_clave),
      'clave'));
  END IF;

  SELECT valor INTO v_antes FROM core.tenant_configuracion
   WHERE tenant_id = p_tenant_id AND clave = p_clave;

  INSERT INTO core.tenant_configuracion (tenant_id, clave, valor, descripcion, updated_by)
  VALUES (p_tenant_id, p_clave, p_valor, p_descripcion, p_user_id)
  ON CONFLICT (tenant_id, clave) DO UPDATE
    SET valor = EXCLUDED.valor, descripcion = coalesce(EXCLUDED.descripcion, core.tenant_configuracion.descripcion),
        updated_at = now(), updated_by = p_user_id;

  -- Cambio de configuración: valor anterior/nuevo, actor y fecha (cap. 18, 33).
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'configurar', 'tenant_configuracion',
    NULL, jsonb_build_object(p_clave, v_antes), jsonb_build_object(p_clave, p_valor));

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('clave', p_clave, 'valor', p_valor));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;
