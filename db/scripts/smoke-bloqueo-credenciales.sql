\set ON_ERROR_STOP on
DO $$
DECLARE r JSONB; i INT; v_email TEXT := 'bloqueo.prueba@mip.local'; v_tenant UUID;
BEGIN
  SELECT id INTO v_tenant FROM core.tenant LIMIT 1;
  DELETE FROM audit.audit_log WHERE entidad_id IN (SELECT id FROM core.usuario WHERE email=v_email);
  DELETE FROM core.usuario WHERE email = v_email;
  INSERT INTO core.usuario (tenant_id, email, password_hash, nombres, apellidos, estado)
  VALUES (v_tenant, v_email, crypt('ClaveCorrecta2026', gen_salt('bf',12)), 'Bloqueo','Prueba','activo');

  FOR i IN 1..6 LOOP
    r := app.sp_auth_login(v_email, 'claveMala' || i);
    RAISE INFO 'intento % -> %', i, coalesce(r->'error'->>'message', 'ENTRO');
  END LOOP;

  r := app.sp_auth_login(v_email, 'ClaveCorrecta2026');
  RAISE INFO 'con la contrasena CORRECTA estando bloqueada -> %', coalesce(r->'error'->>'message', 'ENTRO (MAL)');

  UPDATE core.usuario SET bloqueado_hasta = now() - interval '1 minute' WHERE email = v_email;
  r := app.sp_auth_login(v_email, 'ClaveCorrecta2026');
  RAISE INFO 'tras expirar el bloqueo -> %', CASE WHEN r->>'ok'='true' THEN 'ENTRO (correcto)' ELSE r->'error'->>'message' END;

  RAISE INFO 'contador tras entrar bien -> % (debe ser 0)', (SELECT intentos_fallidos FROM core.usuario WHERE email=v_email);
  RAISE INFO 'eventos login_fallido auditados -> %',
    (SELECT count(*) FROM audit.audit_log a WHERE a.accion='login_fallido'
      AND a.entidad_id = (SELECT id FROM core.usuario WHERE email=v_email));

  DELETE FROM audit.audit_log WHERE entidad_id IN (SELECT id FROM core.usuario WHERE email=v_email);
  DELETE FROM core.usuario WHERE email = v_email;
END $$;
