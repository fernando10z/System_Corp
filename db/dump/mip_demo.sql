-- =============================================================================
-- MIP · volcado de la base con los datos de demostración
--
-- Es el sistema entero en un archivo: esquemas, tablas, enums, triggers, los
-- stored procedures donde vive toda la lógica de negocio, y el juego de datos
-- de muestra (13 OT por todos los estados del Anexo A, 19 solicitudes, 8
-- cotizaciones con su PDF, el histórico de costos y el árbol de trazabilidad
-- ya construido).
--
-- Sirve para levantar MIP en otra máquina sin aplicar migraciones ni sembrar
-- nada:
--
--   bash db/scripts/restaurar-dump.sh
--
-- o a mano:
--
--   createdb mip_dev
--   psql -d mip_dev -f db/dump/mip_demo.sql
--   psql -d mip_dev -f db/migrations/90_grants.sql   # crea el rol de la API
--
-- ⚠  SON DATOS DE DEMOSTRACIÓN, NO DE PRODUCCIÓN.
--    Las contraseñas son las que documenta el README (admin@mip.local /
--    CambiarEnDeploy2026 y los correos @demoindustrial.pe / Demo.MIP.2026).
--    Nunca restaure esto sobre una base con datos reales: el volcado empieza
--    borrando los objetos que va a recrear.
--
-- Generado con --no-owner --no-privileges para que restaure bajo cualquier
-- usuario; por eso los permisos del rol de la aplicación se aplican aparte,
-- con 90_grants.sql. Se omiten las meta-órdenes \restrict de psql 16.13, que
-- no existen en versiones anteriores y romperían la restauración.
-- =============================================================================

--
-- PostgreSQL database dump
--


-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY core.usuario DROP CONSTRAINT IF EXISTS usuario_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.usuario_rol DROP CONSTRAINT IF EXISTS usuario_rol_usuario_id_fkey;
ALTER TABLE IF EXISTS ONLY core.usuario_rol DROP CONSTRAINT IF EXISTS usuario_rol_rol_id_fkey;
ALTER TABLE IF EXISTS ONLY core.usuario_alcance DROP CONSTRAINT IF EXISTS usuario_alcance_usuario_id_fkey;
ALTER TABLE IF EXISTS ONLY core.usuario_alcance DROP CONSTRAINT IF EXISTS usuario_alcance_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.usuario_alcance DROP CONSTRAINT IF EXISTS usuario_alcance_sucursal_id_fkey;
ALTER TABLE IF EXISTS ONLY core.usuario_alcance DROP CONSTRAINT IF EXISTS usuario_alcance_empresa_ruc_id_fkey;
ALTER TABLE IF EXISTS ONLY core.usuario_alcance DROP CONSTRAINT IF EXISTS usuario_alcance_area_id_fkey;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS trabajo_realizado_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS trabajo_realizado_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS trabajo_realizado_revisado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS trabajo_realizado_resultado_id_fkey;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS trabajo_realizado_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS trabajo_realizado_declarado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS trabajo_realizado_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.tipo_trabajo DROP CONSTRAINT IF EXISTS tipo_trabajo_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.tipo_trabajo DROP CONSTRAINT IF EXISTS tipo_trabajo_padre_id_fkey;
ALTER TABLE IF EXISTS ONLY core.tenant_configuracion DROP CONSTRAINT IF EXISTS tenant_configuracion_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.sucursal DROP CONSTRAINT IF EXISTS sucursal_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.sucursal_empresa_ruc DROP CONSTRAINT IF EXISTS sucursal_empresa_ruc_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.sucursal_empresa_ruc DROP CONSTRAINT IF EXISTS sucursal_empresa_ruc_sucursal_id_fkey;
ALTER TABLE IF EXISTS ONLY core.sucursal_empresa_ruc DROP CONSTRAINT IF EXISTS sucursal_empresa_ruc_empresa_ruc_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS solped_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS solped_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS solped_reemplaza_a_fkey;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS solped_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS solped_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS solped_cotizacion_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS solped_anulada_por_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_sucursal_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_solicitud_principal_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_solicitante_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_motivo_rechazo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_impacto_operativo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_empresa_ruc_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_coordinador_revisor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_area_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_decision DROP CONSTRAINT IF EXISTS solicitud_decision_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_decision DROP CONSTRAINT IF EXISTS solicitud_decision_solicitud_relacionada_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_decision DROP CONSTRAINT IF EXISTS solicitud_decision_solicitud_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_decision DROP CONSTRAINT IF EXISTS solicitud_decision_motivo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_decision DROP CONSTRAINT IF EXISTS solicitud_decision_destinatario_id_fkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_decision DROP CONSTRAINT IF EXISTS solicitud_decision_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.seguimiento_administrativo DROP CONSTRAINT IF EXISTS seguimiento_administrativo_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.seguimiento_administrativo DROP CONSTRAINT IF EXISTS seguimiento_administrativo_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.seguimiento_administrativo DROP CONSTRAINT IF EXISTS seguimiento_administrativo_revisado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.seguimiento_administrativo DROP CONSTRAINT IF EXISTS seguimiento_administrativo_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.seguimiento_administrativo DROP CONSTRAINT IF EXISTS seguimiento_administrativo_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.rol DROP CONSTRAINT IF EXISTS rol_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.rol_permiso DROP CONSTRAINT IF EXISTS rol_permiso_rol_id_fkey;
ALTER TABLE IF EXISTS ONLY core.rol_permiso DROP CONSTRAINT IF EXISTS rol_permiso_permiso_id_fkey;
ALTER TABLE IF EXISTS ONLY core.regla_normalizacion DROP CONSTRAINT IF EXISTS regla_normalizacion_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.regla_normalizacion DROP CONSTRAINT IF EXISTS regla_normalizacion_descripcion_normalizada_id_fkey;
ALTER TABLE IF EXISTS ONLY core.regla_normalizacion DROP CONSTRAINT IF EXISTS regla_normalizacion_aprobada_por_fkey;
ALTER TABLE IF EXISTS ONLY core.proveedor DROP CONSTRAINT IF EXISTS proveedor_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_reapertura DROP CONSTRAINT IF EXISTS ot_reapertura_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_reapertura DROP CONSTRAINT IF EXISTS ot_reapertura_reabierta_por_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_reapertura DROP CONSTRAINT IF EXISTS ot_reapertura_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_reapertura DROP CONSTRAINT IF EXISTS ot_reapertura_motivo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_reapertura DROP CONSTRAINT IF EXISTS ot_reapertura_cierre_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_pausa DROP CONSTRAINT IF EXISTS ot_pausa_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_pausa DROP CONSTRAINT IF EXISTS ot_pausa_reanudada_por_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_pausa DROP CONSTRAINT IF EXISTS ot_pausa_pausada_por_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_pausa DROP CONSTRAINT IF EXISTS ot_pausa_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_pausa DROP CONSTRAINT IF EXISTS ot_pausa_motivo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_incidencia DROP CONSTRAINT IF EXISTS ot_incidencia_tipo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_incidencia DROP CONSTRAINT IF EXISTS ot_incidencia_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_incidencia DROP CONSTRAINT IF EXISTS ot_incidencia_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_incidencia DROP CONSTRAINT IF EXISTS ot_incidencia_autor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_evento DROP CONSTRAINT IF EXISTS ot_evento_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_evento DROP CONSTRAINT IF EXISTS ot_evento_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_evento DROP CONSTRAINT IF EXISTS ot_evento_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_estado_historial DROP CONSTRAINT IF EXISTS ot_estado_historial_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_estado_historial DROP CONSTRAINT IF EXISTS ot_estado_historial_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_estado_historial DROP CONSTRAINT IF EXISTS ot_estado_historial_motivo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_estado_historial DROP CONSTRAINT IF EXISTS ot_estado_historial_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_cierre DROP CONSTRAINT IF EXISTS ot_cierre_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_cierre DROP CONSTRAINT IF EXISTS ot_cierre_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_cierre DROP CONSTRAINT IF EXISTS ot_cierre_cerrado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_avance DROP CONSTRAINT IF EXISTS ot_avance_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_avance DROP CONSTRAINT IF EXISTS ot_avance_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ot_avance DROP CONSTRAINT IF EXISTS ot_avance_autor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_tipo_trabajo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_tipo_mantenimiento_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_sucursal_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_solicitud_origen_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_ot_padre_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_motivo_derivacion_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_motivo_cancelacion_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_empresa_ruc_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_emergencia_declarada_por_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_ejecutor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_coordinador_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_cecos_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_area_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_compra DROP CONSTRAINT IF EXISTS orden_compra_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_compra DROP CONSTRAINT IF EXISTS orden_compra_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_compra DROP CONSTRAINT IF EXISTS orden_compra_solped_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_compra DROP CONSTRAINT IF EXISTS orden_compra_registrada_por_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_compra DROP CONSTRAINT IF EXISTS orden_compra_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.orden_compra DROP CONSTRAINT IF EXISTS orden_compra_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.notificacion DROP CONSTRAINT IF EXISTS notificacion_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.notificacion DROP CONSTRAINT IF EXISTS notificacion_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.notificacion DROP CONSTRAINT IF EXISTS notificacion_destinatario_id_fkey;
ALTER TABLE IF EXISTS ONLY core.mensaje DROP CONSTRAINT IF EXISTS mensaje_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.mensaje DROP CONSTRAINT IF EXISTS mensaje_retirado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.mensaje DROP CONSTRAINT IF EXISTS mensaje_responde_a_fkey;
ALTER TABLE IF EXISTS ONLY core.mensaje DROP CONSTRAINT IF EXISTS mensaje_conversacion_id_fkey;
ALTER TABLE IF EXISTS ONLY core.mensaje DROP CONSTRAINT IF EXISTS mensaje_autor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.liberacion_historial DROP CONSTRAINT IF EXISTS liberacion_historial_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.liberacion_historial DROP CONSTRAINT IF EXISTS liberacion_historial_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.liberacion_historial DROP CONSTRAINT IF EXISTS liberacion_historial_orden_compra_id_fkey;
ALTER TABLE IF EXISTS ONLY core.liberacion_historial DROP CONSTRAINT IF EXISTS liberacion_historial_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.empresa_ruc DROP CONSTRAINT IF EXISTS empresa_ruc_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ejecucion DROP CONSTRAINT IF EXISTS ejecucion_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.ejecucion DROP CONSTRAINT IF EXISTS ejecucion_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ejecucion DROP CONSTRAINT IF EXISTS ejecucion_responsable_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ejecucion DROP CONSTRAINT IF EXISTS ejecucion_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.ejecucion DROP CONSTRAINT IF EXISTS ejecucion_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.ejecucion DROP CONSTRAINT IF EXISTS ejecucion_confirmado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS diagnostico_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS diagnostico_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS diagnostico_reemplaza_a_fkey;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS diagnostico_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS diagnostico_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS diagnostico_autor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS diagnostico_aprobado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.descripcion_normalizada DROP CONSTRAINT IF EXISTS descripcion_normalizada_tipo_trabajo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.descripcion_normalizada DROP CONSTRAINT IF EXISTS descripcion_normalizada_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.descripcion_normalizada DROP CONSTRAINT IF EXISTS descripcion_normalizada_aprobada_por_fkey;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS cotizacion_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS cotizacion_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS cotizacion_reemplaza_a_fkey;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS cotizacion_proveedor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS cotizacion_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS cotizacion_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS cotizacion_cargada_por_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_tipo_trabajo_id_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_sucursal_id_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_proveedor_id_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_empresa_ruc_id_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_descripcion_normalizada_id_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_created_by_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_cotizacion_id_fkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_area_id_fkey;
ALTER TABLE IF EXISTS ONLY core.correlativo DROP CONSTRAINT IF EXISTS correlativo_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.conversacion DROP CONSTRAINT IF EXISTS conversacion_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.conversacion_participante DROP CONSTRAINT IF EXISTS conversacion_participante_usuario_id_fkey;
ALTER TABLE IF EXISTS ONLY core.conversacion_participante DROP CONSTRAINT IF EXISTS conversacion_participante_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.conversacion_participante DROP CONSTRAINT IF EXISTS conversacion_participante_invitado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.conversacion_participante DROP CONSTRAINT IF EXISTS conversacion_participante_conversacion_id_fkey;
ALTER TABLE IF EXISTS ONLY core.conversacion DROP CONSTRAINT IF EXISTS conversacion_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.cecos DROP CONSTRAINT IF EXISTS cecos_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.cecos DROP CONSTRAINT IF EXISTS cecos_empresa_ruc_id_fkey;
ALTER TABLE IF EXISTS ONLY core.cecos DROP CONSTRAINT IF EXISTS cecos_area_id_fkey;
ALTER TABLE IF EXISTS ONLY core.catalogo_item DROP CONSTRAINT IF EXISTS catalogo_item_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.area DROP CONSTRAINT IF EXISTS area_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.area DROP CONSTRAINT IF EXISTS area_empresa_ruc_id_fkey;
ALTER TABLE IF EXISTS ONLY core.adjunto DROP CONSTRAINT IF EXISTS adjunto_tenant_id_fkey;
ALTER TABLE IF EXISTS ONLY core.adjunto DROP CONSTRAINT IF EXISTS adjunto_retirado_por_fkey;
ALTER TABLE IF EXISTS ONLY core.adjunto DROP CONSTRAINT IF EXISTS adjunto_ot_id_fkey;
ALTER TABLE IF EXISTS ONLY core.adjunto DROP CONSTRAINT IF EXISTS adjunto_autor_id_fkey;
DROP TRIGGER IF EXISTS trg_usuario_set_updated_at ON core.usuario;
DROP TRIGGER IF EXISTS trg_trabajo_realizado_set_updated_at ON core.trabajo_realizado;
DROP TRIGGER IF EXISTS trg_trabajo_realizado_dirty ON core.trabajo_realizado;
DROP TRIGGER IF EXISTS trg_tipo_trabajo_set_updated_at ON core.tipo_trabajo;
DROP TRIGGER IF EXISTS trg_tenant_set_updated_at ON core.tenant;
DROP TRIGGER IF EXISTS trg_tenant_configuracion_set_updated_at ON core.tenant_configuracion;
DROP TRIGGER IF EXISTS trg_sucursal_set_updated_at ON core.sucursal;
DROP TRIGGER IF EXISTS trg_sucursal_dirty ON core.sucursal;
DROP TRIGGER IF EXISTS trg_solped_set_updated_at ON core.solped;
DROP TRIGGER IF EXISTS trg_solped_estado_admin ON core.solped;
DROP TRIGGER IF EXISTS trg_solped_dirty ON core.solped;
DROP TRIGGER IF EXISTS trg_solicitud_trabajo_set_updated_at ON core.solicitud_trabajo;
DROP TRIGGER IF EXISTS trg_solicitud_trabajo_dirty ON core.solicitud_trabajo;
DROP TRIGGER IF EXISTS trg_solicitud_decision_dirty ON core.solicitud_decision;
DROP TRIGGER IF EXISTS trg_seguimiento_administrativo_set_updated_at ON core.seguimiento_administrativo;
DROP TRIGGER IF EXISTS trg_seguimiento_administrativo_dirty ON core.seguimiento_administrativo;
DROP TRIGGER IF EXISTS trg_rol_set_updated_at ON core.rol;
DROP TRIGGER IF EXISTS trg_regla_normalizacion_set_updated_at ON core.regla_normalizacion;
DROP TRIGGER IF EXISTS trg_proveedor_set_updated_at ON core.proveedor;
DROP TRIGGER IF EXISTS trg_pausa_condicion ON core.ot_pausa;
DROP TRIGGER IF EXISTS trg_ot_reapertura_dirty ON core.ot_reapertura;
DROP TRIGGER IF EXISTS trg_ot_pausa_set_updated_at ON core.ot_pausa;
DROP TRIGGER IF EXISTS trg_ot_pausa_dirty ON core.ot_pausa;
DROP TRIGGER IF EXISTS trg_ot_jerarquia ON core.orden_trabajo;
DROP TRIGGER IF EXISTS trg_ot_incidencia_set_updated_at ON core.ot_incidencia;
DROP TRIGGER IF EXISTS trg_ot_incidencia_dirty ON core.ot_incidencia;
DROP TRIGGER IF EXISTS trg_ot_guarda_cerrada ON core.orden_trabajo;
DROP TRIGGER IF EXISTS trg_ot_evento_inmutable ON core.ot_evento;
DROP TRIGGER IF EXISTS trg_ot_evento_dirty ON core.ot_evento;
DROP TRIGGER IF EXISTS trg_ot_estado_historial_dirty ON core.ot_estado_historial;
DROP TRIGGER IF EXISTS trg_ot_dirty_self ON core.orden_trabajo;
DROP TRIGGER IF EXISTS trg_ot_cierre_dirty ON core.ot_cierre;
DROP TRIGGER IF EXISTS trg_ot_avance_dirty ON core.ot_avance;
DROP TRIGGER IF EXISTS trg_orden_trabajo_set_updated_at ON core.orden_trabajo;
DROP TRIGGER IF EXISTS trg_orden_compra_set_updated_at ON core.orden_compra;
DROP TRIGGER IF EXISTS trg_orden_compra_estado_admin ON core.orden_compra;
DROP TRIGGER IF EXISTS trg_orden_compra_dirty ON core.orden_compra;
DROP TRIGGER IF EXISTS trg_notificacion_set_updated_at ON core.notificacion;
DROP TRIGGER IF EXISTS trg_notificacion_dirty ON core.notificacion;
DROP TRIGGER IF EXISTS trg_mensaje_set_updated_at ON core.mensaje;
DROP TRIGGER IF EXISTS trg_mensaje_dirty ON core.mensaje;
DROP TRIGGER IF EXISTS trg_liberacion_historial_estado_admin ON core.liberacion_historial;
DROP TRIGGER IF EXISTS trg_liberacion_historial_dirty ON core.liberacion_historial;
DROP TRIGGER IF EXISTS trg_empresa_ruc_set_updated_at ON core.empresa_ruc;
DROP TRIGGER IF EXISTS trg_empresa_ruc_dirty ON core.empresa_ruc;
DROP TRIGGER IF EXISTS trg_ejecucion_set_updated_at ON core.ejecucion;
DROP TRIGGER IF EXISTS trg_ejecucion_dirty ON core.ejecucion;
DROP TRIGGER IF EXISTS trg_diagnostico_set_updated_at ON core.diagnostico;
DROP TRIGGER IF EXISTS trg_diagnostico_dirty ON core.diagnostico;
DROP TRIGGER IF EXISTS trg_descripcion_normalizada_set_updated_at ON core.descripcion_normalizada;
DROP TRIGGER IF EXISTS trg_cotizacion_set_updated_at ON core.cotizacion;
DROP TRIGGER IF EXISTS trg_cotizacion_dirty ON core.cotizacion;
DROP TRIGGER IF EXISTS trg_costo_unitario_set_updated_at ON core.costo_unitario;
DROP TRIGGER IF EXISTS trg_costo_unitario_dirty ON core.costo_unitario;
DROP TRIGGER IF EXISTS trg_correlativo_set_updated_at ON core.correlativo;
DROP TRIGGER IF EXISTS trg_conversacion_set_updated_at ON core.conversacion;
DROP TRIGGER IF EXISTS trg_conversacion_participante_set_updated_at ON core.conversacion_participante;
DROP TRIGGER IF EXISTS trg_conversacion_participante_dirty ON core.conversacion_participante;
DROP TRIGGER IF EXISTS trg_conversacion_dirty ON core.conversacion;
DROP TRIGGER IF EXISTS trg_cecos_set_updated_at ON core.cecos;
DROP TRIGGER IF EXISTS trg_catalogo_item_set_updated_at ON core.catalogo_item;
DROP TRIGGER IF EXISTS trg_area_set_updated_at ON core.area;
DROP TRIGGER IF EXISTS trg_area_dirty ON core.area;
DROP TRIGGER IF EXISTS trg_adjunto_set_updated_at ON core.adjunto;
DROP TRIGGER IF EXISTS trg_adjunto_dirty ON core.adjunto;
DROP INDEX IF EXISTS core.uq_trabajo_realizado_vigente;
DROP INDEX IF EXISTS core.uq_solped_vigente;
DROP INDEX IF EXISTS core.uq_pausa_abierta;
DROP INDEX IF EXISTS core.uq_ot_solicitud_origen;
DROP INDEX IF EXISTS core.uq_ot_cierre_vigente;
DROP INDEX IF EXISTS core.uq_diagnostico_vigente;
DROP INDEX IF EXISTS core.uq_cotizacion_vigente;
DROP INDEX IF EXISTS core.ix_usuario_tenant;
DROP INDEX IF EXISTS core.ix_usuario_email_lower;
DROP INDEX IF EXISTS core.ix_usuario_alcance_usuario;
DROP INDEX IF EXISTS core.ix_sucursal_tenant;
DROP INDEX IF EXISTS core.ix_solped_ot;
DROP INDEX IF EXISTS core.ix_solped_numero_sap;
DROP INDEX IF EXISTS core.ix_solicitud_titulo_trgm;
DROP INDEX IF EXISTS core.ix_solicitud_tenant_estado;
DROP INDEX IF EXISTS core.ix_solicitud_solicitante;
DROP INDEX IF EXISTS core.ix_solicitud_decision_solicitud;
DROP INDEX IF EXISTS core.ix_solicitud_area;
DROP INDEX IF EXISTS core.ix_proveedor_razon_trgm;
DROP INDEX IF EXISTS core.ix_ot_trazabilidad_gin;
DROP INDEX IF EXISTS core.ix_ot_tenant_estado;
DROP INDEX IF EXISTS core.ix_ot_reapertura_ot;
DROP INDEX IF EXISTS core.ix_ot_pausa_ot;
DROP INDEX IF EXISTS core.ix_ot_padre;
DROP INDEX IF EXISTS core.ix_ot_organizacion;
DROP INDEX IF EXISTS core.ix_ot_incidencia_ot;
DROP INDEX IF EXISTS core.ix_ot_evento_ot;
DROP INDEX IF EXISTS core.ix_ot_evento_dominio;
DROP INDEX IF EXISTS core.ix_ot_estado_historial_ot;
DROP INDEX IF EXISTS core.ix_ot_emergencia;
DROP INDEX IF EXISTS core.ix_ot_ejecutor;
DROP INDEX IF EXISTS core.ix_ot_dirty;
DROP INDEX IF EXISTS core.ix_ot_coordinador;
DROP INDEX IF EXISTS core.ix_ot_avance_ot;
DROP INDEX IF EXISTS core.ix_ot_admin;
DROP INDEX IF EXISTS core.ix_orden_compra_ot;
DROP INDEX IF EXISTS core.ix_notificacion_destinatario;
DROP INDEX IF EXISTS core.ix_mensaje_conversacion;
DROP INDEX IF EXISTS core.ix_liberacion_ot;
DROP INDEX IF EXISTS core.ix_empresa_ruc_tenant;
DROP INDEX IF EXISTS core.ix_empresa_ruc_razon_trgm;
DROP INDEX IF EXISTS core.ix_diagnostico_ot;
DROP INDEX IF EXISTS core.ix_cotizacion_proveedor;
DROP INDEX IF EXISTS core.ix_cotizacion_ot;
DROP INDEX IF EXISTS core.ix_costo_texto_trgm;
DROP INDEX IF EXISTS core.ix_costo_ot;
DROP INDEX IF EXISTS core.ix_costo_busqueda;
DROP INDEX IF EXISTS core.ix_catalogo_item_tipo;
DROP INDEX IF EXISTS core.ix_area_tenant;
DROP INDEX IF EXISTS core.ix_area_empresa_ruc;
DROP INDEX IF EXISTS core.ix_adjunto_ot;
DROP INDEX IF EXISTS core.ix_adjunto_entidad;
DROP INDEX IF EXISTS audit.ix_audit_log_tenant;
DROP INDEX IF EXISTS audit.ix_audit_log_entidad;
DROP INDEX IF EXISTS audit.ix_audit_log_actor;
ALTER TABLE IF EXISTS ONLY core.usuario_rol DROP CONSTRAINT IF EXISTS usuario_rol_pkey;
ALTER TABLE IF EXISTS ONLY core.usuario DROP CONSTRAINT IF EXISTS usuario_pkey;
ALTER TABLE IF EXISTS ONLY core.usuario_alcance DROP CONSTRAINT IF EXISTS usuario_alcance_pkey;
ALTER TABLE IF EXISTS ONLY core.usuario_rol DROP CONSTRAINT IF EXISTS uq_usuario_rol;
ALTER TABLE IF EXISTS ONLY core.usuario DROP CONSTRAINT IF EXISTS uq_usuario_email;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS uq_trabajo_realizado_version;
ALTER TABLE IF EXISTS ONLY core.tipo_trabajo DROP CONSTRAINT IF EXISTS uq_tipo_trabajo_codigo;
ALTER TABLE IF EXISTS ONLY core.tenant_configuracion DROP CONSTRAINT IF EXISTS uq_tenant_configuracion;
ALTER TABLE IF EXISTS ONLY core.tenant DROP CONSTRAINT IF EXISTS uq_tenant_codigo;
ALTER TABLE IF EXISTS ONLY core.sucursal_empresa_ruc DROP CONSTRAINT IF EXISTS uq_sucursal_empresa_ruc;
ALTER TABLE IF EXISTS ONLY core.sucursal DROP CONSTRAINT IF EXISTS uq_sucursal_codigo;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS uq_solped_version;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS uq_solicitud_numero;
ALTER TABLE IF EXISTS ONLY core.seguimiento_administrativo DROP CONSTRAINT IF EXISTS uq_seguimiento_admin_ot;
ALTER TABLE IF EXISTS ONLY core.rol_permiso DROP CONSTRAINT IF EXISTS uq_rol_permiso;
ALTER TABLE IF EXISTS ONLY core.rol DROP CONSTRAINT IF EXISTS uq_rol_codigo;
ALTER TABLE IF EXISTS ONLY core.proveedor DROP CONSTRAINT IF EXISTS uq_proveedor_ruc;
ALTER TABLE IF EXISTS ONLY core.permiso DROP CONSTRAINT IF EXISTS uq_permiso_codigo;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS uq_ot_numero;
ALTER TABLE IF EXISTS ONLY core.ot_cierre DROP CONSTRAINT IF EXISTS uq_ot_cierre_secuencia;
ALTER TABLE IF EXISTS ONLY core.empresa_ruc DROP CONSTRAINT IF EXISTS uq_empresa_ruc_ruc;
ALTER TABLE IF EXISTS ONLY core.ejecucion DROP CONSTRAINT IF EXISTS uq_ejecucion_ot;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS uq_diagnostico_version;
ALTER TABLE IF EXISTS ONLY core.descripcion_normalizada DROP CONSTRAINT IF EXISTS uq_descripcion_normalizada;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS uq_cotizacion_version;
ALTER TABLE IF EXISTS ONLY core.correlativo DROP CONSTRAINT IF EXISTS uq_correlativo;
ALTER TABLE IF EXISTS ONLY core.conversacion_participante DROP CONSTRAINT IF EXISTS uq_conversacion_participante;
ALTER TABLE IF EXISTS ONLY core.conversacion DROP CONSTRAINT IF EXISTS uq_conversacion_ot;
ALTER TABLE IF EXISTS ONLY core.cecos DROP CONSTRAINT IF EXISTS uq_cecos_codigo;
ALTER TABLE IF EXISTS ONLY core.catalogo_item DROP CONSTRAINT IF EXISTS uq_catalogo_item;
ALTER TABLE IF EXISTS ONLY core.area DROP CONSTRAINT IF EXISTS uq_area_codigo;
ALTER TABLE IF EXISTS ONLY core.trabajo_realizado DROP CONSTRAINT IF EXISTS trabajo_realizado_pkey;
ALTER TABLE IF EXISTS ONLY core.tipo_trabajo DROP CONSTRAINT IF EXISTS tipo_trabajo_pkey;
ALTER TABLE IF EXISTS ONLY core.tenant DROP CONSTRAINT IF EXISTS tenant_pkey;
ALTER TABLE IF EXISTS ONLY core.tenant_configuracion DROP CONSTRAINT IF EXISTS tenant_configuracion_pkey;
ALTER TABLE IF EXISTS ONLY core.sucursal DROP CONSTRAINT IF EXISTS sucursal_pkey;
ALTER TABLE IF EXISTS ONLY core.sucursal_empresa_ruc DROP CONSTRAINT IF EXISTS sucursal_empresa_ruc_pkey;
ALTER TABLE IF EXISTS ONLY core.solped DROP CONSTRAINT IF EXISTS solped_pkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_trabajo DROP CONSTRAINT IF EXISTS solicitud_trabajo_pkey;
ALTER TABLE IF EXISTS ONLY core.solicitud_decision DROP CONSTRAINT IF EXISTS solicitud_decision_pkey;
ALTER TABLE IF EXISTS ONLY core.seguimiento_administrativo DROP CONSTRAINT IF EXISTS seguimiento_administrativo_pkey;
ALTER TABLE IF EXISTS ONLY core.rol DROP CONSTRAINT IF EXISTS rol_pkey;
ALTER TABLE IF EXISTS ONLY core.rol_permiso DROP CONSTRAINT IF EXISTS rol_permiso_pkey;
ALTER TABLE IF EXISTS ONLY core.regla_normalizacion DROP CONSTRAINT IF EXISTS regla_normalizacion_pkey;
ALTER TABLE IF EXISTS ONLY core.proveedor DROP CONSTRAINT IF EXISTS proveedor_pkey;
ALTER TABLE IF EXISTS ONLY core.permiso DROP CONSTRAINT IF EXISTS permiso_pkey;
ALTER TABLE IF EXISTS ONLY core.ot_reapertura DROP CONSTRAINT IF EXISTS ot_reapertura_pkey;
ALTER TABLE IF EXISTS ONLY core.ot_pausa DROP CONSTRAINT IF EXISTS ot_pausa_pkey;
ALTER TABLE IF EXISTS ONLY core.ot_incidencia DROP CONSTRAINT IF EXISTS ot_incidencia_pkey;
ALTER TABLE IF EXISTS ONLY core.ot_evento DROP CONSTRAINT IF EXISTS ot_evento_pkey;
ALTER TABLE IF EXISTS ONLY core.ot_estado_historial DROP CONSTRAINT IF EXISTS ot_estado_historial_pkey;
ALTER TABLE IF EXISTS ONLY core.ot_cierre DROP CONSTRAINT IF EXISTS ot_cierre_pkey;
ALTER TABLE IF EXISTS ONLY core.ot_avance DROP CONSTRAINT IF EXISTS ot_avance_pkey;
ALTER TABLE IF EXISTS ONLY core.orden_trabajo DROP CONSTRAINT IF EXISTS orden_trabajo_pkey;
ALTER TABLE IF EXISTS ONLY core.orden_compra DROP CONSTRAINT IF EXISTS orden_compra_pkey;
ALTER TABLE IF EXISTS ONLY core.notificacion DROP CONSTRAINT IF EXISTS notificacion_pkey;
ALTER TABLE IF EXISTS ONLY core.mensaje DROP CONSTRAINT IF EXISTS mensaje_pkey;
ALTER TABLE IF EXISTS ONLY core.liberacion_historial DROP CONSTRAINT IF EXISTS liberacion_historial_pkey;
ALTER TABLE IF EXISTS ONLY core.empresa_ruc DROP CONSTRAINT IF EXISTS empresa_ruc_pkey;
ALTER TABLE IF EXISTS ONLY core.ejecucion DROP CONSTRAINT IF EXISTS ejecucion_pkey;
ALTER TABLE IF EXISTS ONLY core.diagnostico DROP CONSTRAINT IF EXISTS diagnostico_pkey;
ALTER TABLE IF EXISTS ONLY core.descripcion_normalizada DROP CONSTRAINT IF EXISTS descripcion_normalizada_pkey;
ALTER TABLE IF EXISTS ONLY core.cotizacion DROP CONSTRAINT IF EXISTS cotizacion_pkey;
ALTER TABLE IF EXISTS ONLY core.costo_unitario DROP CONSTRAINT IF EXISTS costo_unitario_pkey;
ALTER TABLE IF EXISTS ONLY core.correlativo DROP CONSTRAINT IF EXISTS correlativo_pkey;
ALTER TABLE IF EXISTS ONLY core.conversacion DROP CONSTRAINT IF EXISTS conversacion_pkey;
ALTER TABLE IF EXISTS ONLY core.conversacion_participante DROP CONSTRAINT IF EXISTS conversacion_participante_pkey;
ALTER TABLE IF EXISTS ONLY core.cecos DROP CONSTRAINT IF EXISTS cecos_pkey;
ALTER TABLE IF EXISTS ONLY core.catalogo_item DROP CONSTRAINT IF EXISTS catalogo_item_pkey;
ALTER TABLE IF EXISTS ONLY core.area DROP CONSTRAINT IF EXISTS area_pkey;
ALTER TABLE IF EXISTS ONLY core.adjunto DROP CONSTRAINT IF EXISTS adjunto_pkey;
ALTER TABLE IF EXISTS ONLY audit.audit_log DROP CONSTRAINT IF EXISTS audit_log_pkey;
ALTER TABLE IF EXISTS core.ot_evento ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS core.liberacion_historial ALTER COLUMN secuencia DROP DEFAULT;
ALTER TABLE IF EXISTS audit.audit_log ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS core.usuario_rol;
DROP TABLE IF EXISTS core.usuario_alcance;
DROP TABLE IF EXISTS core.usuario;
DROP TABLE IF EXISTS core.trabajo_realizado;
DROP TABLE IF EXISTS core.tipo_trabajo;
DROP TABLE IF EXISTS core.tenant_configuracion;
DROP TABLE IF EXISTS core.tenant;
DROP TABLE IF EXISTS core.sucursal_empresa_ruc;
DROP TABLE IF EXISTS core.sucursal;
DROP TABLE IF EXISTS core.solped;
DROP TABLE IF EXISTS core.solicitud_trabajo;
DROP TABLE IF EXISTS core.solicitud_decision;
DROP TABLE IF EXISTS core.seguimiento_administrativo;
DROP TABLE IF EXISTS core.rol_permiso;
DROP TABLE IF EXISTS core.rol;
DROP TABLE IF EXISTS core.regla_normalizacion;
DROP TABLE IF EXISTS core.proveedor;
DROP TABLE IF EXISTS core.permiso;
DROP TABLE IF EXISTS core.ot_reapertura;
DROP TABLE IF EXISTS core.ot_pausa;
DROP TABLE IF EXISTS core.ot_incidencia;
DROP SEQUENCE IF EXISTS core.ot_evento_id_seq;
DROP TABLE IF EXISTS core.ot_evento;
DROP TABLE IF EXISTS core.ot_estado_historial;
DROP TABLE IF EXISTS core.ot_cierre;
DROP TABLE IF EXISTS core.ot_avance;
DROP TABLE IF EXISTS core.orden_compra;
DROP TABLE IF EXISTS core.notificacion;
DROP TABLE IF EXISTS core.mensaje;
DROP SEQUENCE IF EXISTS core.liberacion_historial_secuencia_seq;
DROP TABLE IF EXISTS core.liberacion_historial;
DROP TABLE IF EXISTS core.empresa_ruc;
DROP TABLE IF EXISTS core.ejecucion;
DROP TABLE IF EXISTS core.diagnostico;
DROP TABLE IF EXISTS core.descripcion_normalizada;
DROP TABLE IF EXISTS core.cotizacion;
DROP TABLE IF EXISTS core.costo_unitario;
DROP TABLE IF EXISTS core.correlativo;
DROP TABLE IF EXISTS core.conversacion_participante;
DROP TABLE IF EXISTS core.conversacion;
DROP TABLE IF EXISTS core.cecos;
DROP TABLE IF EXISTS core.catalogo_item;
DROP TABLE IF EXISTS core.area;
DROP TABLE IF EXISTS core.adjunto;
DROP SEQUENCE IF EXISTS audit.audit_log_id_seq;
DROP TABLE IF EXISTS audit.audit_log;
DROP FUNCTION IF EXISTS public.t_raise();
DROP FUNCTION IF EXISTS public.t_div();
DROP FUNCTION IF EXISTS internal.validar_transicion_ot(p_ot_id uuid, p_desde core.ot_estado, p_hacia core.ot_estado, p_motivo text);
DROP FUNCTION IF EXISTS internal.validar_ruc(p_ruc text);
DROP FUNCTION IF EXISTS internal.siguiente_numero(p_tenant_id uuid, p_tipo_documento text, p_prefijo text);
DROP FUNCTION IF EXISTS internal.registrar_evento_ot(p_tenant_id uuid, p_ot_id uuid, p_dominio core.dominio_evento, p_evento text, p_actor_id uuid, p_entidad_tipo text, p_entidad_id uuid, p_anterior jsonb, p_nuevo jsonb, p_motivo text);
DROP FUNCTION IF EXISTS internal.registrar_auditoria(p_actor_id uuid, p_tenant_id uuid, p_accion text, p_entidad text, p_entidad_id uuid, p_antes jsonb, p_despues jsonb, p_motivo text);
DROP FUNCTION IF EXISTS internal.ot_visible(p_ot_id uuid, p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP TABLE IF EXISTS core.orden_trabajo;
DROP FUNCTION IF EXISTS internal.notificar_coordinadores(p_tenant_id uuid, p_area_id uuid, p_evento text, p_titulo text, p_cuerpo text, p_entidad_tipo text, p_entidad_id uuid);
DROP FUNCTION IF EXISTS internal.notificar(p_tenant_id uuid, p_destinatario_id uuid, p_evento text, p_titulo text, p_cuerpo text, p_ot_id uuid, p_entidad_tipo text, p_entidad_id uuid);
DROP FUNCTION IF EXISTS internal.normalizar_busqueda(p_texto text);
DROP FUNCTION IF EXISTS internal.meta_paginacion(p_total integer, p_page integer, p_size integer);
DROP FUNCTION IF EXISTS internal.marcar_ot_dirty_hijas(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.marcar_ot_dirty(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.limite_adjunto(p_tenant_id uuid, p_tipo core.tipo_adjunto);
DROP FUNCTION IF EXISTS internal.fn_ot_trazabilidad_fresca(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_trazabilidad(p_ot_id uuid, p_profundidad integer, p_resumido boolean);
DROP FUNCTION IF EXISTS internal.fn_ot_origen(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_organizacion(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_eventos(p_ot_id uuid, p_limite integer);
DROP FUNCTION IF EXISTS internal.fn_ot_ejecucion(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_diagnosticos(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_cotizaciones(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_costos(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_conversacion(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_cierre(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_cabecera(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_ot_administrativo(p_ot_id uuid);
DROP FUNCTION IF EXISTS internal.fn_adjuntos_de(p_entidad_tipo text, p_entidad_id uuid);
DROP FUNCTION IF EXISTS internal.es_acceso_global(p_user_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS internal.error_jsonb(p_code text, p_message text, p_field text);
DROP FUNCTION IF EXISTS internal.config(p_tenant_id uuid, p_clave text, p_default jsonb);
DROP FUNCTION IF EXISTS internal.codigo_error(p_sqlstate text);
DROP FUNCTION IF EXISTS internal.claves_configurables();
DROP FUNCTION IF EXISTS internal.avanzar_estado_ot(p_tenant_id uuid, p_ot_id uuid, p_desde core.ot_estado, p_hacia core.ot_estado, p_user_id uuid, p_motivo text);
DROP FUNCTION IF EXISTS internal.assert_permiso(p_user_id uuid, p_permiso text);
DROP FUNCTION IF EXISTS internal.assert_alcance(p_user_id uuid, p_sucursal_id uuid, p_empresa_ruc_id uuid, p_area_id uuid);
DROP FUNCTION IF EXISTS internal.assert_acceso_tenant(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS core.validar_jerarquia_ot();
DROP FUNCTION IF EXISTS core.trg_dirty_por_solicitud_hija();
DROP FUNCTION IF EXISTS core.trg_dirty_por_solicitud();
DROP FUNCTION IF EXISTS core.trg_dirty_por_ot_id();
DROP FUNCTION IF EXISTS core.trg_dirty_por_organizacion();
DROP FUNCTION IF EXISTS core.trg_dirty_por_conversacion();
DROP FUNCTION IF EXISTS core.trg_dirty_ot_self();
DROP FUNCTION IF EXISTS core.set_updated_at();
DROP FUNCTION IF EXISTS core.refrescar_estado_administrativo();
DROP FUNCTION IF EXISTS core.refrescar_condicion_ot();
DROP FUNCTION IF EXISTS core.guardar_ot_cerrada();
DROP FUNCTION IF EXISTS core.consolidar_estado_administrativo(p_ot_id uuid);
DROP FUNCTION IF EXISTS core.bloquear_mutacion_bitacora();
DROP FUNCTION IF EXISTS app.sp_usuario_restablecer_password(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_usuario_id uuid, p_password_nueva text);
DROP FUNCTION IF EXISTS app.sp_usuario_inactivar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_usuario_id uuid, p_motivo text);
DROP FUNCTION IF EXISTS app.sp_usuario_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_email text, p_nombres text, p_apellidos text, p_password text, p_rol_codigos text[], p_cargo text, p_documento text, p_telefono text, p_alcance jsonb);
DROP FUNCTION IF EXISTS app.sp_usuario_actualizar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_usuario_id uuid, p_nombres text, p_apellidos text, p_cargo text, p_documento text, p_telefono text, p_rol_codigos text[], p_estado text);
DROP FUNCTION IF EXISTS app.sp_trazabilidad_refrescar_pendientes(p_limite integer);
DROP FUNCTION IF EXISTS app.sp_trabajo_revisar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_resultado text, p_observacion text);
DROP FUNCTION IF EXISTS app.sp_trabajo_realizado_declarar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_descripcion text, p_fecha_termino timestamp with time zone, p_resultado_id uuid, p_resultado_texto text, p_observaciones text);
DROP FUNCTION IF EXISTS app.sp_tipo_trabajo_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_codigo text, p_nombre text, p_padre_id uuid, p_descripcion text);
DROP FUNCTION IF EXISTS app.sp_sucursal_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_codigo text, p_nombre text, p_direccion text);
DROP FUNCTION IF EXISTS app.sp_solped_registrar_numero_sap(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solped_id uuid, p_numero_sap text, p_observacion text);
DROP FUNCTION IF EXISTS app.sp_solped_preparar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_formulario jsonb, p_cotizacion_id uuid, p_numero_interno text);
DROP FUNCTION IF EXISTS app.sp_solped_marcar_lista(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solped_id uuid);
DROP FUNCTION IF EXISTS app.sp_solped_anular(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solped_id uuid, p_motivo text);
DROP FUNCTION IF EXISTS app.sp_solicitud_tomar_revision(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid);
DROP FUNCTION IF EXISTS app.sp_solicitud_enviar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid);
DROP FUNCTION IF EXISTS app.sp_solicitud_decidir(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid, p_tipo text, p_comentario text, p_motivo_id uuid, p_destinatario_id uuid, p_solicitud_principal_id uuid);
DROP FUNCTION IF EXISTS app.sp_solicitud_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_titulo text, p_descripcion text, p_lugar text, p_area_id uuid, p_impacto_operativo_id uuid, p_impacto_comentario text, p_prioridad_percibida text, p_enviar boolean);
DROP FUNCTION IF EXISTS app.sp_rol_asignar_permisos(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_rol_id uuid, p_permiso_codigos text[]);
DROP FUNCTION IF EXISTS app.sp_proveedor_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_razon_social text, p_ruc text, p_contacto text, p_telefono text, p_email text);
DROP FUNCTION IF EXISTS app.sp_pausa_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_motivo_texto text, p_motivo_id uuid);
DROP FUNCTION IF EXISTS app.sp_pausa_reanudar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_observacion text);
DROP FUNCTION IF EXISTS app.sp_ot_trazabilidad_refrescar(p_ot_id uuid, p_forzar boolean);
DROP FUNCTION IF EXISTS app.sp_ot_reabrir(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_motivo_texto text, p_estado_retorno text, p_motivo_id uuid);
DROP FUNCTION IF EXISTS app.sp_ot_crear_desde_solicitud(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid, p_sucursal_id uuid, p_empresa_ruc_id uuid, p_area_id uuid, p_tipo_mantenimiento_id uuid, p_prioridad_tecnica text, p_coordinador_id uuid, p_es_emergencia boolean, p_emergencia_justificacion text, p_tipo_trabajo_id uuid, p_cecos_id uuid);
DROP FUNCTION IF EXISTS app.sp_ot_crear_derivada(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_padre_id uuid, p_motivo_derivacion text, p_tipo_mantenimiento_id uuid, p_tipo_trabajo_id uuid, p_prioridad_tecnica text, p_coordinador_id uuid, p_sucursal_id uuid, p_empresa_ruc_id uuid, p_area_id uuid, p_es_bloqueante boolean, p_motivo_derivacion_id uuid);
DROP FUNCTION IF EXISTS app.sp_ot_cerrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_admin_revisado boolean, p_observacion_pendiente text);
DROP FUNCTION IF EXISTS app.sp_ot_cancelar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_motivo_id uuid, p_observacion text, p_tratamiento_derivadas text);
DROP FUNCTION IF EXISTS app.sp_ot_cambiar_prioridad(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_prioridad text, p_motivo text);
DROP FUNCTION IF EXISTS app.sp_ot_cambiar_estado(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_nuevo_estado text, p_motivo text, p_motivo_id uuid);
DROP FUNCTION IF EXISTS app.sp_ot_actualizar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_payload jsonb);
DROP FUNCTION IF EXISTS app.sp_orden_compra_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_numero_oc text, p_fecha_oc date, p_monto numeric, p_moneda text, p_observacion text, p_solped_id uuid);
DROP FUNCTION IF EXISTS app.sp_notificacion_marcar_leida(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_notificacion_id uuid);
DROP FUNCTION IF EXISTS app.sp_notificacion_marcar_enviada(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_notificacion_id uuid, p_exito boolean, p_error text);
DROP FUNCTION IF EXISTS app.sp_mensaje_retirar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_mensaje_id uuid, p_motivo text);
DROP FUNCTION IF EXISTS app.sp_mensaje_publicar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_cuerpo text, p_visibilidad text, p_responde_a uuid, p_menciones uuid[]);
DROP FUNCTION IF EXISTS app.sp_mensaje_editar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_mensaje_id uuid, p_cuerpo text);
DROP FUNCTION IF EXISTS app.sp_liberacion_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_estado text, p_monto numeric, p_observacion text, p_orden_compra_id uuid);
DROP FUNCTION IF EXISTS app.sp_incidencia_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_descripcion text, p_tipo_id uuid);
DROP FUNCTION IF EXISTS app.sp_empresa_ruc_inactivar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_empresa_ruc_id uuid, p_motivo text);
DROP FUNCTION IF EXISTS app.sp_empresa_ruc_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ruc text, p_razon_social text, p_nombre_corto text, p_sucursal_ids uuid[]);
DROP FUNCTION IF EXISTS app.sp_ejecucion_iniciar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_responsable_id uuid, p_inicio_real timestamp with time zone, p_observaciones text);
DROP FUNCTION IF EXISTS app.sp_diagnostico_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_diagnostico text, p_causa_probable text, p_alcance text, p_trabajo_a_realizar text, p_observaciones text, p_lecturas_instrumentos text, p_motivo_cambio text);
DROP FUNCTION IF EXISTS app.sp_diagnostico_aprobar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_diagnostico_id uuid, p_observacion text);
DROP FUNCTION IF EXISTS app.sp_cotizacion_invalidar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_cotizacion_id uuid, p_motivo text);
DROP FUNCTION IF EXISTS app.sp_cotizacion_cargar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_proveedor_id uuid, p_proveedor_nombre text, p_proveedor_ruc text, p_numero_cotizacion text, p_fecha_cotizacion date, p_monto numeric, p_moneda text, p_plazo_ofrecido_dias integer, p_validez_dias integer, p_observaciones text, p_motivo_reemplazo text);
DROP FUNCTION IF EXISTS app.sp_costo_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_texto_original text, p_monto_total numeric, p_fuente text, p_concepto text, p_cantidad numeric, p_unidad text, p_moneda text, p_cotizacion_id uuid, p_descripcion_normalizada_id uuid);
DROP FUNCTION IF EXISTS app.sp_costo_calificar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_costo_id uuid, p_es_comparable boolean, p_es_outlier boolean, p_justificacion text);
DROP FUNCTION IF EXISTS app.sp_conversacion_invitar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_usuario_id uuid, p_puede_escribir boolean, p_ve_notas_internas boolean);
DROP FUNCTION IF EXISTS app.sp_conformidad_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_conformidad text, p_comentario text);
DROP FUNCTION IF EXISTS app.sp_configuracion_guardar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_clave text, p_valor jsonb, p_descripcion text);
DROP FUNCTION IF EXISTS app.sp_catalogo_item_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_tipo text, p_codigo text, p_nombre text, p_descripcion text, p_orden integer, p_requiere_comentario boolean);
DROP FUNCTION IF EXISTS app.sp_avance_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_descripcion text, p_porcentaje numeric);
DROP FUNCTION IF EXISTS app.sp_auth_login(p_email text, p_password text);
DROP FUNCTION IF EXISTS app.sp_auth_cambiar_password(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_password_actual text, p_password_nueva text);
DROP FUNCTION IF EXISTS app.sp_area_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_empresa_ruc_id uuid, p_codigo text, p_nombre text);
DROP FUNCTION IF EXISTS app.sp_adjunto_retirar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_adjunto_id uuid, p_motivo text);
DROP FUNCTION IF EXISTS app.sp_adjunto_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_entidad_tipo text, p_entidad_id uuid, p_etapa text, p_tipo text, p_nombre text, p_storage_key text, p_mime_type text, p_tamano_bytes bigint, p_ot_id uuid, p_visibilidad text, p_checksum text);
DROP FUNCTION IF EXISTS app.fn_usuario_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb, p_page integer, p_page_size integer);
DROP FUNCTION IF EXISTS app.fn_usuario_asignables(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb);
DROP FUNCTION IF EXISTS app.fn_trazabilidad_verificar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_limite integer);
DROP FUNCTION IF EXISTS app.fn_trazabilidad_buscar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_criterio jsonb, p_limite integer);
DROP FUNCTION IF EXISTS app.fn_tipo_trabajo_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS app.fn_solicitud_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid);
DROP FUNCTION IF EXISTS app.fn_solicitud_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb, p_page integer, p_page_size integer);
DROP FUNCTION IF EXISTS app.fn_sla_solicitudes(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS app.fn_rol_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS app.fn_reporte_ot(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb, p_limite integer);
DROP FUNCTION IF EXISTS app.fn_proveedor_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb, p_page integer, p_page_size integer);
DROP FUNCTION IF EXISTS app.fn_permiso_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS app.fn_ot_trazabilidad(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_profundidad integer);
DROP FUNCTION IF EXISTS app.fn_ot_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid);
DROP FUNCTION IF EXISTS app.fn_ot_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb, p_page integer, p_page_size integer);
DROP FUNCTION IF EXISTS app.fn_ot_linea_tiempo(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid);
DROP FUNCTION IF EXISTS app.fn_ot_historial(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid);
DROP FUNCTION IF EXISTS app.fn_ot_consolidado(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid);
DROP FUNCTION IF EXISTS app.fn_ot_arbol_jerarquia(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid);
DROP FUNCTION IF EXISTS app.fn_organizacion_arbol(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS app.fn_notificacion_pendientes_correo(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_limite integer);
DROP FUNCTION IF EXISTS app.fn_notificacion_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solo_no_leidas boolean, p_limite integer);
DROP FUNCTION IF EXISTS app.fn_kpis(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb);
DROP FUNCTION IF EXISTS app.fn_diagnostico_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid);
DROP FUNCTION IF EXISTS app.fn_dashboard_solicitante(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS app.fn_dashboard_coordinador(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS app.fn_cotizacion_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid);
DROP FUNCTION IF EXISTS app.fn_costo_historico(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb);
DROP FUNCTION IF EXISTS app.fn_configuracion_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean);
DROP FUNCTION IF EXISTS app.fn_catalogo_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_tipo text);
DROP FUNCTION IF EXISTS app.fn_auth_perfil(p_user_id uuid);
DROP FUNCTION IF EXISTS app.fn_auditoria_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb, p_page integer, p_page_size integer);
DROP FUNCTION IF EXISTS app.fn_area_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb);
DROP FUNCTION IF EXISTS app.fn_administrativo_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid);
DROP FUNCTION IF EXISTS app.fn_adjunto_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_adjunto_id uuid);
DROP FUNCTION IF EXISTS app.fn_adjunto_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_entidad_tipo text, p_entidad_id uuid, p_ot_id uuid);
DROP TYPE IF EXISTS core.visibilidad_mensaje;
DROP TYPE IF EXISTS core.tipo_mensaje;
DROP TYPE IF EXISTS core.tipo_decision_solicitud;
DROP TYPE IF EXISTS core.tipo_catalogo;
DROP TYPE IF EXISTS core.tipo_adjunto;
DROP TYPE IF EXISTS core.solped_estado_integracion;
DROP TYPE IF EXISTS core.solicitud_estado;
DROP TYPE IF EXISTS core.scope_rol;
DROP TYPE IF EXISTS core.resultado_revision;
DROP TYPE IF EXISTS core.prioridad;
DROP TYPE IF EXISTS core.ot_estado;
DROP TYPE IF EXISTS core.ot_condicion;
DROP TYPE IF EXISTS core.moneda_codigo;
DROP TYPE IF EXISTS core.fuente_costo;
DROP TYPE IF EXISTS core.etapa_adjunto;
DROP TYPE IF EXISTS core.estado_validacion_costo;
DROP TYPE IF EXISTS core.estado_usuario;
DROP TYPE IF EXISTS core.estado_registro;
DROP TYPE IF EXISTS core.estado_notificacion;
DROP TYPE IF EXISTS core.estado_mensaje;
DROP TYPE IF EXISTS core.estado_liberacion;
DROP TYPE IF EXISTS core.estado_administrativo;
DROP TYPE IF EXISTS core.estado_adjunto;
DROP TYPE IF EXISTS core.dominio_evento;
DROP TYPE IF EXISTS core.conformidad_solicitante;
DROP TYPE IF EXISTS core.concepto_costo;
DROP TYPE IF EXISTS core.canal_notificacion;
DROP EXTENSION IF EXISTS unaccent;
DROP EXTENSION IF EXISTS pgcrypto;
DROP EXTENSION IF EXISTS pg_trgm;
DROP EXTENSION IF EXISTS btree_gin;
DROP SCHEMA IF EXISTS internal;
DROP SCHEMA IF EXISTS core;
DROP SCHEMA IF EXISTS audit;
DROP SCHEMA IF EXISTS app;
--
-- Name: app; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app;


--
-- Name: SCHEMA app; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA app IS 'Stored procedures y funciones públicas. Única superficie expuesta al backend.';


--
-- Name: audit; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA audit;


--
-- Name: SCHEMA audit; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA audit IS 'Auditoría y bitácoras de retención larga.';


--
-- Name: core; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA core;


--
-- Name: SCHEMA core; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA core IS 'Tablas, ENUMs y triggers. NUNCA accedido directamente por el backend.';


--
-- Name: internal; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA internal;


--
-- Name: SCHEMA internal; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA internal IS 'Helpers privados SECURITY DEFINER. Sin EXECUTE para el rol de aplicación.';


--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: canal_notificacion; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.canal_notificacion AS ENUM (
    'interno',
    'correo'
);


--
-- Name: concepto_costo; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.concepto_costo AS ENUM (
    'material',
    'repuesto',
    'servicio',
    'trabajo_integral'
);


--
-- Name: conformidad_solicitante; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.conformidad_solicitante AS ENUM (
    'conforme',
    'no_conforme',
    'sin_pronunciarse'
);


--
-- Name: dominio_evento; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.dominio_evento AS ENUM (
    'solicitud',
    'ot',
    'diagnostico',
    'cotizacion',
    'ejecucion',
    'administracion',
    'seguridad',
    'configuracion',
    'costos'
);


--
-- Name: estado_adjunto; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.estado_adjunto AS ENUM (
    'vigente',
    'reemplazado',
    'retirado'
);


--
-- Name: estado_administrativo; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.estado_administrativo AS ENUM (
    'sin_solped',
    'solped_pendiente',
    'solped_creada',
    'oc_pendiente',
    'oc_registrada',
    'liberacion_pendiente',
    'liberacion_parcial',
    'liberacion_total',
    'administracion_completa'
);


--
-- Name: estado_liberacion; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.estado_liberacion AS ENUM (
    'pendiente',
    'parcial',
    'total'
);


--
-- Name: estado_mensaje; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.estado_mensaje AS ENUM (
    'publicado',
    'editado',
    'retirado'
);


--
-- Name: estado_notificacion; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.estado_notificacion AS ENUM (
    'pendiente',
    'enviada',
    'leida',
    'fallida'
);


--
-- Name: estado_registro; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.estado_registro AS ENUM (
    'activo',
    'inactivo'
);


--
-- Name: estado_usuario; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.estado_usuario AS ENUM (
    'activo',
    'inactivo',
    'bloqueado'
);


--
-- Name: estado_validacion_costo; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.estado_validacion_costo AS ENUM (
    'sin_validar',
    'validado',
    'en_revision',
    'excepcion'
);


--
-- Name: etapa_adjunto; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.etapa_adjunto AS ENUM (
    'solicitud',
    'diagnostico',
    'cotizacion',
    'ejecucion',
    'incidencia',
    'trabajo_realizado',
    'cierre',
    'administrativo',
    'mensaje',
    'otro'
);


--
-- Name: fuente_costo; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.fuente_costo AS ENUM (
    'cotizacion',
    'ot_cerrada',
    'documento_administrativo',
    'carga_validada'
);


--
-- Name: moneda_codigo; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.moneda_codigo AS ENUM (
    'PEN',
    'USD',
    'EUR'
);


--
-- Name: ot_condicion; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.ot_condicion AS ENUM (
    'activa',
    'pausada'
);


--
-- Name: ot_estado; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.ot_estado AS ENUM (
    'creada',
    'en_diagnostico',
    'en_cotizacion',
    'en_trabajo',
    'trabajo_realizado',
    'cerrada',
    'cancelada'
);


--
-- Name: prioridad; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.prioridad AS ENUM (
    'critica',
    'alta',
    'media',
    'baja'
);


--
-- Name: resultado_revision; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.resultado_revision AS ENUM (
    'aprobado',
    'correccion_solicitada',
    'derivada_creada'
);


--
-- Name: scope_rol; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.scope_rol AS ENUM (
    'tenant',
    'global',
    'global_restricted'
);


--
-- Name: solicitud_estado; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.solicitud_estado AS ENUM (
    'borrador',
    'enviada',
    'en_revision',
    'observada',
    'aceptada',
    'rechazada',
    'derivada',
    'duplicada',
    'convertida_en_ot'
);


--
-- Name: solped_estado_integracion; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.solped_estado_integracion AS ENUM (
    'borrador',
    'lista_para_enviar',
    'enviando_a_sap',
    'confirmacion_pendiente',
    'creada_en_sap',
    'error_sap',
    'reemplazada_anulada'
);


--
-- Name: tipo_adjunto; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.tipo_adjunto AS ENUM (
    'pdf',
    'imagen',
    'video',
    'documento',
    'otro'
);


--
-- Name: tipo_catalogo; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.tipo_catalogo AS ENUM (
    'tipo_mantenimiento',
    'tipo_trabajo',
    'impacto_operativo',
    'motivo_cancelacion',
    'motivo_reapertura',
    'motivo_pausa',
    'tipo_incidencia',
    'motivo_rechazo',
    'motivo_reemplazo_cotizacion',
    'motivo_derivacion',
    'resultado_trabajo'
);


--
-- Name: tipo_decision_solicitud; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.tipo_decision_solicitud AS ENUM (
    'aceptar',
    'observar',
    'rechazar',
    'derivar',
    'marcar_duplicada',
    'tomar_revision',
    'reenviar'
);


--
-- Name: tipo_mensaje; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.tipo_mensaje AS ENUM (
    'humano',
    'sistema'
);


--
-- Name: visibilidad_mensaje; Type: TYPE; Schema: core; Owner: -
--

CREATE TYPE core.visibilidad_mensaje AS ENUM (
    'canal',
    'interna'
);


--
-- Name: fn_adjunto_listar(uuid, uuid, boolean, text, uuid, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_adjunto_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_entidad_tipo text DEFAULT NULL::text, p_entidad_id uuid DEFAULT NULL::uuid, p_ot_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', a.id, 'nombre', a.nombre, 'tipo', a.tipo, 'etapa', a.etapa,
           'mime', a.mime_type, 'tamano', a.tamano_bytes, 'storage_key', a.storage_key,
           'estado', a.estado, 'entidad_tipo', a.entidad_tipo, 'entidad_id', a.entidad_id,
           'autor', u.nombres||' '||u.apellidos, 'fecha', a.created_at
         ) ORDER BY a.created_at DESC), '[]'::jsonb) INTO v
  FROM core.adjunto a LEFT JOIN core.usuario u ON u.id = a.autor_id
  WHERE a.tenant_id = p_tenant_id AND a.estado = 'vigente'
    AND (p_ot_id IS NULL OR a.ot_id = p_ot_id)
    AND (p_entidad_tipo IS NULL OR a.entidad_tipo = p_entidad_tipo)
    AND (p_entidad_id IS NULL OR a.entidad_id = p_entidad_id);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_adjunto_obtener(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_adjunto_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_adjunto_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v core.adjunto%ROWTYPE;
  o core.orden_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT * INTO v FROM core.adjunto
   WHERE id = p_adjunto_id
     AND estado = 'vigente'
     AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Adjunto no encontrado'));
  END IF;

  -- Si cuelga de una OT, el alcance organizacional manda igual que en el resto
  -- del expediente: ver el archivo es ver la OT.
  IF v.ot_id IS NOT NULL THEN
    o := internal.ot_visible(v.ot_id, p_user_id, p_tenant_id, p_is_super_admin);
    IF o.id IS NULL THEN
      RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Adjunto no encontrado'));
    END IF;
    PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'nombre', v.nombre, 'mime', v.mime_type,
    'tamano', v.tamano_bytes, 'storage_key', v.storage_key));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_administrativo_obtener(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_administrativo_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:ver');
  RETURN jsonb_build_object('ok', true, 'data', internal.fn_ot_administrativo(p_ot_id));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_area_listar(uuid, uuid, boolean, jsonb); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_area_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB; v_global BOOLEAN; v_empresa TEXT := p_filtros->>'empresa_ruc_id';
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', a.id, 'codigo', a.codigo, 'nombre', a.nombre, 'estado', a.estado,
           'empresa_ruc_id', a.empresa_ruc_id,
           'empresa_ruc', e.razon_social, 'ruc', e.ruc,
           'empresa_activa', e.estado = 'activo'
         ) ORDER BY e.razon_social, a.nombre), '[]'::jsonb) INTO v
  FROM core.area a
  JOIN core.empresa_ruc e ON e.id = a.empresa_ruc_id
  WHERE a.deleted_at IS NULL
    AND (v_global OR a.tenant_id = p_tenant_id)
    AND (v_empresa IS NULL OR a.empresa_ruc_id = v_empresa::uuid)
    AND (v_global
         OR NOT EXISTS (SELECT 1 FROM core.usuario_alcance ua WHERE ua.usuario_id = p_user_id)
         OR EXISTS (SELECT 1 FROM core.usuario_alcance ua
                     WHERE ua.usuario_id = p_user_id
                       AND (ua.area_id IS NULL OR ua.area_id = a.id)
                       AND (ua.empresa_ruc_id IS NULL OR ua.empresa_ruc_id = a.empresa_ruc_id)));

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_auditoria_listar(uuid, uuid, boolean, jsonb, integer, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_auditoria_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb, p_page integer DEFAULT 1, p_page_size integer DEFAULT 50) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'audit', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,50),1),200);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1)*v_size;
  v_total INT; v_data JSONB;
  v_entidad TEXT := p_filtros->>'entidad';
  v_entidad_id TEXT := p_filtros->>'entidad_id';
  v_actor   TEXT := p_filtros->>'actor_id';
  v_accion  TEXT := p_filtros->>'accion';
  v_desde   TEXT := p_filtros->>'desde';
  v_hasta   TEXT := p_filtros->>'hasta';
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  -- Consulta restringida: exige permiso explícito (cap. 33).
  PERFORM internal.assert_permiso(p_user_id, 'auditoria:ver');

  SELECT count(*) INTO v_total FROM audit.audit_log a
   WHERE a.tenant_id = p_tenant_id
     AND (v_entidad    IS NULL OR a.entidad = v_entidad)
     AND (v_entidad_id IS NULL OR a.entidad_id = v_entidad_id::uuid)
     AND (v_actor      IS NULL OR a.actor_id = v_actor::uuid)
     AND (v_accion     IS NULL OR a.accion = v_accion)
     AND (v_desde      IS NULL OR a.created_at >= v_desde::timestamptz)
     AND (v_hasta      IS NULL OR a.created_at < (v_hasta::date + 1)::timestamptz);

  SELECT coalesce(jsonb_agg(x ORDER BY (x->>'fecha') DESC), '[]'::jsonb) INTO v_data FROM (
    SELECT jsonb_build_object(
      'id', a.id, 'accion', a.accion, 'entidad', a.entidad, 'entidad_id', a.entidad_id,
      'actor', u.nombres||' '||u.apellidos, 'actor_id', a.actor_id,
      'diff', a.diff, 'motivo', a.motivo,
      'request_id', a.request_id, 'fecha', a.created_at) AS x
      FROM audit.audit_log a LEFT JOIN core.usuario u ON u.id = a.actor_id
     WHERE a.tenant_id = p_tenant_id
       AND (v_entidad    IS NULL OR a.entidad = v_entidad)
       AND (v_entidad_id IS NULL OR a.entidad_id = v_entidad_id::uuid)
       AND (v_actor      IS NULL OR a.actor_id = v_actor::uuid)
       AND (v_accion     IS NULL OR a.accion = v_accion)
       AND (v_desde      IS NULL OR a.created_at >= v_desde::timestamptz)
       AND (v_hasta      IS NULL OR a.created_at < (v_hasta::date + 1)::timestamptz)
     ORDER BY a.created_at DESC
     LIMIT v_size OFFSET v_off
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_auth_perfil(uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_auth_perfil(p_user_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  SELECT jsonb_build_object(
    'id', u.id, 'email', u.email,
    'nombres', u.nombres, 'apellidos', u.apellidos,
    'nombre', u.nombres || ' ' || u.apellidos,
    'cargo', u.cargo, 'telefono', u.telefono,
    'tenant_id', u.tenant_id,
    'tenant', (SELECT jsonb_build_object('id', t.id, 'nombre', t.nombre,
                                         'zona_horaria', t.zona_horaria,
                                         'moneda_base', t.moneda_base)
                 FROM core.tenant t WHERE t.id = u.tenant_id),
    'is_super_admin', u.is_super_admin,
    'estado', u.estado,
    'preferencias', u.preferencias,
    'roles', coalesce((SELECT jsonb_agg(r.codigo ORDER BY r.codigo)
                         FROM core.usuario_rol ur JOIN core.rol r ON r.id = ur.rol_id
                        WHERE ur.usuario_id = u.id), '[]'::jsonb),
    'permisos', coalesce((SELECT jsonb_agg(DISTINCT p.codigo)
                            FROM core.usuario_rol ur
                            JOIN core.rol_permiso rp ON rp.rol_id = ur.rol_id
                            JOIN core.permiso p      ON p.id = rp.permiso_id
                           WHERE ur.usuario_id = u.id), '[]'::jsonb),
    'acceso_global', internal.es_acceso_global(u.id, u.is_super_admin),
    -- El alcance viaja al frontend para poder filtrar selectores sin ida y vuelta.
    'alcance', coalesce((SELECT jsonb_agg(jsonb_build_object(
                            'sucursal_id', a.sucursal_id, 'empresa_ruc_id', a.empresa_ruc_id,
                            'area_id', a.area_id))
                           FROM core.usuario_alcance a WHERE a.usuario_id = u.id), '[]'::jsonb)
  ) INTO v
  FROM core.usuario u
  WHERE u.id = p_user_id AND u.deleted_at IS NULL;

  IF v IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Usuario no encontrado'));
  END IF;
  RETURN jsonb_build_object('ok', true, 'data', v);
END; $$;


--
-- Name: fn_catalogo_listar(uuid, uuid, boolean, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_catalogo_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_tipo text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_object_agg(tipo, items), '{}'::jsonb) INTO v FROM (
    SELECT c.tipo::text AS tipo,
           jsonb_agg(jsonb_build_object(
             'id', c.id, 'codigo', c.codigo, 'nombre', c.nombre,
             'descripcion', c.descripcion, 'orden', c.orden,
             'requiere_comentario', c.requiere_comentario,
             'es_base', c.tenant_id IS NULL) ORDER BY c.orden, c.nombre) AS items
      FROM core.catalogo_item c
     WHERE c.deleted_at IS NULL AND c.estado = 'activo'
       AND (c.tenant_id = p_tenant_id OR c.tenant_id IS NULL)
       AND (p_tipo IS NULL OR c.tipo::text = p_tipo)
     GROUP BY c.tipo
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_configuracion_obtener(uuid, uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_configuracion_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
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


--
-- Name: fn_costo_historico(uuid, uuid, boolean, jsonb); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_costo_historico(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_umbral INT;
  v JSONB;
  v_tipo     TEXT := p_filtros->>'tipo_trabajo_id';
  v_empresa  TEXT := p_filtros->>'empresa_ruc_id';
  v_sucursal TEXT := p_filtros->>'sucursal_id';
  v_area     TEXT := p_filtros->>'area_id';
  v_prov     TEXT := p_filtros->>'proveedor_id';
  v_moneda   TEXT := coalesce(p_filtros->>'moneda','PEN');
  v_desde    TEXT := p_filtros->>'desde';
  v_hasta    TEXT := p_filtros->>'hasta';
  v_outliers BOOLEAN := coalesce((p_filtros->>'incluir_outliers')::boolean, false);
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'costos:ver');

  -- Umbral configurable por tenant: por debajo no se publica promedio (cap. 32.4).
  v_umbral := coalesce((internal.config(p_tenant_id,'umbral_muestra_costos')->>'minimo')::int, 3);

  WITH comparables AS (
    SELECT cu.*
      FROM core.costo_unitario cu
     WHERE cu.tenant_id = p_tenant_id
       AND cu.es_comparable = true
       AND cu.moneda::text = v_moneda
       AND (v_outliers OR cu.es_outlier = false)
       AND (v_tipo     IS NULL OR cu.tipo_trabajo_id = v_tipo::uuid)
       AND (v_empresa  IS NULL OR cu.empresa_ruc_id = v_empresa::uuid)
       AND (v_sucursal IS NULL OR cu.sucursal_id = v_sucursal::uuid)
       AND (v_area     IS NULL OR cu.area_id = v_area::uuid)
       AND (v_prov     IS NULL OR cu.proveedor_id = v_prov::uuid)
       AND (v_desde    IS NULL OR cu.fecha_referencia >= v_desde::date)
       AND (v_hasta    IS NULL OR cu.fecha_referencia <= v_hasta::date)
  ),
  conteo AS (SELECT count(*)::int AS casos FROM comparables)
  SELECT jsonb_build_object(
    'ultimo_costo', (
      SELECT jsonb_build_object(
               'id', cu.id, 'monto', cu.monto_total, 'costo_unitario', cu.costo_unitario,
               'moneda', cu.moneda, 'fecha', cu.fecha_referencia,
               'proveedor', pr.razon_social, 'fuente', cu.fuente,
               'texto_original', cu.texto_original, 'ot', o.numero_ot)
        FROM comparables cu
        LEFT JOIN core.proveedor pr    ON pr.id = cu.proveedor_id
        LEFT JOIN core.orden_trabajo o ON o.id = cu.ot_id
       ORDER BY cu.fecha_referencia DESC NULLS LAST, cu.created_at DESC
       LIMIT 1),

    -- Promedio y rango SÓLO con muestra suficiente. Si no, se explica por qué:
    -- mostrar "promedio" sobre un caso es falsa precisión (cap. 32.4).
    'estadisticas', CASE
      WHEN (SELECT casos FROM conteo) >= v_umbral THEN (
        SELECT jsonb_build_object(
          'promedio',  round(avg(monto_total)::numeric, 2),
          'minimo',    min(monto_total),
          'maximo',    max(monto_total),
          'mediana',   round((percentile_cont(0.5) WITHIN GROUP (ORDER BY monto_total))::numeric, 2),
          'promedio_unitario', round(avg(costo_unitario)::numeric, 4))
          FROM comparables)
      ELSE jsonb_build_object(
        'promedio', NULL,
        'motivo_sin_promedio',
          format('La muestra tiene %s caso(s) y el umbral configurado es %s. Un promedio con menos casos sería falsa precisión.',
                 (SELECT casos FROM conteo), v_umbral))
      END,

    'registros', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', cu.id, 'texto_original', cu.texto_original,
               'descripcion_normalizada', dn.etiqueta,
               'monto', cu.monto_total, 'costo_unitario', cu.costo_unitario,
               'cantidad', cu.cantidad, 'unidad', cu.unidad, 'moneda', cu.moneda,
               'fecha', cu.fecha_referencia, 'proveedor', pr.razon_social,
               'ot', o.numero_ot, 'fuente', cu.fuente,
               'emergencia', cu.fue_emergencia, 'es_outlier', cu.es_outlier)
             ORDER BY cu.fecha_referencia DESC NULLS LAST)
        FROM comparables cu
        LEFT JOIN core.descripcion_normalizada dn ON dn.id = cu.descripcion_normalizada_id
        LEFT JOIN core.proveedor pr               ON pr.id = cu.proveedor_id
        LEFT JOIN core.orden_trabajo o            ON o.id = cu.ot_id), '[]'::jsonb),

    -- Contexto obligatorio de presentación (cap. 32.4): sin esto los números mienten.
    'contexto', jsonb_build_object(
      'casos', (SELECT casos FROM conteo),
      'umbral_minimo', v_umbral,
      'moneda', v_moneda,
      'outliers_incluidos', v_outliers,
      'filtros', p_filtros,
      'advertencia', 'Costo observado y cotizado. NO es un costo contable final: MIP no tiene integración contable definida.')
  ) INTO v;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_cotizacion_listar(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_cotizacion_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'cotizaciones:ver');
  RETURN jsonb_build_object('ok', true, 'data', internal.fn_ot_cotizaciones(p_ot_id));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_dashboard_coordinador(uuid, uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_dashboard_coordinador(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_global BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(

    -- Bloque 1 · Solicitudes pendientes de primera revisión, ordenadas por
    -- prioridad percibida y antigüedad. Acción: abrir, tomar, decidir o derivar.
    'solicitudes_nuevas', jsonb_build_object(
      'total', (SELECT count(*) FROM core.solicitud_trabajo s
                 WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL
                   AND s.estado IN ('enviada','en_revision')),
      'items', coalesce((SELECT jsonb_agg(jsonb_build_object(
                  'id', s.id, 'numero', s.numero, 'titulo', s.titulo,
                  'prioridad_percibida', s.prioridad_percibida,
                  'area', ar.nombre, 'estado', s.estado,
                  'horas_espera', round(extract(epoch FROM (now() - s.fecha_envio))/3600.0, 1))
                  ORDER BY s.prioridad_percibida NULLS LAST, s.fecha_envio)
                FROM core.solicitud_trabajo s LEFT JOIN core.area ar ON ar.id = s.area_id
               WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL
                 AND s.estado IN ('enviada','en_revision')), '[]'::jsonb)),

    -- Bloque 2 · OT sin diagnóstico vigente completo. Acción: completar o asignar técnico.
    'sin_diagnostico', jsonb_build_object(
      'total', (SELECT count(*) FROM core.orden_trabajo o
                 WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
                   AND o.estado IN ('creada','en_diagnostico')
                   AND NOT EXISTS (SELECT 1 FROM core.diagnostico d WHERE d.ot_id=o.id AND d.vigente)),
      'items', coalesce((SELECT jsonb_agg(jsonb_build_object(
                  'id', o.id, 'numero_ot', o.numero_ot, 'estado', o.estado,
                  'prioridad', o.prioridad_tecnica, 'es_emergencia', o.es_emergencia,
                  'dias_abierta', round(extract(epoch FROM (now() - o.fecha_creacion))/86400.0, 1))
                  ORDER BY o.prioridad_tecnica NULLS LAST, o.fecha_creacion)
                FROM core.orden_trabajo o
               WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
                 AND o.estado IN ('creada','en_diagnostico')
                 AND NOT EXISTS (SELECT 1 FROM core.diagnostico d WHERE d.ot_id=o.id AND d.vigente)), '[]'::jsonb)),

    -- Bloque 3 · En cotización sin PDF vigente, o con el plazo ofrecido vencido.
    'cotizacion_pendiente', jsonb_build_object(
      'total', (SELECT count(*) FROM core.orden_trabajo o
                 WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
                   AND o.estado = 'en_cotizacion'
                   AND NOT EXISTS (SELECT 1 FROM core.cotizacion c
                                    WHERE c.ot_id=o.id AND c.vigente AND NOT c.invalidada)),
      'plazo_vencido', (SELECT count(*) FROM core.orden_trabajo o
                          JOIN core.cotizacion c ON c.ot_id = o.id AND c.vigente AND NOT c.invalidada
                         WHERE o.tenant_id = p_tenant_id AND o.estado = 'en_cotizacion'
                           AND c.plazo_ofrecido_dias IS NOT NULL
                           AND c.fecha_cotizacion + c.plazo_ofrecido_dias < current_date)),

    -- Bloque 4 · Ejecución: en trabajo, pausadas, sin avance reciente y emergencias.
    'ejecucion', jsonb_build_object(
      'en_trabajo', (SELECT count(*) FROM core.orden_trabajo
                      WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND estado='en_trabajo'),
      'pausadas',   (SELECT count(*) FROM core.orden_trabajo
                      WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND condicion='pausada'),
      'emergencias_activas', (SELECT count(*) FROM core.orden_trabajo
                               WHERE tenant_id=p_tenant_id AND deleted_at IS NULL
                                 AND es_emergencia AND estado NOT IN ('cerrada','cancelada')),
      'regularizacion_pendiente', (SELECT count(*) FROM core.orden_trabajo
                                    WHERE tenant_id=p_tenant_id AND deleted_at IS NULL
                                      AND regularizacion_pendiente AND estado NOT IN ('cancelada')),
      'sin_avance_7d', (SELECT count(*) FROM core.orden_trabajo o
                         WHERE o.tenant_id=p_tenant_id AND o.deleted_at IS NULL AND o.estado='en_trabajo'
                           AND NOT EXISTS (SELECT 1 FROM core.ot_avance a
                                            WHERE a.ot_id=o.id AND a.created_at > now() - interval '7 days'))),

    -- Bloque 5 · Trabajo realizado esperando revisión del coordinador.
    'revision_final', jsonb_build_object(
      'total', (SELECT count(*) FROM core.orden_trabajo
                 WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND estado='trabajo_realizado'),
      'items', coalesce((SELECT jsonb_agg(jsonb_build_object(
                  'id', o.id, 'numero_ot', o.numero_ot,
                  'declarado_at', t.created_at,
                  'declarado_por', u.nombres||' '||u.apellidos)
                  ORDER BY t.created_at)
                FROM core.orden_trabajo o
                JOIN core.trabajo_realizado t ON t.ot_id=o.id AND t.vigente
                LEFT JOIN core.usuario u ON u.id = t.declarado_por
               WHERE o.tenant_id=p_tenant_id AND o.deleted_at IS NULL
                 AND o.estado='trabajo_realizado'), '[]'::jsonb)),

    -- Bloque 6 · Cerradas con pendiente administrativo. Acción: registrar el
    -- seguimiento SIN reabrir la OT (cap. 35.1, QA-20).
    'administracion_pendiente', jsonb_build_object(
      'total', (SELECT count(*) FROM core.orden_trabajo
                 WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND estado='cerrada'
                   AND estado_administrativo <> 'administracion_completa'),
      'por_estado', coalesce((SELECT jsonb_object_agg(estado_administrativo, n) FROM (
                      SELECT estado_administrativo, count(*) AS n FROM core.orden_trabajo
                       WHERE tenant_id=p_tenant_id AND deleted_at IS NULL AND estado='cerrada'
                         AND estado_administrativo <> 'administracion_completa'
                       GROUP BY 1) z), '{}'::jsonb)),

    -- Bloque 7 · Jerarquías bloqueadas: padres que no pueden cerrar (cap. 27.3).
    'bloqueos_cierre', coalesce((SELECT jsonb_agg(jsonb_build_object(
        'id', o.id, 'numero_ot', o.numero_ot,
        'derivadas_bloqueantes', (SELECT count(*) FROM core.orden_trabajo h
                                   WHERE h.ot_padre_id=o.id AND h.deleted_at IS NULL
                                     AND h.es_bloqueante_para_padre
                                     AND h.estado NOT IN ('cerrada','cancelada'))))
      FROM core.orden_trabajo o
     WHERE o.tenant_id=p_tenant_id AND o.deleted_at IS NULL
       AND o.estado = 'trabajo_realizado'
       AND EXISTS (SELECT 1 FROM core.orden_trabajo h
                    WHERE h.ot_padre_id=o.id AND h.deleted_at IS NULL
                      AND h.es_bloqueante_para_padre
                      AND h.estado NOT IN ('cerrada','cancelada'))), '[]'::jsonb)
  ));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_dashboard_solicitante(uuid, uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_dashboard_solicitante(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'resumen', (SELECT jsonb_object_agg(estado, n) FROM (
                  SELECT estado::text, count(*) AS n FROM core.solicitud_trabajo
                   WHERE solicitante_id = p_user_id AND deleted_at IS NULL GROUP BY 1) z),
    'solicitudes', coalesce((SELECT jsonb_agg(jsonb_build_object(
        'id', s.id, 'numero', s.numero, 'titulo', s.titulo, 'estado', s.estado,
        'fecha', s.created_at, 'observacion', s.observacion_actual,
        'ot', (SELECT jsonb_build_object('numero', o.numero_ot, 'estado', o.estado)
                 FROM core.orden_trabajo o WHERE o.solicitud_origen_id = s.id))
        ORDER BY s.created_at DESC)
      FROM core.solicitud_trabajo s
     WHERE s.solicitante_id = p_user_id AND s.deleted_at IS NULL), '[]'::jsonb),
    'no_leidas', (SELECT count(*) FROM core.notificacion
                   WHERE destinatario_id = p_user_id AND leida_at IS NULL)));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_diagnostico_listar(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_diagnostico_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  RETURN jsonb_build_object('ok', true, 'data', internal.fn_ot_diagnosticos(p_ot_id));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_kpis(uuid, uuid, boolean, jsonb); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_kpis(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_desde DATE := coalesce((p_filtros->>'desde')::date, current_date - 90);
  v_hasta DATE := coalesce((p_filtros->>'hasta')::date, current_date);
  v_suc   TEXT := p_filtros->>'sucursal_id';
  v_emp   TEXT := p_filtros->>'empresa_ruc_id';
  v_area  TEXT := p_filtros->>'area_id';
  v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'reportes:ver');

  WITH ot_periodo AS (
    SELECT o.* FROM core.orden_trabajo o
     WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
       AND o.fecha_creacion::date BETWEEN v_desde AND v_hasta
       AND (v_suc  IS NULL OR o.sucursal_id = v_suc::uuid)
       AND (v_emp  IS NULL OR o.empresa_ruc_id = v_emp::uuid)
       AND (v_area IS NULL OR o.area_id = v_area::uuid)
  ),
  sol_periodo AS (
    SELECT s.* FROM core.solicitud_trabajo s
     WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL
       AND s.estado <> 'borrador'
       AND s.created_at::date BETWEEN v_desde AND v_hasta
  )
  SELECT jsonb_build_object(
    'periodo', jsonb_build_object('desde', v_desde, 'hasta', v_hasta),

    'solicitudes', (SELECT jsonb_build_object(
        'creadas',    count(*),
        'atendidas',  count(*) FILTER (WHERE estado = 'convertida_en_ot'),
        'observadas', count(*) FILTER (WHERE estado = 'observada'),
        'rechazadas', count(*) FILTER (WHERE estado = 'rechazada'),
        -- Tiempo de primera revisión = primera decisión − envío, sin borradores.
        'horas_primera_revision_promedio',
          round(avg(extract(epoch FROM (fecha_primera_revision - fecha_envio))/3600.0)
                FILTER (WHERE fecha_primera_revision IS NOT NULL)::numeric, 1))
      FROM sol_periodo),

    'ot', (SELECT jsonb_build_object(
        'total',      count(*),
        'abiertas',   count(*) FILTER (WHERE estado NOT IN ('cerrada','cancelada')),
        'cerradas',   count(*) FILTER (WHERE estado = 'cerrada'),
        'canceladas', count(*) FILTER (WHERE estado = 'cancelada'),
        'derivadas',  count(*) FILTER (WHERE ot_padre_id IS NOT NULL),
        'reabiertas', count(*) FILTER (WHERE veces_reabierta > 0),
        'por_estado', (SELECT coalesce(jsonb_object_agg(e, n), '{}'::jsonb) FROM (
                        SELECT estado::text e, count(*) n FROM ot_periodo GROUP BY 1) z),
        'por_prioridad', (SELECT coalesce(jsonb_object_agg(coalesce(pr,'sin_prioridad'), n), '{}'::jsonb) FROM (
                        SELECT prioridad_tecnica::text pr, count(*) n FROM ot_periodo GROUP BY 1) z))
      FROM ot_periodo),

    -- Duración = término real − inicio real, en días calendario. Las pausas se
    -- reportan por separado, nunca descontadas en silencio (cap. 35.2).
    'duracion', (SELECT jsonb_build_object(
        'dias_promedio', round(avg(extract(epoch FROM (o.fecha_termino_real - o.fecha_inicio_real))/86400.0)::numeric, 2),
        'casos', count(*),
        'horas_pausa_promedio', round(coalesce(avg((
            SELECT sum(extract(epoch FROM (pa.fecha_reanudacion - pa.fecha_pausa))/3600.0)
              FROM core.ot_pausa pa WHERE pa.ot_id = o.id AND pa.fecha_reanudacion IS NOT NULL)),0)::numeric, 1))
      FROM ot_periodo o
     WHERE o.fecha_inicio_real IS NOT NULL AND o.fecha_termino_real IS NOT NULL),

    'emergencias', (SELECT jsonb_build_object(
        'cantidad', count(*) FILTER (WHERE es_emergencia),
        'porcentaje', CASE WHEN count(*) = 0 THEN 0
                           ELSE round(100.0 * count(*) FILTER (WHERE es_emergencia) / count(*), 1) END,
        'regularizacion_pendiente', count(*) FILTER (WHERE regularizacion_pendiente))
      FROM ot_periodo),

    -- Cerrar con pendiente administrativo NO implica incumplimiento técnico
    -- (cap. 35.2). El KPI lo dice explícitamente para evitar malas lecturas.
    'cierre_con_pendiente', (SELECT jsonb_build_object(
        'total', count(*) FILTER (WHERE estado='cerrada' AND estado_administrativo <> 'administracion_completa'),
        'oc_pendiente', count(*) FILTER (WHERE estado='cerrada' AND estado_administrativo='oc_pendiente'),
        'liberacion_pendiente', count(*) FILTER (WHERE estado='cerrada' AND estado_administrativo='liberacion_pendiente'),
        'liberacion_parcial', count(*) FILTER (WHERE estado='cerrada' AND estado_administrativo='liberacion_parcial'),
        'nota','No implica incumplimiento técnico.')
      FROM ot_periodo),

    'costos', (SELECT jsonb_build_object(
        'ot_con_cotizacion', count(DISTINCT c.ot_id),
        'monto_cotizado_total', round(coalesce(sum(c.monto),0)::numeric, 2),
        'advertencia','Monto COTIZADO, no contable. Ver la regla de calidad del cap. 16.4.')
      FROM ot_periodo o
      JOIN core.cotizacion c ON c.ot_id = o.id AND c.vigente AND NOT c.invalidada)
  ) INTO v;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_notificacion_listar(uuid, uuid, boolean, boolean, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_notificacion_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solo_no_leidas boolean DEFAULT false, p_limite integer DEFAULT 50) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB; v_no_leidas INT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT count(*) INTO v_no_leidas FROM core.notificacion
   WHERE destinatario_id = p_user_id AND leida_at IS NULL;

  SELECT coalesce(jsonb_agg(x ORDER BY (x->>'fecha') DESC), '[]'::jsonb) INTO v FROM (
    SELECT jsonb_build_object(
      'id', n.id, 'evento', n.evento, 'titulo', n.titulo, 'cuerpo', n.cuerpo,
      'ot_id', n.ot_id, 'ot_numero', o.numero_ot,
      'entidad_tipo', n.entidad_tipo, 'entidad_id', n.entidad_id,
      'leida', n.leida_at IS NOT NULL, 'fecha', n.created_at) AS x
      FROM core.notificacion n
      LEFT JOIN core.orden_trabajo o ON o.id = n.ot_id
     WHERE n.destinatario_id = p_user_id
       AND (NOT p_solo_no_leidas OR n.leida_at IS NULL)
     ORDER BY n.created_at DESC
     LIMIT least(coalesce(p_limite,50), 200)
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v,
                            'meta', jsonb_build_object('no_leidas', v_no_leidas));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_notificacion_pendientes_correo(uuid, uuid, boolean, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_notificacion_pendientes_correo(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_limite integer DEFAULT 100) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', n.id, 'email', u.email,
           'nombre', u.nombres||' '||u.apellidos,
           'evento', n.evento, 'titulo', n.titulo, 'cuerpo', n.cuerpo,
           'ot_numero', o.numero_ot)), '[]'::jsonb) INTO v
  FROM core.notificacion n
  JOIN core.usuario u ON u.id = n.destinatario_id AND u.estado = 'activo'
  LEFT JOIN core.orden_trabajo o ON o.id = n.ot_id
  WHERE n.tenant_id = p_tenant_id AND n.estado = 'pendiente'
    -- Cada usuario puede ajustar sus preferencias; los eventos críticos pueden
    -- ser obligatorios por tenant (cap. 34.1).
    AND coalesce((u.preferencias->'correo'->>n.evento)::boolean, true)
  LIMIT least(coalesce(p_limite,100), 500);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_organizacion_arbol(uuid, uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_organizacion_arbol(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'id', s.id, 'codigo', s.codigo, 'nombre', s.nombre, 'estado', s.estado,
    'empresas', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
        'id', e.id, 'ruc', e.ruc, 'razon_social', e.razon_social, 'estado', e.estado,
        'areas', coalesce((
          SELECT jsonb_agg(jsonb_build_object('id', a.id, 'codigo', a.codigo,
                                              'nombre', a.nombre, 'estado', a.estado)
                 ORDER BY a.nombre)
            FROM core.area a WHERE a.empresa_ruc_id = e.id AND a.deleted_at IS NULL), '[]'::jsonb)
      ) ORDER BY e.razon_social)
        FROM core.sucursal_empresa_ruc se
        JOIN core.empresa_ruc e ON e.id = se.empresa_ruc_id AND e.deleted_at IS NULL
       WHERE se.sucursal_id = s.id), '[]'::jsonb)
  ) ORDER BY s.nombre), '[]'::jsonb) INTO v
  FROM core.sucursal s
  WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_ot_arbol_jerarquia(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_ot_arbol_jerarquia(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_raiz UUID; v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  -- Se sube hasta la raíz para poder mostrar la jerarquía COMPLETA aunque el
  -- usuario haya abierto una nieta.
  WITH RECURSIVE arriba AS (
    SELECT id, ot_padre_id, 0 AS salto FROM core.orden_trabajo WHERE id = p_ot_id
    UNION ALL
    SELECT o.id, o.ot_padre_id, a.salto+1
      FROM core.orden_trabajo o JOIN arriba a ON o.id = a.ot_padre_id
     WHERE a.salto < 100)
  SELECT id INTO v_raiz FROM arriba WHERE ot_padre_id IS NULL LIMIT 1;
  v_raiz := coalesce(v_raiz, p_ot_id);

  WITH RECURSIVE abajo AS (
    SELECT o.id, o.ot_padre_id, o.numero_ot, o.estado, o.condicion,
           o.estado_administrativo, o.prioridad_tecnica, o.es_emergencia,
           o.es_bloqueante_para_padre, o.independizada_de_padre, o.nivel, 0 AS profundidad
      FROM core.orden_trabajo o WHERE o.id = v_raiz AND o.deleted_at IS NULL
    UNION ALL
    SELECT h.id, h.ot_padre_id, h.numero_ot, h.estado, h.condicion,
           h.estado_administrativo, h.prioridad_tecnica, h.es_emergencia,
           h.es_bloqueante_para_padre, h.independizada_de_padre, h.nivel, ab.profundidad+1
      FROM core.orden_trabajo h JOIN abajo ab ON h.ot_padre_id = ab.id
     WHERE h.deleted_at IS NULL AND ab.profundidad < 20)
  SELECT jsonb_build_object(
    'raiz', v_raiz,
    'ot_consultada', p_ot_id,
    'nodos', coalesce(jsonb_agg(jsonb_build_object(
      'id', id, 'ot_padre_id', ot_padre_id, 'numero_ot', numero_ot,
      'estado', estado, 'condicion', condicion,
      'estado_administrativo', estado_administrativo,
      'prioridad', prioridad_tecnica, 'es_emergencia', es_emergencia,
      'es_bloqueante', es_bloqueante_para_padre,
      'independizada', independizada_de_padre,
      'nivel', nivel, 'es_actual', id = p_ot_id) ORDER BY nivel, numero_ot), '[]'::jsonb),
    'total', count(*),
    -- Lo que impide cerrar la raíz, listo para mostrarlo en la ficha (cap. 27.3).
    'bloqueantes_abiertas', count(*) FILTER (
      WHERE es_bloqueante_para_padre AND estado NOT IN ('cerrada','cancelada') AND ot_padre_id IS NOT NULL))
  INTO v FROM abajo;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_ot_consolidado(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_ot_consolidado(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB; v_ve_costos BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  v_ve_costos := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur JOIN core.rol_permiso rp ON rp.rol_id=ur.rol_id
      JOIN core.permiso p ON p.id=rp.permiso_id
     WHERE ur.usuario_id=p_user_id AND p.codigo='costos:ver');

  WITH RECURSIVE desc_ot AS (
    SELECT o.id, 0 AS profundidad FROM core.orden_trabajo o
     WHERE o.ot_padre_id = p_ot_id AND o.deleted_at IS NULL
    UNION ALL
    SELECT h.id, d.profundidad+1 FROM core.orden_trabajo h
      JOIN desc_ot d ON h.ot_padre_id = d.id
     WHERE h.deleted_at IS NULL AND d.profundidad < 20)
  SELECT jsonb_build_object(
    'total_descendientes', count(*),
    'por_estado', coalesce((SELECT jsonb_object_agg(e, n) FROM (
        SELECT o2.estado::text e, count(*) n FROM desc_ot d2
          JOIN core.orden_trabajo o2 ON o2.id = d2.id GROUP BY 1) z), '{}'::jsonb),
    'por_estado_administrativo', coalesce((SELECT jsonb_object_agg(e, n) FROM (
        SELECT o3.estado_administrativo::text e, count(*) n FROM desc_ot d3
          JOIN core.orden_trabajo o3 ON o3.id = d3.id GROUP BY 1) z), '{}'::jsonb),
    'bloquean_cierre', (SELECT count(*) FROM desc_ot d4
                          JOIN core.orden_trabajo o4 ON o4.id = d4.id
                         WHERE o4.es_bloqueante_para_padre
                           AND o4.estado NOT IN ('cerrada','cancelada')),
    -- El sum() va en una subconsulta propia: jsonb_agg(... sum() ...) sería un
    -- agregado dentro de otro, y Postgres no lo admite.
    'costo_cotizado_descendientes', CASE WHEN v_ve_costos THEN (
        SELECT coalesce(jsonb_agg(x), '[]'::jsonb) FROM (
          SELECT jsonb_build_object('moneda', c.moneda, 'total', sum(c.monto)) AS x
            FROM desc_ot d5
            JOIN core.cotizacion c ON c.ot_id = d5.id AND c.vigente AND NOT c.invalidada
           GROUP BY c.moneda) z) END,
    'nota','Consolidación informativa. No fusiona estados ni reescribe los historiales de las derivadas.')
  INTO v FROM desc_ot;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_ot_historial(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_ot_historial(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');
  RETURN jsonb_build_object('ok', true, 'data', internal.fn_ot_eventos(p_ot_id, 1000));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_ot_linea_tiempo(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_ot_linea_tiempo(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB; v_ve_internas BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  SELECT coalesce(bool_or(pp.ve_notas_internas), false) INTO v_ve_internas
    FROM core.conversacion_participante pp
    JOIN core.conversacion c ON c.id = pp.conversacion_id
   WHERE c.ot_id = p_ot_id AND pp.usuario_id = p_user_id;
  v_ve_internas := v_ve_internas OR p_is_super_admin;

  SELECT coalesce(jsonb_agg(x ORDER BY (x->>'fecha')), '[]'::jsonb) INTO v FROM (
    SELECT jsonb_build_object(
             'clase','mensaje', 'tipo', m.tipo, 'id', m.id,
             'cuerpo', CASE WHEN m.estado='retirado' THEN NULL ELSE m.cuerpo END,
             'visibilidad', m.visibilidad, 'estado', m.estado,
             'autor', u.nombres||' '||u.apellidos, 'fecha', m.created_at) AS x
      FROM core.mensaje m
      JOIN core.conversacion c ON c.id = m.conversacion_id
      LEFT JOIN core.usuario u ON u.id = m.autor_id
     WHERE c.ot_id = p_ot_id
       AND (v_ve_internas OR m.visibilidad <> 'interna')
    UNION ALL
    SELECT jsonb_build_object(
             'clase','evento', 'tipo','sistema', 'id', e.id::text,
             'dominio', e.dominio, 'evento', e.evento,
             'anterior', e.valor_anterior, 'nuevo', e.valor_nuevo, 'motivo', e.motivo,
             'autor', eu.nombres||' '||eu.apellidos, 'fecha', e.created_at) AS x
      FROM core.ot_evento e LEFT JOIN core.usuario eu ON eu.id = e.actor_id
     WHERE e.ot_id = p_ot_id
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_ot_listar(uuid, uuid, boolean, jsonb, integer, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_ot_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb, p_page integer DEFAULT 1, p_page_size integer DEFAULT 20) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,20),1),100);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1)*v_size;
  v_total INT; v_data JSONB; v_global BOOLEAN; v_ve_costos BOOLEAN;
  v_estado    TEXT := p_filtros->>'estado';
  v_admin     TEXT := p_filtros->>'estado_administrativo';
  v_sucursal  TEXT := p_filtros->>'sucursal_id';
  v_empresa   TEXT := p_filtros->>'empresa_ruc_id';
  v_area      TEXT := p_filtros->>'area_id';
  v_prioridad TEXT := p_filtros->>'prioridad_tecnica';
  v_tipo_trab TEXT := p_filtros->>'tipo_trabajo_id';
  v_resp      TEXT := p_filtros->>'responsable_id';
  v_desde     TEXT := p_filtros->>'desde';
  v_hasta     TEXT := p_filtros->>'hasta';
  v_emerg     BOOLEAN := (p_filtros->>'solo_emergencias')::boolean;
  v_solo_raiz BOOLEAN := coalesce((p_filtros->>'solo_principales')::boolean, false);
  v_padre     TEXT := p_filtros->>'ot_padre_id';
  v_buscar    TEXT := internal.normalizar_busqueda(p_filtros->>'buscar');
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:listar');
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  -- El solicitante no ve costos (cap. 13, QA-18): se decide una vez y se aplica
  -- al armar cada fila.
  v_ve_costos := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur
      JOIN core.rol_permiso rp ON rp.rol_id = ur.rol_id
      JOIN core.permiso p      ON p.id = rp.permiso_id
     WHERE ur.usuario_id = p_user_id AND p.codigo = 'costos:ver');

  -- Una sola sentencia con CTE, no una tabla temporal: una función STABLE no
  -- puede ejecutar CREATE TABLE, y además así el filtro se evalúa una vez y lo
  -- comparten el conteo y la página.
  WITH filtrado AS (
    SELECT o.id
      FROM core.orden_trabajo o
     WHERE o.deleted_at IS NULL
       AND (v_global OR o.tenant_id = p_tenant_id)
       AND (v_estado    IS NULL OR o.estado::text = v_estado)
       AND (v_admin     IS NULL OR o.estado_administrativo::text = v_admin)
       AND (v_sucursal  IS NULL OR o.sucursal_id = v_sucursal::uuid)
       AND (v_empresa   IS NULL OR o.empresa_ruc_id = v_empresa::uuid)
       AND (v_area      IS NULL OR o.area_id = v_area::uuid)
       AND (v_prioridad IS NULL OR o.prioridad_tecnica::text = v_prioridad)
       AND (v_tipo_trab IS NULL OR o.tipo_trabajo_id = v_tipo_trab::uuid)
       AND (v_resp      IS NULL OR o.coordinador_id = v_resp::uuid OR o.ejecutor_id = v_resp::uuid)
       AND (v_desde     IS NULL OR o.fecha_creacion >= v_desde::timestamptz)
       AND (v_hasta     IS NULL OR o.fecha_creacion <  (v_hasta::date + 1)::timestamptz)
       AND (v_emerg     IS NULL OR o.es_emergencia = v_emerg)
       AND (NOT v_solo_raiz OR o.ot_padre_id IS NULL)
       AND (v_padre     IS NULL OR o.ot_padre_id = v_padre::uuid)
       AND (nullif(v_buscar,'') IS NULL
            OR internal.normalizar_busqueda(o.numero_ot) LIKE '%'||v_buscar||'%'
            OR EXISTS (SELECT 1 FROM core.solicitud_trabajo s
                        WHERE s.id = o.solicitud_origen_id
                          AND internal.normalizar_busqueda(s.titulo||' '||s.descripcion) LIKE '%'||v_buscar||'%'))
       AND (v_global
            OR NOT EXISTS (SELECT 1 FROM core.usuario_alcance ua WHERE ua.usuario_id = p_user_id)
            OR EXISTS (SELECT 1 FROM core.usuario_alcance ua
                        WHERE ua.usuario_id = p_user_id
                          AND (ua.sucursal_id    IS NULL OR ua.sucursal_id    = o.sucursal_id)
                          AND (ua.empresa_ruc_id IS NULL OR ua.empresa_ruc_id = o.empresa_ruc_id)
                          AND (ua.area_id        IS NULL OR ua.area_id        = o.area_id)))
  ),
  pagina AS (
    SELECT jsonb_build_object(
      'id', o.id, 'numero_ot', o.numero_ot, 'estado', o.estado, 'condicion', o.condicion,
      'estado_administrativo', o.estado_administrativo,
      -- Indicador combinado que exige el cap. 14.3 para listas y tablero.
      'indicador', CASE WHEN o.estado = 'cerrada' AND o.estado_administrativo <> 'administracion_completa'
                        THEN 'CERRADA - ' || upper(replace(o.estado_administrativo::text,'_',' '))
                        ELSE upper(replace(o.estado::text,'_',' ')) END,
      'titulo', coalesce(s.titulo, o.motivo_derivacion_texto, o.numero_ot),
      'prioridad_tecnica', o.prioridad_tecnica,
      'es_emergencia', o.es_emergencia,
      'regularizacion_pendiente', o.regularizacion_pendiente,
      'nivel', o.nivel, 'es_derivada', o.ot_padre_id IS NOT NULL,
      'ot_padre', pa.numero_ot,
      'derivadas_activas', (SELECT count(*) FROM core.orden_trabajo h
                             WHERE h.ot_padre_id = o.id AND h.deleted_at IS NULL
                               AND h.estado NOT IN ('cerrada','cancelada')),
      'sucursal', su.nombre, 'empresa_ruc', er.razon_social, 'area', ar.nombre,
      'tipo_trabajo', tt.nombre,
      'coordinador', co.nombres||' '||co.apellidos,
      'ejecutor', ej.nombres||' '||ej.apellidos,
      'fecha_creacion', o.fecha_creacion,
      'fecha_inicio_real', o.fecha_inicio_real,
      'fecha_termino_real', o.fecha_termino_real,
      'fecha_cierre', o.fecha_cierre,
      'duracion_dias', CASE WHEN o.fecha_inicio_real IS NOT NULL AND o.fecha_termino_real IS NOT NULL
                            THEN round(extract(epoch FROM (o.fecha_termino_real - o.fecha_inicio_real))/86400.0, 2) END,
      'tiene_diagnostico', EXISTS (SELECT 1 FROM core.diagnostico d WHERE d.ot_id=o.id AND d.vigente),
      'tiene_cotizacion',  EXISTS (SELECT 1 FROM core.cotizacion c WHERE c.ot_id=o.id AND c.vigente AND NOT c.invalidada),
      -- El solicitante no ve costos (cap. 13, QA-18): se decide una vez arriba.
      'monto_cotizado', CASE WHEN v_ve_costos THEN
        (SELECT c.monto FROM core.cotizacion c WHERE c.ot_id=o.id AND c.vigente AND NOT c.invalidada LIMIT 1) END,
      'moneda', CASE WHEN v_ve_costos THEN
        (SELECT c.moneda FROM core.cotizacion c WHERE c.ot_id=o.id AND c.vigente AND NOT c.invalidada LIMIT 1) END,
      'veces_reabierta', o.veces_reabierta,
      'trazabilidad_version', o.trazabilidad_version
    ) AS d
    FROM filtrado f
    JOIN core.orden_trabajo o ON o.id = f.id
    LEFT JOIN core.solicitud_trabajo s ON s.id = o.solicitud_origen_id
    LEFT JOIN core.orden_trabajo pa    ON pa.id = o.ot_padre_id
    LEFT JOIN core.sucursal su         ON su.id = o.sucursal_id
    LEFT JOIN core.empresa_ruc er      ON er.id = o.empresa_ruc_id
    LEFT JOIN core.area ar             ON ar.id = o.area_id
    LEFT JOIN core.tipo_trabajo tt     ON tt.id = o.tipo_trabajo_id
    LEFT JOIN core.usuario co          ON co.id = o.coordinador_id
    LEFT JOIN core.usuario ej          ON ej.id = o.ejecutor_id
    ORDER BY o.prioridad_tecnica NULLS LAST, o.fecha_creacion DESC
    LIMIT v_size OFFSET v_off
  )
  SELECT (SELECT count(*)::int FROM filtrado),
         coalesce((SELECT jsonb_agg(d) FROM pagina), '[]'::jsonb)
    INTO v_total, v_data;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_ot_obtener(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_ot_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_arbol JSONB;
  v_ve_costos BOOLEAN;
  v_ve_interno BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  v_arbol := internal.fn_ot_trazabilidad_fresca(p_ot_id);

  v_ve_costos := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur JOIN core.rol_permiso rp ON rp.rol_id=ur.rol_id
      JOIN core.permiso p ON p.id=rp.permiso_id
     WHERE ur.usuario_id=p_user_id AND p.codigo='costos:ver');
  v_ve_interno := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur JOIN core.rol_permiso rp ON rp.rol_id=ur.rol_id
      JOIN core.permiso p ON p.id=rp.permiso_id
     WHERE ur.usuario_id=p_user_id AND p.codigo='administrativo:ver');

  -- QA-18: el solicitante no ve costos, RUC, CECOS, cotizaciones ni notas
  -- internas. Se poda el árbol ANTES de devolverlo, no en el frontend.
  IF NOT v_ve_costos THEN
    v_arbol := v_arbol - 'costos' - 'cotizaciones';
  END IF;
  IF NOT v_ve_interno THEN
    v_arbol := v_arbol - 'administrativo';
    v_arbol := jsonb_set(v_arbol, '{organizacion,empresa_ruc}', 'null'::jsonb, false);
    v_arbol := jsonb_set(v_arbol, '{organizacion,cecos}', 'null'::jsonb, false);
    IF v_arbol ? 'conversacion' THEN
      v_arbol := jsonb_set(v_arbol, '{conversacion,mensajes}', coalesce((
        SELECT jsonb_agg(m) FROM jsonb_array_elements(v_arbol->'conversacion'->'mensajes') m
         WHERE m->>'visibilidad' IS DISTINCT FROM 'interna'), '[]'::jsonb));
    END IF;
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', v_arbol);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_ot_trazabilidad(uuid, uuid, boolean, uuid, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_ot_trazabilidad(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_profundidad integer DEFAULT 10) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:ver');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  -- Con la profundidad por defecto se sirve el snapshot; con otra se recalcula,
  -- porque el snapshot siempre se guarda a profundidad 10.
  IF coalesce(p_profundidad,10) = 10 THEN
    v := internal.fn_ot_trazabilidad_fresca(p_ot_id);
  ELSE
    v := internal.fn_ot_trazabilidad(p_ot_id, p_profundidad, false);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_permiso_listar(uuid, uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_permiso_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', p.id, 'codigo', p.codigo, 'modulo', p.modulo,
           'accion', p.accion, 'descripcion', p.descripcion) ORDER BY p.modulo, p.accion), '[]'::jsonb)
    INTO v FROM core.permiso p;
  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_proveedor_listar(uuid, uuid, boolean, jsonb, integer, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_proveedor_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb, p_page integer DEFAULT 1, p_page_size integer DEFAULT 20) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,20),1),100);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1)*v_size;
  v_total INT; v_data JSONB;
  v_buscar TEXT := internal.normalizar_busqueda(p_filtros->>'buscar');
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT count(*) INTO v_total FROM core.proveedor p
   WHERE p.tenant_id = p_tenant_id AND p.deleted_at IS NULL
     AND (nullif(v_buscar,'') IS NULL
          OR internal.normalizar_busqueda(p.razon_social||' '||coalesce(p.ruc,'')) LIKE '%'||v_buscar||'%');

  SELECT coalesce(jsonb_agg(d), '[]'::jsonb) INTO v_data FROM (
    SELECT jsonb_build_object(
      'id', p.id, 'ruc', p.ruc, 'razon_social', p.razon_social,
      'contacto', p.contacto, 'telefono', p.telefono, 'email', p.email, 'estado', p.estado,
      -- Recurrencia y costo histórico, SIN ranking automático (cap. 16.2)
      'cotizaciones', (SELECT count(*) FROM core.cotizacion c WHERE c.proveedor_id = p.id),
      'ultima_cotizacion', (SELECT max(c.fecha_cotizacion) FROM core.cotizacion c WHERE c.proveedor_id = p.id)
    ) AS d
    FROM core.proveedor p
    WHERE p.tenant_id = p_tenant_id AND p.deleted_at IS NULL
      AND (nullif(v_buscar,'') IS NULL
           OR internal.normalizar_busqueda(p.razon_social||' '||coalesce(p.ruc,'')) LIKE '%'||v_buscar||'%')
    ORDER BY p.razon_social LIMIT v_size OFFSET v_off
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_reporte_ot(uuid, uuid, boolean, jsonb, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_reporte_ot(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb, p_limite integer DEFAULT 5000) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v JSONB; v_global BOOLEAN; v_ve_costos BOOLEAN;
  v_desde TEXT := p_filtros->>'desde';       v_hasta TEXT := p_filtros->>'hasta';
  v_suc   TEXT := p_filtros->>'sucursal_id'; v_emp   TEXT := p_filtros->>'empresa_ruc_id';
  v_area  TEXT := p_filtros->>'area_id';     v_estado TEXT := p_filtros->>'estado';
  v_prio  TEXT := p_filtros->>'prioridad_tecnica';
  v_tipo  TEXT := p_filtros->>'tipo_trabajo_id';
  v_resp  TEXT := p_filtros->>'responsable_id';
  v_emerg BOOLEAN := (p_filtros->>'emergencia')::boolean;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'reportes:ver');
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  v_ve_costos := p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur JOIN core.rol_permiso rp ON rp.rol_id=ur.rol_id
      JOIN core.permiso p ON p.id=rp.permiso_id
     WHERE ur.usuario_id=p_user_id AND p.codigo='costos:ver');

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'numero_ot', o.numero_ot,
    'estado', o.estado, 'estado_administrativo', o.estado_administrativo,
    'titulo', coalesce(s.titulo, o.motivo_derivacion_texto),
    'solicitud', s.numero,
    'ot_padre', pa.numero_ot,
    'nivel', o.nivel,
    'sucursal', su.nombre, 'empresa_ruc', er.razon_social, 'ruc', er.ruc,
    'area', ar.nombre, 'cecos', ce.codigo,
    'tipo_mantenimiento', tm.nombre, 'tipo_trabajo', tt.nombre,
    'prioridad_tecnica', o.prioridad_tecnica,
    'prioridad_percibida', s.prioridad_percibida,
    'es_emergencia', o.es_emergencia,
    'coordinador', co.nombres||' '||co.apellidos,
    'ejecutor', ej.nombres||' '||ej.apellidos,
    'fecha_creacion', o.fecha_creacion, 'fecha_inicio', o.fecha_inicio_real,
    'fecha_termino', o.fecha_termino_real, 'fecha_cierre', o.fecha_cierre,
    'duracion_dias', CASE WHEN o.fecha_inicio_real IS NOT NULL AND o.fecha_termino_real IS NOT NULL
                          THEN round(extract(epoch FROM (o.fecha_termino_real-o.fecha_inicio_real))/86400.0,2) END,
    'veces_reabierta', o.veces_reabierta,
    'proveedor', CASE WHEN v_ve_costos THEN coalesce(pr.razon_social, c.proveedor_nombre) END,
    'monto_cotizado', CASE WHEN v_ve_costos THEN c.monto END,
    'moneda', CASE WHEN v_ve_costos THEN c.moneda END,
    'solped_sap', CASE WHEN v_ve_costos THEN sp.numero_sap END,
    'oc', CASE WHEN v_ve_costos THEN oc.numero_oc END,
    'monto_liberado', CASE WHEN v_ve_costos THEN sa.monto_liberado_total END
  ) ORDER BY o.fecha_creacion DESC), '[]'::jsonb) INTO v
  FROM core.orden_trabajo o
  LEFT JOIN core.solicitud_trabajo s ON s.id = o.solicitud_origen_id
  LEFT JOIN core.orden_trabajo pa    ON pa.id = o.ot_padre_id
  LEFT JOIN core.sucursal su         ON su.id = o.sucursal_id
  LEFT JOIN core.empresa_ruc er      ON er.id = o.empresa_ruc_id
  LEFT JOIN core.area ar             ON ar.id = o.area_id
  LEFT JOIN core.cecos ce            ON ce.id = o.cecos_id
  LEFT JOIN core.catalogo_item tm    ON tm.id = o.tipo_mantenimiento_id
  LEFT JOIN core.tipo_trabajo tt     ON tt.id = o.tipo_trabajo_id
  LEFT JOIN core.usuario co          ON co.id = o.coordinador_id
  LEFT JOIN core.usuario ej          ON ej.id = o.ejecutor_id
  LEFT JOIN core.cotizacion c        ON c.ot_id = o.id AND c.vigente AND NOT c.invalidada
  LEFT JOIN core.proveedor pr        ON pr.id = c.proveedor_id
  LEFT JOIN core.solped sp           ON sp.ot_id = o.id AND sp.vigente AND NOT sp.anulada
  LEFT JOIN core.seguimiento_administrativo sa ON sa.ot_id = o.id
  LEFT JOIN LATERAL (SELECT numero_oc FROM core.orden_compra
                      WHERE ot_id = o.id AND NOT anulada
                      ORDER BY created_at DESC LIMIT 1) oc ON true
  WHERE o.deleted_at IS NULL
    AND (v_global OR o.tenant_id = p_tenant_id)
    AND (v_desde  IS NULL OR o.fecha_creacion >= v_desde::timestamptz)
    AND (v_hasta  IS NULL OR o.fecha_creacion < (v_hasta::date + 1)::timestamptz)
    AND (v_suc    IS NULL OR o.sucursal_id = v_suc::uuid)
    AND (v_emp    IS NULL OR o.empresa_ruc_id = v_emp::uuid)
    AND (v_area   IS NULL OR o.area_id = v_area::uuid)
    AND (v_estado IS NULL OR o.estado::text = v_estado)
    AND (v_prio   IS NULL OR o.prioridad_tecnica::text = v_prio)
    AND (v_tipo   IS NULL OR o.tipo_trabajo_id = v_tipo::uuid)
    AND (v_resp   IS NULL OR o.coordinador_id = v_resp::uuid OR o.ejecutor_id = v_resp::uuid)
    AND (v_emerg  IS NULL OR o.es_emergencia = v_emerg)
    AND (v_global
         OR NOT EXISTS (SELECT 1 FROM core.usuario_alcance ua WHERE ua.usuario_id = p_user_id)
         OR EXISTS (SELECT 1 FROM core.usuario_alcance ua
                     WHERE ua.usuario_id = p_user_id
                       AND (ua.sucursal_id    IS NULL OR ua.sucursal_id    = o.sucursal_id)
                       AND (ua.empresa_ruc_id IS NULL OR ua.empresa_ruc_id = o.empresa_ruc_id)
                       AND (ua.area_id        IS NULL OR ua.area_id        = o.area_id)));

  RETURN jsonb_build_object('ok', true, 'data', v,
    'meta', jsonb_build_object('filtros', p_filtros, 'incluye_costos', v_ve_costos));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_rol_listar(uuid, uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_rol_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'roles:listar');

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'id', r.id, 'codigo', r.codigo, 'nombre', r.nombre, 'descripcion', r.descripcion,
    'scope', r.scope, 'es_sistema', r.es_sistema,
    'usuarios', (SELECT count(*) FROM core.usuario_rol ur WHERE ur.rol_id = r.id),
    'permisos', coalesce((SELECT jsonb_agg(p.codigo ORDER BY p.codigo)
                            FROM core.rol_permiso rp JOIN core.permiso p ON p.id = rp.permiso_id
                           WHERE rp.rol_id = r.id), '[]'::jsonb)
  ) ORDER BY r.nombre), '[]'::jsonb) INTO v
  FROM core.rol r
  WHERE r.deleted_at IS NULL AND (r.tenant_id = p_tenant_id OR r.tenant_id IS NULL);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_sla_solicitudes(uuid, uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_sla_solicitudes(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB; v_sla JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  -- Minutos máximos de primera revisión, configurables por tenant.
  v_sla := coalesce(internal.config(p_tenant_id, 'sla_primera_revision'),
                    '{"critica":15,"alta":60,"media":480,"baja":1440}'::jsonb);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'prioridad', pr,
    'sla_minutos', (v_sla->>pr)::int,
    'pendientes', pendientes,
    'incumplidas', incumplidas
  ) ORDER BY pr), '[]'::jsonb) INTO v
  FROM (
    SELECT coalesce(s.prioridad_percibida::text,'baja') AS pr,
           count(*) FILTER (WHERE s.fecha_primera_revision IS NULL) AS pendientes,
           count(*) FILTER (
             WHERE s.fecha_primera_revision IS NULL
               AND s.fecha_envio IS NOT NULL
               AND now() - s.fecha_envio >
                   make_interval(mins => coalesce((v_sla->>coalesce(s.prioridad_percibida::text,'baja'))::int, 1440))
           ) AS incumplidas
      FROM core.solicitud_trabajo s
     WHERE s.tenant_id = p_tenant_id AND s.deleted_at IS NULL
       AND s.estado IN ('enviada','en_revision')
     GROUP BY 1
  ) x;

  RETURN jsonb_build_object('ok', true, 'data', v,
    'meta', jsonb_build_object('nota',
      'Los SLA son objetivos de atención, no estimaciones de ejecución. No cierran solicitudes automáticamente.'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_solicitud_listar(uuid, uuid, boolean, jsonb, integer, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_solicitud_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb, p_page integer DEFAULT 1, p_page_size integer DEFAULT 20) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,20),1),100);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1)*v_size;
  v_total INT; v_data JSONB; v_global BOOLEAN;
  v_estado TEXT := p_filtros->>'estado';
  v_area   TEXT := p_filtros->>'area_id';
  v_mias   BOOLEAN := coalesce((p_filtros->>'mias')::boolean, false);
  v_buscar TEXT := internal.normalizar_busqueda(p_filtros->>'buscar');
  v_pendientes BOOLEAN := coalesce((p_filtros->>'pendientes_revision')::boolean, false);
  -- Rango sobre la fecha de envío; si aún es borrador, sobre la de creación.
  v_desde  TEXT := nullif(p_filtros->>'desde','');
  v_hasta  TEXT := nullif(p_filtros->>'hasta','');
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  -- CTE en vez de tabla temporal: una función STABLE no puede hacer CREATE TABLE.
  WITH filtrado AS (
    SELECT s.id FROM core.solicitud_trabajo s
     WHERE s.deleted_at IS NULL
       AND (v_global OR s.tenant_id = p_tenant_id)
       AND (v_estado IS NULL OR s.estado::text = v_estado)
       AND (v_area   IS NULL OR s.area_id = v_area::uuid)
       AND (NOT v_mias OR s.solicitante_id = p_user_id)
       AND (NOT v_pendientes OR s.estado IN ('enviada','en_revision'))
       AND (v_desde IS NULL OR coalesce(s.fecha_envio, s.created_at) >= v_desde::timestamptz)
       AND (v_hasta IS NULL OR coalesce(s.fecha_envio, s.created_at) < (v_hasta::date + 1)::timestamptz)
       AND (nullif(v_buscar,'') IS NULL
            OR internal.normalizar_busqueda(s.titulo||' '||s.descripcion||' '||s.numero) LIKE '%'||v_buscar||'%')
       -- El solicitante ve lo suyo; el resto necesita alcance sobre el área (cap. 4.1).
       AND (v_global OR s.solicitante_id = p_user_id
            OR NOT EXISTS (SELECT 1 FROM core.usuario_alcance ua WHERE ua.usuario_id = p_user_id)
            OR EXISTS (SELECT 1 FROM core.usuario_alcance ua
                        WHERE ua.usuario_id = p_user_id
                          AND (ua.area_id IS NULL OR ua.area_id = s.area_id)))
  ),
  pagina AS (
    SELECT jsonb_build_object(
      'id', s.id, 'numero', s.numero, 'estado', s.estado, 'titulo', s.titulo,
      'descripcion', s.descripcion, 'lugar', s.lugar,
      'prioridad_percibida', s.prioridad_percibida,
      'impacto', ci.nombre,
      'area', ar.nombre, 'area_id', s.area_id,
      'empresa_ruc', er.razon_social,
      'solicitante', u.nombres||' '||u.apellidos,
      'fecha_envio', s.fecha_envio,
      'fecha_primera_revision', s.fecha_primera_revision,
      -- Antigüedad: es lo que ordena la bandeja del coordinador (cap. 35.1).
      'horas_espera', CASE WHEN s.fecha_primera_revision IS NULL AND s.fecha_envio IS NOT NULL
                           THEN round(extract(epoch FROM (now() - s.fecha_envio))/3600.0, 1) END,
      'ot', (SELECT jsonb_build_object('id', o.id, 'numero', o.numero_ot, 'estado', o.estado)
               FROM core.orden_trabajo o WHERE o.solicitud_origen_id = s.id),
      'adjuntos', (SELECT count(*) FROM core.adjunto a
                    WHERE a.entidad_tipo='solicitud_trabajo' AND a.entidad_id=s.id),
      'created_at', s.created_at
    ) AS d
    FROM filtrado f
    JOIN core.solicitud_trabajo s ON s.id = f.id
    LEFT JOIN core.area ar          ON ar.id = s.area_id
    LEFT JOIN core.empresa_ruc er   ON er.id = s.empresa_ruc_id
    LEFT JOIN core.usuario u        ON u.id = s.solicitante_id
    LEFT JOIN core.catalogo_item ci ON ci.id = s.impacto_operativo_id
    ORDER BY s.created_at DESC
    LIMIT v_size OFFSET v_off
  )
  SELECT (SELECT count(*)::int FROM filtrado),
         coalesce((SELECT jsonb_agg(d) FROM pagina), '[]'::jsonb)
    INTO v_total, v_data;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_solicitud_obtener(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_solicitud_obtener(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT jsonb_build_object(
    'id', s.id, 'numero', s.numero, 'estado', s.estado,
    'titulo', s.titulo, 'descripcion', s.descripcion, 'lugar', s.lugar,
    'impacto', ci.nombre, 'impacto_comentario', s.impacto_comentario,
    'prioridad_percibida', s.prioridad_percibida,
    'area', jsonb_build_object('id', ar.id, 'nombre', ar.nombre),
    'empresa_ruc', jsonb_build_object('id', er.id, 'razon_social', er.razon_social, 'ruc', er.ruc),
    'solicitante', jsonb_build_object('id', u.id, 'nombre', u.nombres||' '||u.apellidos),
    'fecha_envio', s.fecha_envio, 'fecha_primera_revision', s.fecha_primera_revision,
    'observacion_actual', s.observacion_actual,
    'solicitud_principal_id', s.solicitud_principal_id,
    'decisiones', coalesce((SELECT jsonb_agg(jsonb_build_object(
        'tipo', d.tipo, 'estado_anterior', d.estado_anterior, 'estado_nuevo', d.estado_nuevo,
        'motivo', cm.nombre, 'comentario', d.comentario,
        'actor', du.nombres||' '||du.apellidos, 'fecha', d.created_at) ORDER BY d.created_at)
      FROM core.solicitud_decision d
      LEFT JOIN core.usuario du ON du.id = d.actor_id
      LEFT JOIN core.catalogo_item cm ON cm.id = d.motivo_id
     WHERE d.solicitud_id = s.id), '[]'::jsonb),
    'adjuntos', internal.fn_adjuntos_de('solicitud_trabajo', s.id),
    'ot', (SELECT jsonb_build_object('id', o.id, 'numero', o.numero_ot, 'estado', o.estado)
             FROM core.orden_trabajo o WHERE o.solicitud_origen_id = s.id)
  ) INTO v
  FROM core.solicitud_trabajo s
  LEFT JOIN core.area ar        ON ar.id = s.area_id
  LEFT JOIN core.empresa_ruc er ON er.id = s.empresa_ruc_id
  LEFT JOIN core.usuario u      ON u.id = s.solicitante_id
  LEFT JOIN core.catalogo_item ci ON ci.id = s.impacto_operativo_id
  WHERE s.id = p_solicitud_id AND s.deleted_at IS NULL;

  IF v IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;
  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_tipo_trabajo_listar(uuid, uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_tipo_trabajo_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', t.id, 'codigo', t.codigo, 'nombre', t.nombre,
           'padre_id', t.padre_id, 'es_base', t.es_base, 'estado', t.estado,
           'casos_historicos', (SELECT count(*) FROM core.costo_unitario cu
                                 WHERE cu.tipo_trabajo_id = t.id AND cu.es_comparable)
         ) ORDER BY t.nombre), '[]'::jsonb) INTO v
  FROM core.tipo_trabajo t
  WHERE t.deleted_at IS NULL AND t.estado = 'activo'
    AND (t.tenant_id = p_tenant_id OR t.tenant_id IS NULL);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_trazabilidad_buscar(uuid, uuid, boolean, jsonb, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_trazabilidad_buscar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_criterio jsonb, p_limite integer DEFAULT 50) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:listar');

  -- Contención: p_criterio se usa con el operador @> sobre jsonb. No se concatena
  -- en SQL, así que no hay superficie de inyección.
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id', o.id, 'numero_ot', o.numero_ot, 'estado', o.estado,
           'trazabilidad_version', o.trazabilidad_version,
           'coincidencia', p_criterio)), '[]'::jsonb) INTO v
  FROM core.orden_trabajo o
  WHERE o.tenant_id = p_tenant_id AND o.deleted_at IS NULL
    AND o.trazabilidad @> p_criterio
  LIMIT least(coalesce(p_limite,50), 200);

  RETURN jsonb_build_object('ok', true, 'data', v);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_trazabilidad_verificar(uuid, uuid, boolean, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_trazabilidad_verificar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_limite integer DEFAULT 50) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v JSONB; v_revisadas INT := 0; v_ot RECORD; v_desviadas JSONB := '[]'::jsonb;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'auditoria:ver');

  FOR v_ot IN
    SELECT id, numero_ot, trazabilidad, trazabilidad_dirty
      FROM core.orden_trabajo
     WHERE tenant_id = p_tenant_id AND deleted_at IS NULL
     ORDER BY updated_at DESC
     LIMIT least(coalesce(p_limite,50), 500)
  LOOP
    v_revisadas := v_revisadas + 1;
    -- Se compara sin _meta: lleva la marca de tiempo de generación y siempre difiere.
    IF NOT v_ot.trazabilidad_dirty
       AND (v_ot.trazabilidad - '_meta') IS DISTINCT FROM
           (internal.fn_ot_trazabilidad(v_ot.id, 10, false) - '_meta') THEN
      v_desviadas := v_desviadas || jsonb_build_array(
        jsonb_build_object('id', v_ot.id, 'numero_ot', v_ot.numero_ot));
    END IF;
  END LOOP;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'revisadas', v_revisadas,
    'desviadas', v_desviadas,
    'sucias_pendientes', (SELECT count(*) FROM core.orden_trabajo
                           WHERE tenant_id = p_tenant_id AND trazabilidad_dirty),
    'integridad_ok', jsonb_array_length(v_desviadas) = 0));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_usuario_asignables(uuid, uuid, boolean, jsonb); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_usuario_asignables(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_data JSONB;
  v_global BOOLEAN;
  v_rol TEXT := nullif(p_filtros->>'rol','');
  v_puede BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT p_is_super_admin OR EXISTS (
    SELECT 1 FROM core.usuario_rol ur
      JOIN core.rol_permiso rp ON rp.rol_id = ur.rol_id
      JOIN core.permiso p      ON p.id = rp.permiso_id
     WHERE ur.usuario_id = p_user_id
       AND p.codigo IN ('ot:crear','ot:editar','ejecucion:iniciar','usuarios:listar'))
  INTO v_puede;

  IF NOT v_puede THEN
    RAISE EXCEPTION 'Permiso denegado: asignar responsables' USING ERRCODE = '42501';
  END IF;

  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  SELECT coalesce(jsonb_agg(d ORDER BY d->>'nombre'), '[]'::jsonb) INTO v_data FROM (
    SELECT jsonb_build_object(
      'id', u.id,
      'nombre', u.nombres||' '||u.apellidos,
      'cargo', u.cargo,
      'roles', coalesce((SELECT jsonb_agg(r.codigo)
                           FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                          WHERE ur.usuario_id=u.id), '[]'::jsonb)
    ) AS d
    FROM core.usuario u
    WHERE u.deleted_at IS NULL
      AND u.estado = 'activo'
      AND (v_global OR u.tenant_id = p_tenant_id)
      AND (v_rol IS NULL OR EXISTS (SELECT 1 FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                                     WHERE ur.usuario_id=u.id AND r.codigo = v_rol))
    ORDER BY u.nombres, u.apellidos
    LIMIT 200
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v_data);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: fn_usuario_listar(uuid, uuid, boolean, jsonb, integer, integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.fn_usuario_listar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_filtros jsonb DEFAULT '{}'::jsonb, p_page integer DEFAULT 1, p_page_size integer DEFAULT 20) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_size INT := least(greatest(coalesce(p_page_size,20),1),100);
  v_off  INT := (greatest(coalesce(p_page,1),1)-1) * v_size;
  v_total INT; v_data JSONB; v_global BOOLEAN;
  v_buscar TEXT := internal.normalizar_busqueda(p_filtros->>'buscar');
  v_estado TEXT := p_filtros->>'estado';
  v_rol    TEXT := p_filtros->>'rol';
  -- El rango se aplica al alta del usuario: es la fecha que tiene sentido
  -- acotar en una pantalla de administración ("altas de este mes").
  v_desde  TEXT := nullif(p_filtros->>'desde','');
  v_hasta  TEXT := nullif(p_filtros->>'hasta','');
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:listar');
  v_global := internal.es_acceso_global(p_user_id, p_is_super_admin);

  SELECT count(*) INTO v_total
    FROM core.usuario u
   WHERE u.deleted_at IS NULL
     AND (v_global OR u.tenant_id = p_tenant_id)
     AND (v_estado IS NULL OR u.estado::text = v_estado)
     AND (nullif(v_buscar,'') IS NULL
          OR internal.normalizar_busqueda(u.nombres||' '||u.apellidos||' '||u.email) LIKE '%'||v_buscar||'%')
     AND (v_desde IS NULL OR u.created_at >= v_desde::timestamptz)
     AND (v_hasta IS NULL OR u.created_at < (v_hasta::date + 1)::timestamptz)
     AND (v_rol IS NULL OR EXISTS (SELECT 1 FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                                    WHERE ur.usuario_id=u.id AND r.codigo=v_rol));

  SELECT coalesce(jsonb_agg(d ORDER BY d->>'apellidos'), '[]'::jsonb) INTO v_data FROM (
    SELECT jsonb_build_object(
      'id', u.id, 'email', u.email, 'nombres', u.nombres, 'apellidos', u.apellidos,
      'nombre', u.nombres||' '||u.apellidos,
      'documento', u.documento, 'telefono', u.telefono, 'cargo', u.cargo,
      'estado', u.estado, 'is_super_admin', u.is_super_admin,
      'ultimo_acceso_at', u.ultimo_acceso_at,
      'roles', coalesce((SELECT jsonb_agg(jsonb_build_object('id',r.id,'codigo',r.codigo,'nombre',r.nombre))
                           FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                          WHERE ur.usuario_id=u.id), '[]'::jsonb)
    ) AS d
    FROM core.usuario u
    WHERE u.deleted_at IS NULL
      AND (v_global OR u.tenant_id = p_tenant_id)
      AND (v_estado IS NULL OR u.estado::text = v_estado)
      AND (nullif(v_buscar,'') IS NULL
           OR internal.normalizar_busqueda(u.nombres||' '||u.apellidos||' '||u.email) LIKE '%'||v_buscar||'%')
      AND (v_desde IS NULL OR u.created_at >= v_desde::timestamptz)
      AND (v_hasta IS NULL OR u.created_at < (v_hasta::date + 1)::timestamptz)
      AND (v_rol IS NULL OR EXISTS (SELECT 1 FROM core.usuario_rol ur JOIN core.rol r ON r.id=ur.rol_id
                                     WHERE ur.usuario_id=u.id AND r.codigo=v_rol))
    ORDER BY u.apellidos, u.nombres
    LIMIT v_size OFFSET v_off
  ) s;

  RETURN jsonb_build_object('ok', true, 'data', v_data,
                            'meta', internal.meta_paginacion(v_total, p_page, v_size));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_adjunto_registrar(uuid, uuid, boolean, text, uuid, text, text, text, text, text, bigint, uuid, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_adjunto_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_entidad_tipo text, p_entidad_id uuid, p_etapa text, p_tipo text, p_nombre text, p_storage_key text, p_mime_type text DEFAULT NULL::text, p_tamano_bytes bigint DEFAULT NULL::bigint, p_ot_id uuid DEFAULT NULL::uuid, p_visibilidad text DEFAULT 'canal'::text, p_checksum text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v core.adjunto%ROWTYPE;
  v_tipo core.tipo_adjunto := p_tipo::core.tipo_adjunto;
  v_limite BIGINT;
  v_total_ot BIGINT;
  v_limite_ot BIGINT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'adjuntos:cargar');

  v_limite := internal.limite_adjunto(p_tenant_id, v_tipo);
  IF p_tamano_bytes IS NOT NULL AND p_tamano_bytes > v_limite THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION',
      format('El archivo supera el límite de %s MB para %s', round(v_limite/1048576.0), p_tipo),
      'tamano_bytes'));
  END IF;

  -- Tope acumulado por OT. El cap. 28.3 pide ADVERTIR antes de superarlo, así que
  -- se devuelve la advertencia junto con el resultado en vez de fallar en seco.
  v_limite_ot := coalesce((internal.config(p_tenant_id,'limites_adjunto')->>'total_ot')::bigint,
                          500 * 1024 * 1024);
  IF p_ot_id IS NOT NULL THEN
    SELECT coalesce(sum(tamano_bytes),0) INTO v_total_ot
      FROM core.adjunto WHERE ot_id = p_ot_id AND estado = 'vigente';
    IF v_total_ot + coalesce(p_tamano_bytes,0) > v_limite_ot THEN
      RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
        'BUSINESS_RULE',
        format('La OT superaría el límite de %s MB de archivos', round(v_limite_ot/1048576.0))));
    END IF;
  END IF;

  INSERT INTO core.adjunto (
    tenant_id, ot_id, entidad_tipo, entidad_id, etapa, tipo, nombre, nombre_original,
    mime_type, tamano_bytes, storage_key, checksum, visibilidad, autor_id)
  VALUES (p_tenant_id, p_ot_id, p_entidad_tipo, p_entidad_id,
          p_etapa::core.etapa_adjunto, v_tipo, p_nombre, p_nombre,
          p_mime_type, p_tamano_bytes, p_storage_key, p_checksum,
          coalesce(p_visibilidad,'canal')::core.visibilidad_mensaje, p_user_id)
  RETURNING * INTO v;

  IF p_ot_id IS NOT NULL THEN
    PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'adjunto_cargado',
      p_user_id, p_entidad_tipo, p_entidad_id, NULL,
      jsonb_build_object('nombre', p_nombre, 'tipo', p_tipo, 'etapa', p_etapa));
    PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'nombre', v.nombre, 'storage_key', v.storage_key,
    'advertencia', CASE WHEN p_ot_id IS NOT NULL
                          AND (v_total_ot + coalesce(p_tamano_bytes,0)) > v_limite_ot * 0.8
                        THEN 'La OT está cerca del límite de almacenamiento configurado.' END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_adjunto_retirar(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_adjunto_retirar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_adjunto_id uuid, p_motivo text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.adjunto%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'adjuntos:retirar');

  SELECT * INTO v FROM core.adjunto WHERE id = p_adjunto_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Adjunto no encontrado'));
  END IF;

  UPDATE core.adjunto
     SET estado = 'retirado', retirado_at = now(), retirado_por = p_user_id
   WHERE id = p_adjunto_id;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'retirar', 'adjunto',
                                       v.id, to_jsonb(v), NULL, p_motivo);
  IF v.ot_id IS NOT NULL THEN
    PERFORM app.sp_ot_trazabilidad_refrescar(v.ot_id, true);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('retirado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_area_crear(uuid, uuid, boolean, uuid, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_area_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_empresa_ruc_id uuid, p_codigo text, p_nombre text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.area%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'organizacion:crear');

  -- Un área pertenece a UNA sola empresa/RUC (cap. 5). El mismo nombre bajo otra
  -- razón social es otra entidad, y el índice único lo permite explícitamente.
  INSERT INTO core.area (tenant_id, empresa_ruc_id, codigo, nombre, created_by, updated_by)
  VALUES (p_tenant_id, p_empresa_ruc_id, upper(btrim(p_codigo)), btrim(p_nombre), p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'area', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_auth_cambiar_password(uuid, uuid, boolean, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_auth_cambiar_password(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_password_actual text, p_password_nueva text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_hash TEXT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT password_hash INTO v_hash FROM core.usuario WHERE id = p_user_id AND deleted_at IS NULL;
  IF v_hash IS NULL OR v_hash <> crypt(p_password_actual, v_hash) THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('UNAUTHORIZED','La contraseña actual no coincide'));
  END IF;
  IF length(coalesce(p_password_nueva,'')) < 10 THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La contraseña debe tener al menos 10 caracteres','password_nueva'));
  END IF;

  UPDATE core.usuario
     SET password_hash = crypt(p_password_nueva, gen_salt('bf', 12)), updated_by = p_user_id
   WHERE id = p_user_id;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cambiar_password', 'usuario', p_user_id);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('cambiada', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_auth_login(text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_auth_login(p_email text, p_password text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  u          core.usuario%ROWTYPE;
  v_cfg      JSONB;
  v_intentos INT;
  v_minutos  INT;
  v_restan   INT;
BEGIN
  SELECT * INTO u FROM core.usuario
   WHERE lower(email) = lower(btrim(p_email)) AND deleted_at IS NULL;

  -- Usuario inexistente: mismo mensaje y mismo coste aparente que una
  -- contraseña incorrecta. No se le regala a un atacante la confirmación de qué
  -- correos existen.
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('UNAUTHORIZED','Credenciales inválidas'));
  END IF;

  v_cfg      := coalesce(internal.config(u.tenant_id, 'bloqueo_credenciales'),
                         '{"intentos":5,"minutos":15}'::jsonb);
  v_intentos := coalesce((v_cfg->>'intentos')::int, 5);
  v_minutos  := coalesce((v_cfg->>'minutos')::int, 15);

  -- Cuenta bloqueada: se dice, y se dice cuánto falta. Callarlo sólo consigue
  -- que la persona reintente y alargue su propio bloqueo.
  IF u.bloqueado_hasta IS NOT NULL AND u.bloqueado_hasta > now() THEN
    v_restan := greatest(1, ceil(extract(epoch FROM (u.bloqueado_hasta - now())) / 60)::int);
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'UNAUTHORIZED',
      format('Cuenta bloqueada temporalmente por intentos fallidos. Vuelva a intentarlo en %s minuto(s).', v_restan)));
  END IF;

  IF u.password_hash IS NULL OR u.password_hash <> crypt(p_password, u.password_hash) THEN
    UPDATE core.usuario
       SET intentos_fallidos = intentos_fallidos + 1,
           ultimo_intento_fallido_at = now(),
           bloqueado_hasta = CASE
             WHEN intentos_fallidos + 1 >= v_intentos THEN now() + make_interval(mins => v_minutos)
             ELSE bloqueado_hasta END
     WHERE id = u.id;

    -- Cada fallo queda en la auditoría: es lo que permite detectar un ataque en
    -- curso en vez de enterarse cuando ya entraron.
    PERFORM internal.registrar_auditoria(u.id, u.tenant_id, 'login_fallido', 'usuario', u.id,
      NULL, jsonb_build_object('intentos', u.intentos_fallidos + 1, 'umbral', v_intentos));

    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('UNAUTHORIZED','Credenciales inválidas'));
  END IF;

  IF u.estado <> 'activo' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('FORBIDDEN','La cuenta está ' || u.estado));
  END IF;

  -- Entrada correcta: el contador vuelve a cero y se levanta cualquier bloqueo.
  UPDATE core.usuario
     SET ultimo_acceso_at = now(), intentos_fallidos = 0, bloqueado_hasta = NULL
   WHERE id = u.id;

  PERFORM internal.registrar_auditoria(u.id, u.tenant_id, 'login', 'usuario', u.id);
  RETURN app.fn_auth_perfil(u.id);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_avance_registrar(uuid, uuid, boolean, uuid, text, numeric); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_avance_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_descripcion text, p_porcentaje numeric DEFAULT NULL::numeric) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v core.ot_avance%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:avanzar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado NOT IN ('en_trabajo','trabajo_realizado') THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('No se registran avances con la OT en %s', o.estado)));
  END IF;
  IF btrim(coalesce(p_descripcion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El avance exige una descripción','descripcion'));
  END IF;

  INSERT INTO core.ot_avance (tenant_id, ot_id, descripcion, porcentaje, autor_id)
  VALUES (p_tenant_id, p_ot_id, btrim(p_descripcion), p_porcentaje, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'avance_registrado',
    p_user_id, 'ot_avance', v.id, NULL,
    jsonb_build_object('porcentaje', p_porcentaje));

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_catalogo_item_crear(uuid, uuid, boolean, text, text, text, text, integer, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_catalogo_item_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_tipo text, p_codigo text, p_nombre text, p_descripcion text DEFAULT NULL::text, p_orden integer DEFAULT 0, p_requiere_comentario boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.catalogo_item%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'catalogos:crear');

  INSERT INTO core.catalogo_item (tenant_id, tipo, codigo, nombre, descripcion, orden,
                                  requiere_comentario, created_by, updated_by)
  VALUES (p_tenant_id, p_tipo::core.tipo_catalogo, upper(btrim(p_codigo)), btrim(p_nombre),
          p_descripcion, coalesce(p_orden,0), coalesce(p_requiere_comentario,false),
          p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'catalogo_item', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_configuracion_guardar(uuid, uuid, boolean, text, jsonb, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_configuracion_guardar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_clave text, p_valor jsonb, p_descripcion text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
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


--
-- Name: sp_conformidad_registrar(uuid, uuid, boolean, uuid, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_conformidad_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_conformidad text, p_comentario text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE t core.trabajo_realizado%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT * INTO t FROM core.trabajo_realizado WHERE ot_id = p_ot_id AND vigente;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND','Aún no hay trabajo realizado sobre el que pronunciarse'));
  END IF;

  UPDATE core.trabajo_realizado
     SET conformidad = p_conformidad::core.conformidad_solicitante,
         conformidad_comentario = p_comentario, conformidad_at = now(), updated_by = p_user_id
   WHERE id = t.id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'conformidad_registrada',
    p_user_id, 'trabajo_realizado', t.id, NULL,
    jsonb_build_object('conformidad', p_conformidad), p_comentario);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('conformidad', p_conformidad));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_conversacion_invitar(uuid, uuid, boolean, uuid, uuid, boolean, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_conversacion_invitar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_usuario_id uuid, p_puede_escribir boolean DEFAULT true, p_ve_notas_internas boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE c core.conversacion%ROWTYPE; o core.orden_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'conversacion:invitar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  SELECT * INTO c FROM core.conversacion WHERE ot_id = p_ot_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no tiene conversación'));
  END IF;

  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id,
                                              puede_escribir, ve_notas_internas, invitado_por)
  VALUES (p_tenant_id, c.id, p_usuario_id, coalesce(p_puede_escribir,true),
          coalesce(p_ve_notas_internas,false), p_user_id)
  ON CONFLICT (conversacion_id, usuario_id) DO UPDATE
    SET puede_escribir = EXCLUDED.puede_escribir,
        ve_notas_internas = EXCLUDED.ve_notas_internas,
        activo = true, updated_at = now();

  PERFORM internal.notificar(p_tenant_id, p_usuario_id, 'conversacion_invitado',
    format('Se le incorporó a la conversación de la OT %s', o.numero_ot),
    NULL, p_ot_id, 'conversacion', c.id);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('invitado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_costo_calificar(uuid, uuid, boolean, uuid, boolean, boolean, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_costo_calificar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_costo_id uuid, p_es_comparable boolean, p_es_outlier boolean DEFAULT false, p_justificacion text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.costo_unitario%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'costos:registrar');

  IF p_es_outlier AND btrim(coalesce(p_justificacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Marcar un valor como atípico exige justificación consultable','justificacion'));
  END IF;

  UPDATE core.costo_unitario
     SET es_comparable = coalesce(p_es_comparable, es_comparable),
         es_outlier = coalesce(p_es_outlier, es_outlier),
         outlier_justificacion = coalesce(p_justificacion, outlier_justificacion),
         estado_validacion = CASE WHEN p_es_outlier THEN 'excepcion'::core.estado_validacion_costo
                                  ELSE 'validado'::core.estado_validacion_costo END,
         updated_by = p_user_id
   WHERE id = p_costo_id
  RETURNING * INTO v;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Registro de costo no encontrado'));
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'calificar', 'costo_unitario',
                                       v.id, NULL, to_jsonb(v), p_justificacion);
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_costo_registrar(uuid, uuid, boolean, uuid, text, numeric, text, text, numeric, text, text, uuid, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_costo_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_texto_original text, p_monto_total numeric, p_fuente text DEFAULT 'cotizacion'::text, p_concepto text DEFAULT NULL::text, p_cantidad numeric DEFAULT NULL::numeric, p_unidad text DEFAULT NULL::text, p_moneda text DEFAULT 'PEN'::text, p_cotizacion_id uuid DEFAULT NULL::uuid, p_descripcion_normalizada_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v core.costo_unitario%ROWTYPE;
  v_unitario NUMERIC;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'costos:registrar');

  IF btrim(coalesce(p_texto_original,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','El texto original del documento es obligatorio: no hay registros sin procedencia','texto_original'));
  END IF;

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  -- Costo unitario SÓLO si la cantidad es positiva; si no, se conserva el total
  -- y el unitario queda NULL. Dividir por una cantidad ausente inventaría un dato
  -- (cap. 32.2).
  v_unitario := CASE WHEN coalesce(p_cantidad,0) > 0
                     THEN round(p_monto_total / p_cantidad, 4) END;

  INSERT INTO core.costo_unitario (
    tenant_id, ot_id, cotizacion_id, fuente, texto_original,
    descripcion_normalizada_id, tipo_trabajo_id, concepto,
    cantidad, unidad, monto_total, costo_unitario, moneda, fecha_referencia,
    proveedor_id, sucursal_id, empresa_ruc_id, area_id,
    fue_emergencia, ot_es_derivada, created_by, updated_by)
  SELECT
    p_tenant_id, p_ot_id, coalesce(p_cotizacion_id, c.id), p_fuente::core.fuente_costo,
    btrim(p_texto_original), p_descripcion_normalizada_id, o.tipo_trabajo_id,
    nullif(p_concepto,'')::core.concepto_costo,
    p_cantidad, p_unidad, p_monto_total, v_unitario,
    coalesce(p_moneda, c.moneda::text, 'PEN')::core.moneda_codigo,
    coalesce(c.fecha_cotizacion, current_date),
    c.proveedor_id, o.sucursal_id, o.empresa_ruc_id, o.area_id,
    o.es_emergencia, o.ot_padre_id IS NOT NULL, p_user_id, p_user_id
  FROM (SELECT 1) dummy
  LEFT JOIN core.cotizacion c
    ON c.id = coalesce(p_cotizacion_id,
                       (SELECT id FROM core.cotizacion
                         WHERE ot_id = p_ot_id AND vigente AND NOT invalidada LIMIT 1))
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'costos', 'costo_registrado',
    p_user_id, 'costo_unitario', v.id, NULL,
    jsonb_build_object('monto', p_monto_total, 'moneda', v.moneda, 'fuente', p_fuente));
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_cotizacion_cargar(uuid, uuid, boolean, uuid, uuid, text, text, text, date, numeric, text, integer, integer, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_cotizacion_cargar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_proveedor_id uuid DEFAULT NULL::uuid, p_proveedor_nombre text DEFAULT NULL::text, p_proveedor_ruc text DEFAULT NULL::text, p_numero_cotizacion text DEFAULT NULL::text, p_fecha_cotizacion date DEFAULT NULL::date, p_monto numeric DEFAULT NULL::numeric, p_moneda text DEFAULT 'PEN'::text, p_plazo_ofrecido_dias integer DEFAULT NULL::integer, p_validez_dias integer DEFAULT NULL::integer, p_observaciones text DEFAULT NULL::text, p_motivo_reemplazo text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_vigente core.cotizacion%ROWTYPE;
  v core.cotizacion%ROWTYPE;
  v_version INT;
  v_tenia_solped BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'cotizaciones:cargar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  -- Se carga con la OT en cotización, o durante la regularización de una
  -- emergencia que arrancó sin ella (cap. 28.1).
  IF o.estado NOT IN ('en_cotizacion','en_diagnostico','en_trabajo') THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('No se carga cotización con la OT en %s', o.estado)));
  END IF;

  SELECT * INTO v_vigente FROM core.cotizacion
   WHERE ot_id = p_ot_id AND vigente AND NOT invalidada;

  -- Reemplazar exige motivo. No borra nada: crea una versión nueva y la anterior
  -- conserva archivo, metadatos, usuario y fecha (cap. 28.2, QA-09).
  IF v_vigente.id IS NOT NULL AND btrim(coalesce(p_motivo_reemplazo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Reemplazar la cotización vigente exige motivo','motivo_reemplazo'));
  END IF;

  SELECT coalesce(max(version),0)+1 INTO v_version FROM core.cotizacion WHERE ot_id = p_ot_id;

  UPDATE core.cotizacion SET vigente = false, updated_by = p_user_id
   WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.cotizacion (
    tenant_id, ot_id, version, vigente, proveedor_id, proveedor_ruc, proveedor_nombre,
    numero_cotizacion, fecha_cotizacion, monto, moneda, plazo_ofrecido_dias, validez_dias,
    observaciones, motivo_reemplazo, reemplaza_a, cargada_por, created_by, updated_by)
  VALUES (
    p_tenant_id, p_ot_id, v_version, true, p_proveedor_id,
    nullif(regexp_replace(coalesce(p_proveedor_ruc,''),'\D','','g'),''),
    p_proveedor_nombre, p_numero_cotizacion, p_fecha_cotizacion,
    p_monto, coalesce(p_moneda,'PEN')::core.moneda_codigo, p_plazo_ofrecido_dias, p_validez_dias,
    p_observaciones, p_motivo_reemplazo, v_vigente.id, p_user_id, p_user_id, p_user_id)
  RETURNING * INTO v;

  -- Cargar la cotización mueve la OT a 'en_cotizacion'. Desde 'en_trabajo' NO se
  -- retrocede: ahí la carga es la regularización de una emergencia que arrancó
  -- sin cotización, y el estado ya es el correcto (cap. 28.1).
  IF o.estado = 'en_diagnostico' THEN
    PERFORM internal.avanzar_estado_ot(p_tenant_id, p_ot_id, o.estado, 'en_cotizacion',
      p_user_id, 'Cotización seleccionada cargada');
  END IF;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'cotizacion',
    CASE WHEN v_vigente.id IS NULL THEN 'cotizacion_cargada' ELSE 'cotizacion_reemplazada' END,
    p_user_id, 'cotizacion', v.id,
    CASE WHEN v_vigente.id IS NOT NULL
         THEN jsonb_build_object('version', v_vigente.version, 'monto', v_vigente.monto) END,
    jsonb_build_object('version', v_version, 'monto', p_monto, 'moneda', p_moneda),
    p_motivo_reemplazo);

  -- Si ya existía una SOLPED, hay que advertir: MIP no modifica SAP automáticamente
  -- y el formulario interno puede haber quedado desalineado (cap. 28.2).
  SELECT EXISTS (SELECT 1 FROM core.solped WHERE ot_id = p_ot_id AND NOT anulada)
    INTO v_tenia_solped;

  IF o.coordinador_id IS DISTINCT FROM p_user_id THEN
    PERFORM internal.notificar(p_tenant_id, o.coordinador_id, 'cotizacion_cargada',
      format('Cotización cargada en la OT %s', o.numero_ot),
      coalesce(p_proveedor_nombre,'') || ' · ' || coalesce(p_monto::text,'s/monto'),
      p_ot_id, 'cotizacion', v.id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id,
    CASE WHEN v_vigente.id IS NULL THEN 'cargar' ELSE 'reemplazar' END,
    'cotizacion', v.id, to_jsonb(v_vigente), to_jsonb(v), p_motivo_reemplazo);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'version', v_version, 'reemplaza_a', v_vigente.id,
    'advertencia', CASE WHEN v_tenia_solped AND v_vigente.id IS NOT NULL
      THEN 'Esta OT ya tiene una SOLPED. MIP no modifica SAP automáticamente: revise el formulario interno y regularice manualmente si corresponde.'
      END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_cotizacion_invalidar(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_cotizacion_invalidar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_cotizacion_id uuid, p_motivo text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE c core.cotizacion%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'cotizaciones:cargar');

  IF btrim(coalesce(p_motivo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Invalidar una cotización exige motivo','motivo'));
  END IF;

  SELECT * INTO c FROM core.cotizacion WHERE id = p_cotizacion_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Cotización no encontrada'));
  END IF;

  -- Invalidación LÓGICA: el archivo y los metadatos se conservan (cap. 18.1).
  UPDATE core.cotizacion
     SET invalidada = true, vigente = false, motivo_reemplazo = p_motivo, updated_by = p_user_id
   WHERE id = p_cotizacion_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, c.ot_id, 'cotizacion', 'cotizacion_invalidada',
    p_user_id, 'cotizacion', c.id, jsonb_build_object('version', c.version), NULL, p_motivo);
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'invalidar', 'cotizacion',
                                       c.id, to_jsonb(c), NULL, p_motivo);
  PERFORM app.sp_ot_trazabilidad_refrescar(c.ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('invalidada', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_diagnostico_aprobar(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_diagnostico_aprobar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_diagnostico_id uuid, p_observacion text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE d core.diagnostico%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'diagnosticos:aprobar');

  SELECT * INTO d FROM core.diagnostico WHERE id = p_diagnostico_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Diagnóstico no encontrado'));
  END IF;
  IF NOT d.vigente THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE','Sólo se aprueba el diagnóstico vigente'));
  END IF;

  UPDATE core.diagnostico
     SET aprobado_por = p_user_id, aprobado_at = now(),
         observaciones = coalesce(nullif(btrim(coalesce(p_observacion,'')),''), observaciones),
         updated_by = p_user_id
   WHERE id = p_diagnostico_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, d.ot_id, 'diagnostico', 'diagnostico_aprobado',
    p_user_id, 'diagnostico', d.id, NULL, jsonb_build_object('version', d.version), p_observacion);
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'aprobar', 'diagnostico', d.id);
  PERFORM app.sp_ot_trazabilidad_refrescar(d.ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('aprobado', true, 'version', d.version));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_diagnostico_registrar(uuid, uuid, boolean, uuid, text, text, text, text, text, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_diagnostico_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_diagnostico text, p_causa_probable text, p_alcance text, p_trabajo_a_realizar text, p_observaciones text DEFAULT NULL::text, p_lecturas_instrumentos text DEFAULT NULL::text, p_motivo_cambio text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_vigente core.diagnostico%ROWTYPE;
  v core.diagnostico%ROWTYPE;
  v_version INT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'diagnosticos:registrar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  -- Sólo en CREADA/EN DIAGNOSTICO, salvo reapertura o permiso especial (cap. 26.1).
  IF o.estado NOT IN ('creada','en_diagnostico','en_cotizacion','en_trabajo') THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('No se registra diagnóstico con la OT en %s', o.estado)));
  END IF;

  -- Los cuatro campos técnicos son obligatorios (cap. 9, QA-07).
  IF btrim(coalesce(p_diagnostico,'')) = '' OR btrim(coalesce(p_causa_probable,'')) = ''
     OR btrim(coalesce(p_alcance,'')) = '' OR btrim(coalesce(p_trabajo_a_realizar,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Diagnóstico, causa probable, alcance y trabajo a realizar son obligatorios'));
  END IF;

  SELECT * INTO v_vigente FROM core.diagnostico WHERE ot_id = p_ot_id AND vigente;

  -- A partir de la segunda versión el motivo del cambio es obligatorio: es lo que
  -- permite entender después por qué evolucionó el diagnóstico (QA-06).
  IF v_vigente.id IS NOT NULL AND btrim(coalesce(p_motivo_cambio,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Reemplazar el diagnóstico vigente exige explicar el motivo del cambio','motivo_cambio'));
  END IF;

  SELECT coalesce(max(version),0)+1 INTO v_version FROM core.diagnostico WHERE ot_id = p_ot_id;

  -- Bajar la vigencia ANTES de insertar: el índice único parcial garantiza que
  -- nunca haya dos vigentes, así que el orden importa.
  UPDATE core.diagnostico SET vigente = false, updated_by = p_user_id
   WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.diagnostico (
    tenant_id, ot_id, version, vigente, diagnostico, causa_probable, alcance,
    trabajo_a_realizar, observaciones, lecturas_instrumentos, autor_id,
    motivo_cambio, reemplaza_a, created_by, updated_by)
  VALUES (
    p_tenant_id, p_ot_id, v_version, true,
    btrim(p_diagnostico), btrim(p_causa_probable), btrim(p_alcance), btrim(p_trabajo_a_realizar),
    p_observaciones,
    -- Las lecturas de instrumentos se guardan como TEXTO. El MVP no modela
    -- unidades ni series medibles, y hacerlo aquí sería inventar alcance (cap. 9).
    p_lecturas_instrumentos,
    p_user_id, p_motivo_cambio, v_vigente.id, p_user_id, p_user_id)
  RETURNING * INTO v;

  -- El primer diagnóstico saca la OT de 'creada'. Sin este avance la OT se
  -- queda ahí para siempre y la cotización, la ejecución y el cierre se vuelven
  -- inalcanzables (Anexo A). El guardián comprueba que el contexto técnico esté
  -- completo antes de dejar pasar.
  IF o.estado = 'creada' THEN
    PERFORM internal.avanzar_estado_ot(p_tenant_id, p_ot_id, o.estado, 'en_diagnostico',
      p_user_id, 'Primer diagnóstico registrado');
  END IF;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'diagnostico',
    CASE WHEN v_vigente.id IS NULL THEN 'diagnostico_creado' ELSE 'diagnostico_reemplazado' END,
    p_user_id, 'diagnostico', v.id,
    CASE WHEN v_vigente.id IS NOT NULL THEN jsonb_build_object('version', v_vigente.version) END,
    jsonb_build_object('version', v_version), p_motivo_cambio);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id,
    CASE WHEN v_vigente.id IS NULL THEN 'crear' ELSE 'reemplazar' END,
    'diagnostico', v.id, to_jsonb(v_vigente), to_jsonb(v), p_motivo_cambio);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'version', v_version, 'reemplaza_a', v_vigente.id));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ejecucion_iniciar(uuid, uuid, boolean, uuid, uuid, timestamp with time zone, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ejecucion_iniciar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_responsable_id uuid, p_inicio_real timestamp with time zone DEFAULT NULL::timestamp with time zone, p_observaciones text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_inicio TIMESTAMPTZ := coalesce(p_inicio_real, now());
  v_hay_cotiz BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:iniciar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  IF p_responsable_id IS NULL THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El inicio exige responsable de ejecución','responsable_id'));
  END IF;
  IF v_inicio > now() THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El inicio real no puede estar en el futuro','inicio_real'));
  END IF;

  SELECT EXISTS (SELECT 1 FROM core.cotizacion c
                  WHERE c.ot_id = p_ot_id AND c.vigente AND NOT c.invalidada)
    INTO v_hay_cotiz;

  -- El ejecutor debe estar fijado antes de que validar_transicion_ot lo compruebe.
  UPDATE core.orden_trabajo
     SET ejecutor_id = p_responsable_id, fecha_inicio_real = v_inicio, updated_by = p_user_id
   WHERE id = p_ot_id;

  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, 'en_trabajo', p_observaciones);

  INSERT INTO core.ejecucion (tenant_id, ot_id, responsable_id, inicio_real, confirmado_por,
                              inicio_sin_cotizacion, observaciones, created_by, updated_by)
  VALUES (p_tenant_id, p_ot_id, p_responsable_id, v_inicio, p_user_id,
          NOT v_hay_cotiz, p_observaciones, p_user_id, p_user_id)
  ON CONFLICT (ot_id) DO UPDATE
    SET responsable_id = EXCLUDED.responsable_id,
        inicio_real    = EXCLUDED.inicio_real,
        confirmado_por = EXCLUDED.confirmado_por,
        updated_at     = now();

  UPDATE core.orden_trabajo
     SET estado = 'en_trabajo',
         -- Arrancar sin cotización deja pendiente la regularización, siempre.
         regularizacion_pendiente = CASE WHEN NOT v_hay_cotiz THEN true ELSE regularizacion_pendiente END,
         updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, p_ot_id, o.estado, 'en_trabajo', p_user_id,
          CASE WHEN NOT v_hay_cotiz THEN 'Inicio en emergencia, sin cotización vigente' END);

  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id, ve_notas_internas)
  SELECT p_tenant_id, c.id, p_responsable_id, false FROM core.conversacion c WHERE c.ot_id = p_ot_id
  ON CONFLICT DO NOTHING;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'ejecucion_iniciada',
    p_user_id, 'ejecucion', p_ot_id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','en_trabajo','inicio_real', v_inicio,
                       'sin_cotizacion', NOT v_hay_cotiz), p_observaciones);

  PERFORM internal.notificar(p_tenant_id, p_responsable_id, 'ot_asignada',
    format('Inició la ejecución de la OT %s', o.numero_ot), NULL, p_ot_id, 'orden_trabajo', p_ot_id);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'iniciar', 'ejecucion', p_ot_id);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado','en_trabajo', 'inicio_real', v_inicio,
    'regularizacion_pendiente', NOT v_hay_cotiz));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_empresa_ruc_crear(uuid, uuid, boolean, text, text, text, uuid[]); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_empresa_ruc_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ruc text, p_razon_social text, p_nombre_corto text DEFAULT NULL::text, p_sucursal_ids uuid[] DEFAULT NULL::uuid[]) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.empresa_ruc%ROWTYPE; s UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'organizacion:crear');

  IF NOT internal.validar_ruc(p_ruc) THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El RUC no es válido','ruc'));
  END IF;

  INSERT INTO core.empresa_ruc (tenant_id, ruc, razon_social, nombre_corto, created_by, updated_by)
  VALUES (p_tenant_id, regexp_replace(p_ruc,'\D','','g'), btrim(p_razon_social), p_nombre_corto,
          p_user_id, p_user_id)
  RETURNING * INTO v;

  IF p_sucursal_ids IS NOT NULL THEN
    FOREACH s IN ARRAY p_sucursal_ids LOOP
      INSERT INTO core.sucursal_empresa_ruc (tenant_id, sucursal_id, empresa_ruc_id)
      VALUES (p_tenant_id, s, v.id) ON CONFLICT DO NOTHING;
    END LOOP;
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'empresa_ruc', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_empresa_ruc_inactivar(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_empresa_ruc_inactivar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_empresa_ruc_id uuid, p_motivo text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_abiertas INT; v_antes JSONB; v_despues JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'organizacion:editar');

  SELECT to_jsonb(e) INTO v_antes FROM core.empresa_ruc e WHERE e.id = p_empresa_ruc_id;
  IF v_antes IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Empresa/RUC no encontrada'));
  END IF;

  SELECT count(*) INTO v_abiertas
    FROM core.orden_trabajo
   WHERE empresa_ruc_id = p_empresa_ruc_id
     AND estado NOT IN ('cerrada','cancelada') AND deleted_at IS NULL;

  UPDATE core.empresa_ruc SET estado = 'inactivo', updated_by = p_user_id
   WHERE id = p_empresa_ruc_id
  RETURNING to_jsonb(core.empresa_ruc.*) INTO v_despues;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'inactivar', 'empresa_ruc',
                                       p_empresa_ruc_id, v_antes, v_despues, p_motivo);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'inactivada', true,
    'ot_abiertas', v_abiertas,
    'alerta', CASE WHEN v_abiertas > 0
                   THEN format('Quedan %s OT abiertas con esta RUC. Se conservan, pero no podrá usarse en OT nuevas.', v_abiertas)
              END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_incidencia_registrar(uuid, uuid, boolean, uuid, text, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_incidencia_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_descripcion text, p_tipo_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v core.ot_incidencia%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:avanzar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  INSERT INTO core.ot_incidencia (tenant_id, ot_id, tipo_id, descripcion, autor_id)
  VALUES (p_tenant_id, p_ot_id, p_tipo_id, btrim(p_descripcion), p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'incidencia_registrada',
    p_user_id, 'ot_incidencia', v.id, NULL, jsonb_build_object('descripcion', p_descripcion));

  -- Una incidencia es algo sobre lo que el coordinador puede tener que actuar.
  IF o.coordinador_id IS DISTINCT FROM p_user_id THEN
    PERFORM internal.notificar(p_tenant_id, o.coordinador_id, 'incidencia_registrada',
      format('Incidencia en la OT %s', o.numero_ot), p_descripcion, p_ot_id, 'ot_incidencia', v.id);
  END IF;

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_liberacion_registrar(uuid, uuid, boolean, uuid, text, numeric, text, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_liberacion_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_estado text, p_monto numeric, p_observacion text DEFAULT NULL::text, p_orden_compra_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_anterior core.liberacion_historial%ROWTYPE;
  v core.liberacion_historial%ROWTYPE;
  v_nuevo core.estado_liberacion := p_estado::core.estado_liberacion;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:liberacion');

  IF coalesce(p_monto,0) < 0 THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El monto liberado no puede ser negativo','monto'));
  END IF;

  SELECT * INTO v_anterior FROM core.liberacion_historial
   WHERE ot_id = p_ot_id ORDER BY secuencia DESC LIMIT 1;

  -- Cada cambio guarda valor anterior, nuevo, usuario, fecha y observación.
  INSERT INTO core.liberacion_historial (
    tenant_id, ot_id, orden_compra_id, estado_anterior, estado_nuevo,
    monto_anterior, monto_nuevo, observacion, actor_id)
  VALUES (p_tenant_id, p_ot_id,
          coalesce(p_orden_compra_id, (SELECT id FROM core.orden_compra
                                        WHERE ot_id = p_ot_id AND NOT anulada
                                        ORDER BY created_at DESC LIMIT 1)),
          v_anterior.estado_nuevo, v_nuevo,
          v_anterior.monto_nuevo, coalesce(p_monto,0), p_observacion, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'administracion', 'liberacion_actualizada',
    p_user_id, 'liberacion_historial', v.id,
    jsonb_build_object('estado', v_anterior.estado_nuevo, 'monto', v_anterior.monto_nuevo),
    jsonb_build_object('estado', v_nuevo, 'monto', coalesce(p_monto,0)), p_observacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'registrar', 'liberacion',
    p_ot_id, jsonb_build_object('estado', v_anterior.estado_nuevo, 'monto', v_anterior.monto_nuevo),
    jsonb_build_object('estado', v_nuevo, 'monto', coalesce(p_monto,0)), p_observacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado', v_nuevo, 'monto_liberado', coalesce(p_monto,0),
    'estado_administrativo', (SELECT estado_administrativo FROM core.orden_trabajo WHERE id = p_ot_id),
    -- Advertencia que el cap. 31.3 exige no perder de vista.
    'nota','El monto liberado NO equivale al costo final de la OT.'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_mensaje_editar(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_mensaje_editar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_mensaje_id uuid, p_cuerpo text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.mensaje%ROWTYPE; v_ot UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT * INTO v FROM core.mensaje WHERE id = p_mensaje_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Mensaje no encontrado'));
  END IF;
  IF v.autor_id IS DISTINCT FROM p_user_id AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('FORBIDDEN','Sólo el autor puede editar su mensaje'));
  END IF;
  IF v.estado = 'retirado' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','El mensaje fue retirado'));
  END IF;

  UPDATE core.mensaje
     SET cuerpo_anterior = coalesce(cuerpo_anterior, cuerpo),
         cuerpo = btrim(p_cuerpo), estado = 'editado', editado_at = now()
   WHERE id = p_mensaje_id;

  SELECT ot_id INTO v_ot FROM core.conversacion WHERE id = v.conversacion_id;
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'editar', 'mensaje', v.id,
    jsonb_build_object('cuerpo', v.cuerpo), jsonb_build_object('cuerpo', btrim(p_cuerpo)));
  PERFORM app.sp_ot_trazabilidad_refrescar(v_ot, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('editado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_mensaje_publicar(uuid, uuid, boolean, uuid, text, text, uuid, uuid[]); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_mensaje_publicar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_cuerpo text, p_visibilidad text DEFAULT 'canal'::text, p_responde_a uuid DEFAULT NULL::uuid, p_menciones uuid[] DEFAULT NULL::uuid[]) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  c core.conversacion%ROWTYPE;
  o core.orden_trabajo%ROWTYPE;
  v core.mensaje%ROWTYPE;
  pa core.conversacion_participante%ROWTYPE;
  m UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'conversacion:escribir');

  IF btrim(coalesce(p_cuerpo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El mensaje no puede estar vacío','cuerpo'));
  END IF;

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  SELECT * INTO c FROM core.conversacion WHERE ot_id = p_ot_id;
  IF NOT FOUND THEN
    INSERT INTO core.conversacion (tenant_id, ot_id) VALUES (p_tenant_id, p_ot_id) RETURNING * INTO c;
  END IF;

  IF c.solo_lectura AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE','La conversación está en solo lectura porque la OT está cerrada'));
  END IF;

  SELECT * INTO pa FROM core.conversacion_participante
   WHERE conversacion_id = c.id AND usuario_id = p_user_id AND activo;

  IF NOT FOUND AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'FORBIDDEN','No participa en la conversación de esta OT'));
  END IF;
  IF FOUND AND NOT pa.puede_escribir THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'FORBIDDEN','Su acceso a esta conversación es de sólo lectura'));
  END IF;
  -- Una nota interna sólo la publica quien puede verlas (cap. 30.1).
  IF p_visibilidad = 'interna' AND FOUND AND NOT pa.ve_notas_internas AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'FORBIDDEN','No puede publicar notas internas'));
  END IF;

  INSERT INTO core.mensaje (tenant_id, conversacion_id, tipo, visibilidad, cuerpo,
                            responde_a, autor_id, menciones)
  VALUES (p_tenant_id, c.id, 'humano', coalesce(p_visibilidad,'canal')::core.visibilidad_mensaje,
          btrim(p_cuerpo), p_responde_a, p_user_id, coalesce(p_menciones, '{}'))
  RETURNING * INTO v;

  -- Notificar a los participantes; las menciones sólo llegan a quien participa,
  -- que es la forma de garantizar "sólo usuarios con permiso de ver la OT".
  FOR m IN
    SELECT pp.usuario_id FROM core.conversacion_participante pp
     WHERE pp.conversacion_id = c.id AND pp.activo AND pp.usuario_id <> p_user_id
       AND (coalesce(p_visibilidad,'canal') <> 'interna' OR pp.ve_notas_internas)
  LOOP
    PERFORM internal.notificar(p_tenant_id, m, 'mensaje_nuevo',
      format('Nuevo mensaje en la OT %s', o.numero_ot),
      left(btrim(p_cuerpo), 200), p_ot_id, 'mensaje', v.id);
  END LOOP;

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'fecha', v.created_at, 'visibilidad', v.visibilidad));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_mensaje_retirar(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_mensaje_retirar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_mensaje_id uuid, p_motivo text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.mensaje%ROWTYPE; v_ot UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  SELECT * INTO v FROM core.mensaje WHERE id = p_mensaje_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Mensaje no encontrado'));
  END IF;
  IF v.autor_id IS DISTINCT FROM p_user_id AND NOT p_is_super_admin THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('FORBIDDEN','Sólo el autor o un administrador puede retirar el mensaje'));
  END IF;

  UPDATE core.mensaje
     SET estado = 'retirado', retirado_at = now(), retirado_por = p_user_id,
         cuerpo_anterior = coalesce(cuerpo_anterior, cuerpo)
   WHERE id = p_mensaje_id;

  SELECT ot_id INTO v_ot FROM core.conversacion WHERE id = v.conversacion_id;
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'retirar', 'mensaje', v.id,
                                       jsonb_build_object('cuerpo', v.cuerpo), NULL, p_motivo);
  PERFORM app.sp_ot_trazabilidad_refrescar(v_ot, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('retirado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_notificacion_marcar_enviada(uuid, uuid, boolean, uuid, boolean, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_notificacion_marcar_enviada(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_notificacion_id uuid, p_exito boolean, p_error text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  UPDATE core.notificacion
     SET estado = CASE WHEN p_exito THEN 'enviada'::core.estado_notificacion
                       ELSE 'fallida'::core.estado_notificacion END,
         error_envio = p_error
   WHERE id = p_notificacion_id;
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('registrado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_notificacion_marcar_leida(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_notificacion_marcar_leida(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_notificacion_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_n INT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);

  -- Sin id se marcan todas: es el "marcar todo como leído" de la campana.
  UPDATE core.notificacion
     SET leida_at = now(), estado = 'leida'
   WHERE destinatario_id = p_user_id AND leida_at IS NULL
     AND (p_notificacion_id IS NULL OR id = p_notificacion_id);
  GET DIAGNOSTICS v_n = ROW_COUNT;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('marcadas', v_n));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_orden_compra_registrar(uuid, uuid, boolean, uuid, text, date, numeric, text, text, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_orden_compra_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_numero_oc text, p_fecha_oc date DEFAULT NULL::date, p_monto numeric DEFAULT NULL::numeric, p_moneda text DEFAULT 'PEN'::text, p_observacion text DEFAULT NULL::text, p_solped_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v core.orden_compra%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:oc');

  IF btrim(coalesce(p_numero_oc,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Indique el número de OC','numero_oc'));
  END IF;

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  INSERT INTO core.orden_compra (tenant_id, ot_id, solped_id, numero_oc, fecha_oc,
                                 monto, moneda, observacion, registrada_por, created_by, updated_by)
  VALUES (p_tenant_id, p_ot_id,
          coalesce(p_solped_id, (SELECT id FROM core.solped
                                  WHERE ot_id = p_ot_id AND vigente AND NOT anulada LIMIT 1)),
          btrim(p_numero_oc), p_fecha_oc, p_monto, coalesce(p_moneda,'PEN')::core.moneda_codigo,
          p_observacion, p_user_id, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'administracion', 'oc_registrada',
    p_user_id, 'orden_compra', v.id, NULL,
    jsonb_build_object('numero_oc', v.numero_oc, 'monto', p_monto), p_observacion);
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'registrar', 'orden_compra',
                                       v.id, NULL, to_jsonb(v), p_observacion);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'numero_oc', v.numero_oc,
    -- El trigger de estado administrativo ya recalculó el indicador.
    'estado_administrativo', (SELECT estado_administrativo FROM core.orden_trabajo WHERE id = p_ot_id),
    'ot_reabierta', false));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_actualizar(uuid, uuid, boolean, uuid, jsonb); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_actualizar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_payload jsonb) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_antes JSONB; v_despues JSONB; o core.orden_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:editar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado IN ('cerrada','cancelada') THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('Una OT %s no se edita; use reapertura si corresponde', o.estado)));
  END IF;

  SELECT to_jsonb(x) - 'trazabilidad' INTO v_antes FROM core.orden_trabajo x WHERE x.id = p_ot_id;

  UPDATE core.orden_trabajo SET
    sucursal_id           = coalesce((p_payload->>'sucursal_id')::uuid, sucursal_id),
    empresa_ruc_id        = coalesce((p_payload->>'empresa_ruc_id')::uuid, empresa_ruc_id),
    area_id               = coalesce((p_payload->>'area_id')::uuid, area_id),
    cecos_id              = coalesce((p_payload->>'cecos_id')::uuid, cecos_id),
    tipo_mantenimiento_id = coalesce((p_payload->>'tipo_mantenimiento_id')::uuid, tipo_mantenimiento_id),
    tipo_trabajo_id       = coalesce((p_payload->>'tipo_trabajo_id')::uuid, tipo_trabajo_id),
    coordinador_id        = coalesce((p_payload->>'coordinador_id')::uuid, coordinador_id),
    ejecutor_id           = coalesce((p_payload->>'ejecutor_id')::uuid, ejecutor_id),
    updated_by            = p_user_id
  WHERE id = p_ot_id;

  SELECT to_jsonb(x) - 'trazabilidad' INTO v_despues FROM core.orden_trabajo x WHERE x.id = p_ot_id;

  IF (p_payload ? 'ejecutor_id') AND (v_antes->>'ejecutor_id') IS DISTINCT FROM (v_despues->>'ejecutor_id') THEN
    PERFORM internal.notificar(p_tenant_id, (v_despues->>'ejecutor_id')::uuid, 'ot_asignada',
      format('Se le asignó la OT %s', o.numero_ot), NULL, p_ot_id, 'orden_trabajo', p_ot_id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'actualizar', 'orden_trabajo',
                                       p_ot_id, v_antes, v_despues);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', v_despues);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_cambiar_estado(uuid, uuid, boolean, uuid, text, text, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_cambiar_estado(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_nuevo_estado text, p_motivo text DEFAULT NULL::text, p_motivo_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_nuevo core.ot_estado := p_nuevo_estado::core.ot_estado;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:cambiar_estado');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  PERFORM internal.assert_alcance(p_user_id, o.sucursal_id, o.empresa_ruc_id, o.area_id);

  IF o.estado = v_nuevo THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('CONFLICT','La OT ya está en ese estado'));
  END IF;

  -- El Anexo A decide. Si el par no es legal o faltan condiciones, esto lanza.
  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, v_nuevo, p_motivo);

  -- Salir de CERRADA es reapertura y tiene su propio SP; aquí se bloquea para que
  -- nadie se la salte por descuido.
  IF o.estado = 'cerrada' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE',
        'Una OT cerrada se reabre con app.sp_ot_reabrir, que exige permiso y motivo'));
  END IF;

  UPDATE core.orden_trabajo
     SET estado = v_nuevo,
         motivo_cancelacion_id   = CASE WHEN v_nuevo = 'cancelada' THEN p_motivo_id ELSE motivo_cancelacion_id END,
         cancelacion_observacion = CASE WHEN v_nuevo = 'cancelada' THEN p_motivo ELSE cancelacion_observacion END,
         fecha_cancelacion       = CASE WHEN v_nuevo = 'cancelada' THEN now() ELSE fecha_cancelacion END,
         updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo,
                                        motivo_id, motivo_texto, actor_id)
  VALUES (p_tenant_id, p_ot_id, o.estado, v_nuevo, p_motivo_id, p_motivo, p_user_id);

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'estado_cambiado', p_user_id,
    'orden_trabajo', p_ot_id,
    jsonb_build_object('estado', o.estado), jsonb_build_object('estado', v_nuevo), p_motivo);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cambiar_estado', 'orden_trabajo',
    p_ot_id, jsonb_build_object('estado', o.estado), jsonb_build_object('estado', v_nuevo), p_motivo);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado_anterior', o.estado, 'estado', v_nuevo));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_cambiar_prioridad(uuid, uuid, boolean, uuid, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_cambiar_prioridad(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_prioridad text, p_motivo text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_nueva core.prioridad := p_prioridad::core.prioridad;
  v_exige_motivo BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:cambiar_prioridad');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  -- Exige motivo si se BAJA una prioridad crítica/alta, o si se cambia estando ya
  -- en trabajo: son los dos casos que hay que poder justificar después (cap. 25.4).
  -- Comparación por ENUM, no por texto: el orden de declaración es
  -- critica < alta < media < baja, así que "mayor" = menos urgente. Comparar
  -- como texto daría 'alta' < 'baja' alfabéticamente y leería al revés.
  v_exige_motivo :=
    (o.prioridad_tecnica IN ('critica','alta') AND v_nueva > o.prioridad_tecnica)
    OR o.estado = 'en_trabajo';

  IF v_exige_motivo AND btrim(coalesce(p_motivo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Bajar una prioridad crítica/alta o cambiarla en ejecución exige motivo','motivo'));
  END IF;

  UPDATE core.orden_trabajo SET prioridad_tecnica = v_nueva, updated_by = p_user_id WHERE id = p_ot_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'prioridad_cambiada', p_user_id,
    'orden_trabajo', p_ot_id,
    jsonb_build_object('prioridad_tecnica', o.prioridad_tecnica),
    jsonb_build_object('prioridad_tecnica', v_nueva), p_motivo);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cambiar_prioridad', 'orden_trabajo',
    p_ot_id, jsonb_build_object('prioridad_tecnica', o.prioridad_tecnica),
    jsonb_build_object('prioridad_tecnica', v_nueva), p_motivo);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'prioridad_anterior', o.prioridad_tecnica, 'prioridad_tecnica', v_nueva));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_cancelar(uuid, uuid, boolean, uuid, uuid, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_cancelar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_motivo_id uuid, p_observacion text, p_tratamiento_derivadas text DEFAULT 'bloquear'::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_hijas INT;
  h RECORD;
  v_afectadas JSONB := '[]'::jsonb;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:cancelar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF btrim(coalesce(p_observacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La cancelación exige observación libre obligatoria','observacion'));
  END IF;

  SELECT count(*) INTO v_hijas
    FROM core.orden_trabajo
   WHERE ot_padre_id = p_ot_id AND deleted_at IS NULL AND estado NOT IN ('cerrada','cancelada');

  IF v_hijas > 0 AND p_tratamiento_derivadas = 'bloquear' THEN
    -- Se devuelve la lista para que la interfaz pueda mostrarlas y pedir la decisión.
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE',
      format('La OT tiene %s derivada(s) activa(s). Indique si cancelarlas, independizarlas o resolverlas antes.', v_hijas)),
      'data', jsonb_build_object('derivadas_activas', (
        SELECT jsonb_agg(jsonb_build_object('id', h2.id, 'numero', h2.numero_ot, 'estado', h2.estado))
          FROM core.orden_trabajo h2
         WHERE h2.ot_padre_id = p_ot_id AND h2.deleted_at IS NULL
           AND h2.estado NOT IN ('cerrada','cancelada'))));
  END IF;

  FOR h IN SELECT * FROM core.orden_trabajo
            WHERE ot_padre_id = p_ot_id AND deleted_at IS NULL AND estado NOT IN ('cerrada','cancelada')
  LOOP
    IF p_tratamiento_derivadas = 'cancelar' THEN
      -- Cada cancelación exige su propio motivo; se hereda el del padre con nota.
      PERFORM app.sp_ot_cancelar(p_user_id, p_tenant_id, p_is_super_admin, h.id, p_motivo_id,
        format('Cancelada junto con la OT superior %s. %s', o.numero_ot, p_observacion), 'cancelar');
      v_afectadas := v_afectadas || jsonb_build_array(
        jsonb_build_object('numero', h.numero_ot, 'accion', 'cancelada'));
    ELSIF p_tratamiento_derivadas = 'independizar' THEN
      -- Sobrevive a la cancelación del padre sólo porque el usuario lo decidió
      -- expresamente, y la auditoría lo registra (cap. 27.2).
      UPDATE core.orden_trabajo
         SET independizada_de_padre = true, es_bloqueante_para_padre = false, updated_by = p_user_id
       WHERE id = h.id;
      PERFORM internal.registrar_evento_ot(p_tenant_id, h.id, 'ot', 'independizada_de_padre', p_user_id,
        'orden_trabajo', h.id, NULL, jsonb_build_object('padre', o.numero_ot),
        'El padre fue cancelado y se decidió mantenerla activa');
      v_afectadas := v_afectadas || jsonb_build_array(
        jsonb_build_object('numero', h.numero_ot, 'accion', 'independizada'));
    END IF;
  END LOOP;

  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, 'cancelada', p_observacion);

  UPDATE core.orden_trabajo
     SET estado = 'cancelada', motivo_cancelacion_id = p_motivo_id,
         cancelacion_observacion = p_observacion, fecha_cancelacion = now(), updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo,
                                        motivo_id, motivo_texto, actor_id)
  VALUES (p_tenant_id, p_ot_id, o.estado, 'cancelada', p_motivo_id, p_observacion, p_user_id);

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'ot_cancelada', p_user_id,
    'orden_trabajo', p_ot_id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','cancelada','derivadas', v_afectadas), p_observacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cancelar', 'orden_trabajo',
    p_ot_id, jsonb_build_object('estado', o.estado), jsonb_build_object('estado','cancelada'), p_observacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado','cancelada', 'derivadas_afectadas', v_afectadas));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_cerrar(uuid, uuid, boolean, uuid, boolean, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_cerrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_admin_revisado boolean DEFAULT false, p_observacion_pendiente text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v_admin core.estado_administrativo;
  v_hay_pendiente BOOLEAN;
  v_secuencia INT;
  v_cierre core.ot_cierre%ROWTYPE;
  v_hijas JSONB;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:cerrar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  -- Exige revisión aprobada y derivadas bloqueantes resueltas (Anexo A, QA-16).
  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, 'cerrada', NULL);

  v_admin := core.consolidar_estado_administrativo(p_ot_id);
  v_hay_pendiente := v_admin <> 'administracion_completa';

  -- La regla que define el producto: se PUEDE cerrar con pendiente, pero sólo con
  -- confirmación explícita y observación escrita (cap. 31.2, QA-19).
  IF v_hay_pendiente THEN
    IF NOT coalesce(p_admin_revisado,false) THEN
      RETURN jsonb_build_object('ok', false,
        'error', internal.error_jsonb('BUSINESS_RULE',
          format('El seguimiento administrativo está en "%s". Confirme que lo revisó para poder cerrar.', v_admin)),
        'data', jsonb_build_object('estado_administrativo', v_admin,
                                   'requiere_confirmacion', true));
    END IF;
    IF btrim(coalesce(p_observacion_pendiente,'')) = '' THEN
      RETURN jsonb_build_object('ok', false,
        'error', internal.error_jsonb('VALIDATION',
          'Cerrar con pendiente administrativo exige una observación que lo explique','observacion_pendiente'));
    END IF;
  END IF;

  -- Derivadas NO bloqueantes que siguen abiertas: no impiden el cierre, pero se
  -- muestran como pendiente visible (cap. 27.2).
  SELECT coalesce(jsonb_agg(jsonb_build_object('numero', h.numero_ot, 'estado', h.estado)), '[]'::jsonb)
    INTO v_hijas
    FROM core.orden_trabajo h
   WHERE h.ot_padre_id = p_ot_id AND h.deleted_at IS NULL
     AND h.estado NOT IN ('cerrada','cancelada');

  SELECT coalesce(max(secuencia),0)+1 INTO v_secuencia FROM core.ot_cierre WHERE ot_id = p_ot_id;
  UPDATE core.ot_cierre SET vigente = false WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.ot_cierre (
    tenant_id, ot_id, secuencia, vigente, cerrado_por, admin_revisado,
    estado_admin_al_cierre, observacion_pendiente, derivadas_bloqueantes_resueltas)
  VALUES (p_tenant_id, p_ot_id, v_secuencia, true, p_user_id, coalesce(p_admin_revisado,false),
          v_admin, p_observacion_pendiente, true)
  RETURNING * INTO v_cierre;

  UPDATE core.orden_trabajo
     SET estado = 'cerrada', fecha_cierre = now(), updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, p_ot_id, o.estado, 'cerrada', p_user_id, p_observacion_pendiente);

  -- Tras cerrar, la conversación queda en solo lectura (cap. 30.2).
  UPDATE core.conversacion SET solo_lectura = true WHERE ot_id = p_ot_id;

  UPDATE core.seguimiento_administrativo
     SET revisado_por = CASE WHEN p_admin_revisado THEN p_user_id ELSE revisado_por END,
         revisado_at  = CASE WHEN p_admin_revisado THEN now() ELSE revisado_at END,
         observacion  = coalesce(p_observacion_pendiente, observacion),
         updated_by   = p_user_id
   WHERE ot_id = p_ot_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'ot_cerrada', p_user_id,
    'ot_cierre', v_cierre.id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','cerrada','estado_administrativo', v_admin,
                       'con_pendiente', v_hay_pendiente), p_observacion_pendiente);

  PERFORM internal.notificar(p_tenant_id,
    (SELECT solicitante_id FROM core.solicitud_trabajo WHERE id = o.solicitud_origen_id),
    'ot_cerrada', format('La OT %s fue cerrada', o.numero_ot), NULL, p_ot_id, 'orden_trabajo', p_ot_id);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'cerrar', 'orden_trabajo',
    p_ot_id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','cerrada','estado_administrativo', v_admin), p_observacion_pendiente);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  IF o.ot_padre_id IS NOT NULL THEN
    PERFORM app.sp_ot_trazabilidad_refrescar(o.ot_padre_id, true);
  END IF;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado','cerrada',
    'estado_administrativo', v_admin,
    -- El indicador combinado que se muestra en listas y tablero (cap. 14.3):
    -- por ejemplo 'CERRADA - OC PENDIENTE'.
    'indicador', CASE WHEN v_hay_pendiente
                      THEN 'CERRADA - ' || upper(replace(v_admin::text,'_',' '))
                      ELSE 'CERRADA' END,
    'derivadas_no_bloqueantes_abiertas', v_hijas,
    'secuencia_cierre', v_secuencia));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_crear_derivada(uuid, uuid, boolean, uuid, text, uuid, uuid, text, uuid, uuid, uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_crear_derivada(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_padre_id uuid, p_motivo_derivacion text, p_tipo_mantenimiento_id uuid DEFAULT NULL::uuid, p_tipo_trabajo_id uuid DEFAULT NULL::uuid, p_prioridad_tecnica text DEFAULT NULL::text, p_coordinador_id uuid DEFAULT NULL::uuid, p_sucursal_id uuid DEFAULT NULL::uuid, p_empresa_ruc_id uuid DEFAULT NULL::uuid, p_area_id uuid DEFAULT NULL::uuid, p_es_bloqueante boolean DEFAULT true, p_motivo_derivacion_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  p core.orden_trabajo%ROWTYPE;
  v core.orden_trabajo%ROWTYPE;
  v_numero TEXT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:derivar');

  p := internal.ot_visible(p_ot_padre_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF p.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT padre no existe'));
  END IF;
  IF btrim(coalesce(p_motivo_derivacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La derivación exige motivo','motivo_derivacion'));
  END IF;

  v_numero := internal.siguiente_numero(p_tenant_id, 'OT');

  INSERT INTO core.orden_trabajo (
    tenant_id, numero_ot, ot_padre_id, motivo_derivacion_id, motivo_derivacion_texto,
    es_bloqueante_para_padre,
    sucursal_id, empresa_ruc_id, area_id, cecos_id,
    tipo_mantenimiento_id, tipo_trabajo_id, prioridad_tecnica, coordinador_id,
    estado, created_by, updated_by)
  VALUES (
    p_tenant_id, v_numero, p_ot_padre_id, p_motivo_derivacion_id, btrim(p_motivo_derivacion),
    coalesce(p_es_bloqueante, true),
    -- Herencia propuesta desde el padre, sobreescribible por el coordinador.
    coalesce(p_sucursal_id,    p.sucursal_id),
    coalesce(p_empresa_ruc_id, p.empresa_ruc_id),
    coalesce(p_area_id,        p.area_id),
    p.cecos_id,
    coalesce(p_tipo_mantenimiento_id, p.tipo_mantenimiento_id),
    coalesce(p_tipo_trabajo_id,       p.tipo_trabajo_id),
    coalesce(nullif(p_prioridad_tecnica,'')::core.prioridad, p.prioridad_tecnica),
    coalesce(p_coordinador_id, p.coordinador_id),
    'creada', p_user_id, p_user_id)
  RETURNING * INTO v;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, v.id, NULL, 'creada', p_user_id, 'Derivada de ' || p.numero_ot);

  INSERT INTO core.conversacion (tenant_id, ot_id) VALUES (p_tenant_id, v.id);
  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id, ve_notas_internas)
  SELECT p_tenant_id, c.id, coalesce(p_coordinador_id, p.coordinador_id), true
    FROM core.conversacion c WHERE c.ot_id = v.id;
  INSERT INTO core.seguimiento_administrativo (tenant_id, ot_id) VALUES (p_tenant_id, v.id)
  ON CONFLICT (ot_id) DO NOTHING;

  -- El hecho queda en la bitácora de AMBAS: en la hija su origen, en el padre la
  -- derivación. Así ninguna de las dos historias tiene un hueco.
  PERFORM internal.registrar_evento_ot(p_tenant_id, v.id, 'ot', 'derivada_creada', p_user_id,
    'orden_trabajo', v.id, NULL,
    jsonb_build_object('numero', v_numero, 'padre', p.numero_ot, 'bloqueante', coalesce(p_es_bloqueante,true)),
    p_motivo_derivacion);
  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_padre_id, 'ot', 'derivada_generada', p_user_id,
    'orden_trabajo', v.id, NULL,
    jsonb_build_object('numero', v_numero, 'bloqueante', coalesce(p_es_bloqueante,true)),
    p_motivo_derivacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear_derivada', 'orden_trabajo',
                                       v.id, NULL, to_jsonb(v) - 'trazabilidad', p_motivo_derivacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(v.id, true);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_padre_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'numero_ot', v_numero, 'ot_padre', p.numero_ot, 'nivel', v.nivel));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_crear_desde_solicitud(uuid, uuid, boolean, uuid, uuid, uuid, uuid, uuid, text, uuid, boolean, text, uuid, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_crear_desde_solicitud(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid, p_sucursal_id uuid, p_empresa_ruc_id uuid, p_area_id uuid, p_tipo_mantenimiento_id uuid, p_prioridad_tecnica text, p_coordinador_id uuid, p_es_emergencia boolean DEFAULT false, p_emergencia_justificacion text DEFAULT NULL::text, p_tipo_trabajo_id uuid DEFAULT NULL::uuid, p_cecos_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  s core.solicitud_trabajo%ROWTYPE;
  v core.orden_trabajo%ROWTYPE;
  v_numero TEXT;
  v_ruc_estado core.estado_registro;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:crear');
  PERFORM internal.assert_alcance(p_user_id, p_sucursal_id, p_empresa_ruc_id, p_area_id);

  SELECT * INTO s FROM core.solicitud_trabajo WHERE id = p_solicitud_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;
  IF s.estado = 'convertida_en_ot' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('CONFLICT','Esa solicitud ya fue convertida en OT'));
  END IF;
  IF s.estado IN ('rechazada','duplicada') THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE',
        format('Una solicitud %s no se convierte en OT', s.estado)));
  END IF;

  -- No se permite abrir una OT bajo una RUC inactiva (Anexo C, QA-24).
  SELECT estado INTO v_ruc_estado FROM core.empresa_ruc WHERE id = p_empresa_ruc_id;
  IF v_ruc_estado <> 'activo' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','La empresa/RUC está inactiva y no admite OT nuevas','empresa_ruc_id'));
  END IF;

  IF p_es_emergencia AND btrim(coalesce(p_emergencia_justificacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La emergencia exige justificación','emergencia_justificacion'));
  END IF;

  v_numero := internal.siguiente_numero(p_tenant_id, 'OT');

  INSERT INTO core.orden_trabajo (
    tenant_id, numero_ot, solicitud_origen_id,
    sucursal_id, empresa_ruc_id, area_id, cecos_id,
    tipo_mantenimiento_id, tipo_trabajo_id, prioridad_tecnica,
    es_emergencia, emergencia_justificacion, emergencia_declarada_por, emergencia_declarada_at,
    regularizacion_pendiente, coordinador_id, estado, created_by, updated_by)
  VALUES (
    p_tenant_id, v_numero, p_solicitud_id,
    p_sucursal_id, p_empresa_ruc_id, p_area_id, p_cecos_id,
    p_tipo_mantenimiento_id, p_tipo_trabajo_id, p_prioridad_tecnica::core.prioridad,
    coalesce(p_es_emergencia,false), p_emergencia_justificacion,
    CASE WHEN p_es_emergencia THEN p_user_id END,
    CASE WHEN p_es_emergencia THEN now() END,
    -- La emergencia cambia el orden administrativo, no elimina la regularización (cap. 3).
    coalesce(p_es_emergencia,false),
    p_coordinador_id, 'creada', p_user_id, p_user_id)
  RETURNING * INTO v;

  UPDATE core.solicitud_trabajo
     SET estado = 'convertida_en_ot', updated_by = p_user_id,
         fecha_primera_revision = coalesce(fecha_primera_revision, now())
   WHERE id = p_solicitud_id;

  INSERT INTO core.solicitud_decision (tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo, actor_id, comentario)
  VALUES (p_tenant_id, p_solicitud_id, 'aceptar', s.estado, 'convertida_en_ot', p_user_id,
          'Convertida en ' || v_numero);

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, v.id, NULL, 'creada', p_user_id, 'Creada desde ' || s.numero);

  -- Cada OT tiene un canal de conversación (cap. 21.1). Se crea con la OT para que
  -- solicitante y coordinador puedan hablar desde el minuto cero.
  INSERT INTO core.conversacion (tenant_id, ot_id) VALUES (p_tenant_id, v.id);
  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id, ve_notas_internas)
  SELECT p_tenant_id, c.id, s.solicitante_id, false FROM core.conversacion c WHERE c.ot_id = v.id;
  INSERT INTO core.conversacion_participante (tenant_id, conversacion_id, usuario_id, ve_notas_internas)
  SELECT p_tenant_id, c.id, p_coordinador_id, true FROM core.conversacion c WHERE c.ot_id = v.id
  ON CONFLICT DO NOTHING;

  INSERT INTO core.seguimiento_administrativo (tenant_id, ot_id) VALUES (p_tenant_id, v.id)
  ON CONFLICT (ot_id) DO NOTHING;

  PERFORM internal.registrar_evento_ot(p_tenant_id, v.id, 'ot', 'ot_creada', p_user_id,
    'orden_trabajo', v.id, NULL,
    jsonb_build_object('numero', v_numero, 'desde_solicitud', s.numero,
                       'emergencia', coalesce(p_es_emergencia,false)));

  -- Se avisa al solicitante de que su necesidad fue aceptada (cap. 24.4).
  PERFORM internal.notificar(p_tenant_id, s.solicitante_id, 'solicitud_aceptada',
    format('Su solicitud %s fue aceptada', s.numero),
    format('Se generó la orden de trabajo %s.', v_numero), v.id, 'orden_trabajo', v.id);

  IF p_coordinador_id <> p_user_id THEN
    PERFORM internal.notificar(p_tenant_id, p_coordinador_id, 'ot_asignada',
      format('Se le asignó la OT %s', v_numero), s.titulo, v.id, 'orden_trabajo', v.id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'orden_trabajo', v.id,
                                       NULL, to_jsonb(v) - 'trazabilidad');
  PERFORM app.sp_ot_trazabilidad_refrescar(v.id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'numero_ot', v_numero, 'estado', v.estado));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_reabrir(uuid, uuid, boolean, uuid, text, text, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_reabrir(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_motivo_texto text, p_estado_retorno text DEFAULT 'en_trabajo'::text, p_motivo_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  c core.ot_cierre%ROWTYPE;
  v core.ot_reapertura%ROWTYPE;
  v_retorno core.ot_estado := p_estado_retorno::core.ot_estado;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:reabrir');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado <> 'cerrada' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','Sólo se reabre una OT cerrada'));
  END IF;
  IF btrim(coalesce(p_motivo_texto,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La reapertura exige motivo obligatorio','motivo_texto'));
  END IF;

  PERFORM internal.validar_transicion_ot(p_ot_id, 'cerrada', v_retorno, p_motivo_texto);

  SELECT * INTO c FROM core.ot_cierre WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.ot_reapertura (tenant_id, ot_id, cierre_id, motivo_id, motivo_texto,
                                  estado_retorno, reabierta_por)
  VALUES (p_tenant_id, p_ot_id, c.id, p_motivo_id, btrim(p_motivo_texto), v_retorno, p_user_id)
  RETURNING * INTO v;

  -- El cierre deja de ser el vigente, pero la fila permanece con todos sus datos.
  UPDATE core.ot_cierre SET vigente = false WHERE id = c.id;

  -- Aquí sí hay que levantar la guarda: es exactamente el caso legítimo previsto
  -- por el cap. 21.3, "una OT cerrada sólo cambia mediante reapertura auditada".
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);
  UPDATE core.orden_trabajo
     SET estado = v_retorno, fecha_cierre = NULL,
         veces_reabierta = veces_reabierta + 1, updated_by = p_user_id
   WHERE id = p_ot_id;
  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);

  UPDATE core.conversacion SET solo_lectura = false WHERE ot_id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo,
                                        motivo_id, motivo_texto, actor_id)
  VALUES (p_tenant_id, p_ot_id, 'cerrada', v_retorno, p_motivo_id, p_motivo_texto, p_user_id);

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ot', 'ot_reabierta', p_user_id,
    'ot_reapertura', v.id, jsonb_build_object('estado','cerrada','cierre_secuencia', c.secuencia),
    jsonb_build_object('estado', v_retorno), p_motivo_texto);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'reabrir', 'orden_trabajo',
    p_ot_id, jsonb_build_object('estado','cerrada'), jsonb_build_object('estado', v_retorno), p_motivo_texto);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado', v_retorno, 'veces_reabierta', o.veces_reabierta + 1,
    'cierre_conservado', c.secuencia));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_ot_trazabilidad_refrescar(uuid, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_ot_trazabilidad_refrescar(p_ot_id uuid, p_forzar boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_dirty  BOOLEAN;
  v_arbol  JSONB;
  v_padre  UUID;
BEGIN
  SELECT trazabilidad_dirty, ot_padre_id INTO v_dirty, v_padre
    FROM core.orden_trabajo WHERE id = p_ot_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND', 'La OT no existe'));
  END IF;

  IF NOT v_dirty AND NOT p_forzar THEN
    RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('refrescada', false));
  END IF;

  v_arbol := internal.fn_ot_trazabilidad(p_ot_id, 10, false);

  -- Escribir el snapshot no es "modificar la OT" en el sentido del cap. 21.3, así
  -- que la guarda de OT cerrada se levanta explícitamente para esta operación.
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);
  UPDATE core.orden_trabajo
     SET trazabilidad         = v_arbol,
         trazabilidad_dirty   = false,
         trazabilidad_version = trazabilidad_version + 1,
         trazabilidad_at      = now()
   WHERE id = p_ot_id;
  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'refrescada',  true,
    'total_nodos', (v_arbol->'_meta'->>'total_nodos')::int,
    'profundidad', (v_arbol->'_meta'->>'profundidad_arbol')::int));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_pausa_reanudar(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_pausa_reanudar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_observacion text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.ot_pausa%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:pausar');

  SELECT * INTO v FROM core.ot_pausa WHERE ot_id = p_ot_id AND fecha_reanudacion IS NULL;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND','La OT no tiene una pausa vigente'));
  END IF;

  UPDATE core.ot_pausa
     SET fecha_reanudacion = now(), reanudada_por = p_user_id,
         observacion_reanudacion = p_observacion
   WHERE id = v.id
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'pausa_reanudada',
    p_user_id, 'ot_pausa', v.id, jsonb_build_object('fecha_pausa', v.fecha_pausa),
    jsonb_build_object('fecha_reanudacion', v.fecha_reanudacion), p_observacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'fecha_reanudacion', v.fecha_reanudacion, 'condicion','activa'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_pausa_registrar(uuid, uuid, boolean, uuid, text, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_pausa_registrar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_motivo_texto text, p_motivo_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE o core.orden_trabajo%ROWTYPE; v core.ot_pausa%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:pausar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado <> 'en_trabajo' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','Sólo se pausa una OT en trabajo'));
  END IF;
  IF btrim(coalesce(p_motivo_texto,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La pausa exige motivo','motivo_texto'));
  END IF;

  -- No se permite una nueva pausa si hay una vigente: evita intervalos ambiguos
  -- (cap. 29.3, QA-12). El índice único lo garantiza; aquí damos el mensaje claro.
  IF EXISTS (SELECT 1 FROM core.ot_pausa WHERE ot_id = p_ot_id AND fecha_reanudacion IS NULL) THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'CONFLICT','La OT ya tiene una pausa vigente. Reanude antes de volver a pausar'));
  END IF;

  INSERT INTO core.ot_pausa (tenant_id, ot_id, motivo_id, motivo_texto, pausada_por)
  VALUES (p_tenant_id, p_ot_id, p_motivo_id, btrim(p_motivo_texto), p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'pausa_registrada',
    p_user_id, 'ot_pausa', v.id, NULL, jsonb_build_object('fecha_pausa', v.fecha_pausa), p_motivo_texto);

  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  -- La condición 'pausada' la pone el trigger trg_pausa_condicion.
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'fecha_pausa', v.fecha_pausa, 'condicion', 'pausada'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_proveedor_crear(uuid, uuid, boolean, text, text, text, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_proveedor_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_razon_social text, p_ruc text DEFAULT NULL::text, p_contacto text DEFAULT NULL::text, p_telefono text DEFAULT NULL::text, p_email text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.proveedor%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'proveedores:crear');

  IF p_ruc IS NOT NULL AND NOT internal.validar_ruc(p_ruc) THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El RUC del proveedor no es válido','ruc'));
  END IF;

  INSERT INTO core.proveedor (tenant_id, ruc, razon_social, contacto, telefono, email,
                              created_by, updated_by)
  VALUES (p_tenant_id, nullif(regexp_replace(coalesce(p_ruc,''),'\D','','g'),''),
          btrim(p_razon_social), p_contacto, p_telefono, p_email, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'proveedor', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_rol_asignar_permisos(uuid, uuid, boolean, uuid, text[]); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_rol_asignar_permisos(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_rol_id uuid, p_permiso_codigos text[]) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_antes JSONB; v_despues JSONB; c TEXT; v_permiso UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'roles:editar');

  SELECT coalesce(jsonb_agg(p.codigo ORDER BY p.codigo), '[]'::jsonb) INTO v_antes
    FROM core.rol_permiso rp JOIN core.permiso p ON p.id = rp.permiso_id
   WHERE rp.rol_id = p_rol_id;

  DELETE FROM core.rol_permiso WHERE rol_id = p_rol_id;
  FOREACH c IN ARRAY coalesce(p_permiso_codigos, ARRAY[]::TEXT[]) LOOP
    SELECT id INTO v_permiso FROM core.permiso WHERE codigo = c;
    IF v_permiso IS NOT NULL THEN
      INSERT INTO core.rol_permiso (rol_id, permiso_id) VALUES (p_rol_id, v_permiso)
      ON CONFLICT DO NOTHING;
    END IF;
  END LOOP;

  SELECT coalesce(jsonb_agg(p.codigo ORDER BY p.codigo), '[]'::jsonb) INTO v_despues
    FROM core.rol_permiso rp JOIN core.permiso p ON p.id = rp.permiso_id
   WHERE rp.rol_id = p_rol_id;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'asignar_permisos', 'rol', p_rol_id,
                                       jsonb_build_object('permisos', v_antes),
                                       jsonb_build_object('permisos', v_despues));
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('permisos', v_despues));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_solicitud_crear(uuid, uuid, boolean, text, text, text, uuid, uuid, text, text, boolean); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_solicitud_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_titulo text, p_descripcion text, p_lugar text, p_area_id uuid, p_impacto_operativo_id uuid DEFAULT NULL::uuid, p_impacto_comentario text DEFAULT NULL::text, p_prioridad_percibida text DEFAULT NULL::text, p_enviar boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $_$
DECLARE
  v core.solicitud_trabajo%ROWTYPE;
  v_empresa UUID; v_sucursal UUID; v_numero TEXT;
  v_requiere_comentario BOOLEAN;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'solicitudes:crear');

  -- El área determina la empresa/RUC; la sucursal se toma de la primera asociada.
  SELECT a.empresa_ruc_id INTO v_empresa
    FROM core.area a WHERE a.id = p_area_id AND a.deleted_at IS NULL;
  IF v_empresa IS NULL THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND','El área indicada no existe','area_id'));
  END IF;

  -- El usuario sólo puede reportar dentro de su alcance (cap. 24.1, "Errores").
  PERFORM internal.assert_alcance(p_user_id, NULL, v_empresa, p_area_id);

  SELECT se.sucursal_id INTO v_sucursal
    FROM core.sucursal_empresa_ruc se WHERE se.empresa_ruc_id = v_empresa LIMIT 1;

  -- El ítem 'Otro' del catálogo de impacto exige comentario (cap. 24.3).
  SELECT requiere_comentario INTO v_requiere_comentario
    FROM core.catalogo_item WHERE id = p_impacto_operativo_id;
  IF coalesce(v_requiere_comentario,false) AND btrim(coalesce(p_impacto_comentario,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Ese impacto operativo exige un comentario','impacto_comentario'));
  END IF;

  -- La descripción no puede ser sólo espacios o un carácter repetido (cap. 24.3).
  IF btrim(p_descripcion) ~ '^(.)\1*$' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La descripción debe explicar la necesidad','descripcion'));
  END IF;

  v_numero := internal.siguiente_numero(p_tenant_id, 'ST');

  INSERT INTO core.solicitud_trabajo (
    tenant_id, numero, estado, titulo, descripcion, lugar,
    impacto_operativo_id, impacto_comentario, prioridad_percibida,
    area_id, empresa_ruc_id, sucursal_id, solicitante_id, fecha_envio,
    created_by, updated_by)
  VALUES (
    p_tenant_id, v_numero,
    CASE WHEN p_enviar THEN 'enviada'::core.solicitud_estado ELSE 'borrador'::core.solicitud_estado END,
    btrim(p_titulo), btrim(p_descripcion), btrim(p_lugar),
    p_impacto_operativo_id, p_impacto_comentario,
    nullif(p_prioridad_percibida,'')::core.prioridad,
    p_area_id, v_empresa, v_sucursal, p_user_id,
    CASE WHEN p_enviar THEN now() END,
    p_user_id, p_user_id)
  RETURNING * INTO v;

  -- Un borrador no notifica ni crea OT (cap. 24.2).
  IF p_enviar THEN
    PERFORM internal.notificar_coordinadores(
      p_tenant_id, p_area_id, 'solicitud_nueva',
      'Nueva solicitud ' || v_numero,
      v.titulo, 'solicitud_trabajo', v.id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'solicitud_trabajo',
                                       v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $_$;


--
-- Name: sp_solicitud_decidir(uuid, uuid, boolean, uuid, text, text, uuid, uuid, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_solicitud_decidir(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid, p_tipo text, p_comentario text DEFAULT NULL::text, p_motivo_id uuid DEFAULT NULL::uuid, p_destinatario_id uuid DEFAULT NULL::uuid, p_solicitud_principal_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  s core.solicitud_trabajo%ROWTYPE;
  v_nuevo core.solicitud_estado;
  v_tipo  core.tipo_decision_solicitud := p_tipo::core.tipo_decision_solicitud;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'solicitudes:decidir');

  SELECT * INTO s FROM core.solicitud_trabajo WHERE id = p_solicitud_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;

  -- Una solicitud convertida en OT es inmutable como origen (cap. 24.2).
  IF s.estado IN ('convertida_en_ot','rechazada','duplicada') THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE',
        format('Una solicitud %s ya no admite decisiones', s.estado)));
  END IF;

  v_nuevo := CASE v_tipo
    WHEN 'observar'         THEN 'observada'::core.solicitud_estado
    WHEN 'rechazar'         THEN 'rechazada'::core.solicitud_estado
    WHEN 'derivar'          THEN 'derivada'::core.solicitud_estado
    WHEN 'marcar_duplicada' THEN 'duplicada'::core.solicitud_estado
    ELSE NULL END;

  IF v_nuevo IS NULL THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION',
        'Decisión no válida aquí. Para aceptar use la conversión a OT.','tipo'));
  END IF;

  -- Rechazar exige motivo (cap. 7.3); observar exige el comentario que verá el
  -- solicitante; derivar exige destinatario; duplicada exige la principal.
  IF v_tipo = 'rechazar' AND p_motivo_id IS NULL AND btrim(coalesce(p_comentario,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','El rechazo exige motivo','motivo_id'));
  END IF;
  IF v_tipo = 'observar' AND btrim(coalesce(p_comentario,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La observación exige un comentario para el solicitante','comentario'));
  END IF;
  IF v_tipo = 'derivar' AND p_destinatario_id IS NULL THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Derivar exige indicar el destinatario','destinatario_id'));
  END IF;
  IF v_tipo = 'marcar_duplicada' THEN
    IF p_solicitud_principal_id IS NULL THEN
      RETURN jsonb_build_object('ok', false,
        'error', internal.error_jsonb('VALIDATION','Marcar duplicada exige la solicitud principal','solicitud_principal_id'));
    END IF;
    IF p_solicitud_principal_id = p_solicitud_id THEN
      RETURN jsonb_build_object('ok', false,
        'error', internal.error_jsonb('VALIDATION','Una solicitud no puede ser duplicada de sí misma'));
    END IF;
  END IF;

  UPDATE core.solicitud_trabajo
     SET estado = v_nuevo,
         motivo_rechazo_id = CASE WHEN v_tipo = 'rechazar' THEN p_motivo_id ELSE motivo_rechazo_id END,
         observacion_actual = coalesce(p_comentario, observacion_actual),
         solicitud_principal_id = CASE WHEN v_tipo = 'marcar_duplicada'
                                       THEN p_solicitud_principal_id ELSE solicitud_principal_id END,
         coordinador_revisor_id = CASE WHEN v_tipo = 'derivar' THEN p_destinatario_id
                                       ELSE coalesce(coordinador_revisor_id, p_user_id) END,
         fecha_primera_revision = coalesce(fecha_primera_revision, now()),
         updated_by = p_user_id
   WHERE id = p_solicitud_id;

  INSERT INTO core.solicitud_decision (
    tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo,
    motivo_id, comentario, destinatario_id, solicitud_relacionada_id, actor_id)
  VALUES (p_tenant_id, p_solicitud_id, v_tipo, s.estado, v_nuevo,
          p_motivo_id, p_comentario, p_destinatario_id, p_solicitud_principal_id, p_user_id);

  -- Se notifica a quien tiene que actuar, no por cada cambio menor (cap. 19).
  IF v_tipo IN ('observar','rechazar') THEN
    PERFORM internal.notificar(p_tenant_id, s.solicitante_id, 'solicitud_' || p_tipo,
      format('Su solicitud %s fue %s', s.numero, v_nuevo), p_comentario,
      NULL, 'solicitud_trabajo', s.id);
  ELSIF v_tipo = 'derivar' THEN
    PERFORM internal.notificar(p_tenant_id, p_destinatario_id, 'solicitud_derivada',
      format('Se le derivó la solicitud %s', s.numero), p_comentario,
      NULL, 'solicitud_trabajo', s.id);
  END IF;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, p_tipo, 'solicitud_trabajo',
    p_solicitud_id, jsonb_build_object('estado', s.estado),
    jsonb_build_object('estado', v_nuevo), p_comentario);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado', v_nuevo, 'decision', p_tipo));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_solicitud_enviar(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_solicitud_enviar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE s core.solicitud_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  SELECT * INTO s FROM core.solicitud_trabajo WHERE id = p_solicitud_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;
  IF s.estado NOT IN ('borrador','observada') THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','Sólo se envía una solicitud en borrador u observada'));
  END IF;

  UPDATE core.solicitud_trabajo
     SET estado = 'enviada', fecha_envio = coalesce(fecha_envio, now()), updated_by = p_user_id
   WHERE id = p_solicitud_id;

  INSERT INTO core.solicitud_decision (tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo, actor_id)
  VALUES (p_tenant_id, p_solicitud_id, 'reenviar', s.estado, 'enviada', p_user_id);

  PERFORM internal.notificar_coordinadores(p_tenant_id, s.area_id, 'solicitud_nueva',
    'Solicitud ' || s.numero || ' enviada', s.titulo, 'solicitud_trabajo', s.id);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('estado','enviada'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_solicitud_tomar_revision(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_solicitud_tomar_revision(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solicitud_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE s core.solicitud_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'solicitudes:decidir');

  SELECT * INTO s FROM core.solicitud_trabajo WHERE id = p_solicitud_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Solicitud no encontrada'));
  END IF;
  IF s.estado <> 'enviada' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','Sólo se toma en revisión una solicitud enviada'));
  END IF;

  UPDATE core.solicitud_trabajo
     SET estado = 'en_revision',
         coordinador_revisor_id = p_user_id,
         fecha_primera_revision = coalesce(fecha_primera_revision, now()),
         updated_by = p_user_id
   WHERE id = p_solicitud_id;

  INSERT INTO core.solicitud_decision (tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo, actor_id)
  VALUES (p_tenant_id, p_solicitud_id, 'tomar_revision', s.estado, 'en_revision', p_user_id);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('estado','en_revision'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_solped_anular(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_solped_anular(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solped_id uuid, p_motivo text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE s core.solped%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:solped');

  IF btrim(coalesce(p_motivo,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Anular la SOLPED exige motivo','motivo'));
  END IF;

  SELECT * INTO s FROM core.solped WHERE id = p_solped_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','SOLPED no encontrada'));
  END IF;

  UPDATE core.solped
     SET anulada = true, vigente = false, estado_integracion = 'reemplazada_anulada',
         motivo_anulacion = p_motivo, anulada_por = p_user_id, anulada_at = now(),
         updated_by = p_user_id
   WHERE id = p_solped_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, s.ot_id, 'administracion', 'solped_anulada',
    p_user_id, 'solped', s.id, jsonb_build_object('estado', s.estado_integracion, 'numero_sap', s.numero_sap),
    jsonb_build_object('estado','reemplazada_anulada'), p_motivo);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'anular', 'solped',
                                       s.id, to_jsonb(s), NULL, p_motivo);
  PERFORM app.sp_ot_trazabilidad_refrescar(s.ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'anulada', true,
    'nota', CASE WHEN s.numero_sap IS NOT NULL
      THEN 'El documento SAP no se modificó. MIP sólo anuló su registro interno; gestione la anulación en SAP manualmente.' END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_solped_marcar_lista(uuid, uuid, boolean, uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_solped_marcar_lista(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solped_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE s core.solped%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:solped');

  SELECT * INTO s FROM core.solped WHERE id = p_solped_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','SOLPED no encontrada'));
  END IF;
  IF s.anulada THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('BUSINESS_RULE','La SOLPED está anulada'));
  END IF;
  IF s.estado_integracion <> 'borrador' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE', format('La SOLPED está en %s', s.estado_integracion)));
  END IF;

  UPDATE core.solped SET estado_integracion = 'lista_para_enviar', updated_by = p_user_id
   WHERE id = p_solped_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, s.ot_id, 'administracion', 'solped_lista',
    p_user_id, 'solped', s.id, jsonb_build_object('estado','borrador'),
    jsonb_build_object('estado','lista_para_enviar'));
  PERFORM app.sp_ot_trazabilidad_refrescar(s.ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'estado_integracion','lista_para_enviar',
    -- Se dice la verdad al usuario en lugar de fingir una integración que no existe.
    'nota','El conector SAP no está definido todavía (cap. 22.4). Registre el número SAP manualmente cuando Compras lo informe.'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_solped_preparar(uuid, uuid, boolean, uuid, jsonb, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_solped_preparar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_formulario jsonb DEFAULT '{}'::jsonb, p_cotizacion_id uuid DEFAULT NULL::uuid, p_numero_interno text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v core.solped%ROWTYPE;
  v_version INT;
  v_cotiz core.cotizacion%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:solped');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;

  SELECT * INTO v_cotiz FROM core.cotizacion
   WHERE id = coalesce(p_cotizacion_id,
                       (SELECT id FROM core.cotizacion
                         WHERE ot_id = p_ot_id AND vigente AND NOT invalidada LIMIT 1));

  SELECT coalesce(max(version),0)+1 INTO v_version FROM core.solped WHERE ot_id = p_ot_id;
  UPDATE core.solped SET vigente = false, updated_by = p_user_id
   WHERE ot_id = p_ot_id AND vigente AND NOT anulada;

  INSERT INTO core.solped (
    tenant_id, ot_id, version, vigente, numero_interno, referencia_externa,
    estado_integracion, formulario, cotizacion_id, monto, moneda,
    fecha_solped, created_by, updated_by)
  VALUES (
    p_tenant_id, p_ot_id, v_version, true,
    coalesce(p_numero_interno, o.numero_ot || '-SP' || v_version),
    -- Clave de idempotencia: si algún día el conector no sabe si SAP creó el
    -- documento, se consulta por esta referencia en vez de arriesgar un duplicado
    -- (cap. 22.3, estado CONFIRMACION PENDIENTE).
    o.numero_ot || '-' || v_version || '-' || substr(gen_random_uuid()::text, 1, 8),
    'borrador', coalesce(p_formulario,'{}'::jsonb), v_cotiz.id,
    v_cotiz.monto, coalesce(v_cotiz.moneda,'PEN'), current_date, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'administracion', 'solped_preparada',
    p_user_id, 'solped', v.id, NULL,
    jsonb_build_object('version', v_version, 'numero_interno', v.numero_interno));
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'preparar', 'solped', v.id, NULL, to_jsonb(v));
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'version', v_version, 'numero_interno', v.numero_interno,
    'estado_integracion', v.estado_integracion,
    'referencia_externa', v.referencia_externa));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_solped_registrar_numero_sap(uuid, uuid, boolean, uuid, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_solped_registrar_numero_sap(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_solped_id uuid, p_numero_sap text, p_observacion text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE s core.solped%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'administrativo:solped');

  IF btrim(coalesce(p_numero_sap,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Indique el número SAP','numero_sap'));
  END IF;

  SELECT * INTO s FROM core.solped WHERE id = p_solped_id AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','SOLPED no encontrada'));
  END IF;

  -- Corregir un número ya confirmado es posible, pero SIEMPRE por flujo auditado
  -- (cap. 22.2): queda el valor anterior y el nuevo.
  UPDATE core.solped
     SET numero_sap = btrim(p_numero_sap), estado_integracion = 'creada_en_sap',
         fecha_solped = coalesce(fecha_solped, current_date), updated_by = p_user_id
   WHERE id = p_solped_id;

  PERFORM internal.registrar_evento_ot(p_tenant_id, s.ot_id, 'administracion', 'solped_numero_sap',
    p_user_id, 'solped', s.id,
    jsonb_build_object('numero_sap', s.numero_sap, 'estado', s.estado_integracion),
    jsonb_build_object('numero_sap', btrim(p_numero_sap), 'estado','creada_en_sap'), p_observacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'registrar_numero_sap', 'solped',
    s.id, jsonb_build_object('numero_sap', s.numero_sap),
    jsonb_build_object('numero_sap', btrim(p_numero_sap)), p_observacion);

  PERFORM app.sp_ot_trazabilidad_refrescar(s.ot_id, true);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'numero_sap', btrim(p_numero_sap), 'estado_integracion','creada_en_sap'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_sucursal_crear(uuid, uuid, boolean, text, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_sucursal_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_codigo text, p_nombre text, p_direccion text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.sucursal%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'organizacion:crear');

  INSERT INTO core.sucursal (tenant_id, codigo, nombre, direccion, created_by, updated_by)
  VALUES (p_tenant_id, upper(btrim(p_codigo)), btrim(p_nombre), p_direccion, p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'sucursal', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_tipo_trabajo_crear(uuid, uuid, boolean, text, text, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_tipo_trabajo_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_codigo text, p_nombre text, p_padre_id uuid DEFAULT NULL::uuid, p_descripcion text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.tipo_trabajo%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'catalogos:crear');

  INSERT INTO core.tipo_trabajo (tenant_id, codigo, nombre, padre_id, descripcion, created_by, updated_by)
  VALUES (p_tenant_id, upper(btrim(p_codigo)), btrim(p_nombre), p_padre_id, p_descripcion,
          p_user_id, p_user_id)
  RETURNING * INTO v;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'tipo_trabajo', v.id, NULL, to_jsonb(v));
  RETURN jsonb_build_object('ok', true, 'data', to_jsonb(v));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_trabajo_realizado_declarar(uuid, uuid, boolean, uuid, text, timestamp with time zone, uuid, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_trabajo_realizado_declarar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_descripcion text, p_fecha_termino timestamp with time zone DEFAULT NULL::timestamp with time zone, p_resultado_id uuid DEFAULT NULL::uuid, p_resultado_texto text DEFAULT NULL::text, p_observaciones text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  v core.trabajo_realizado%ROWTYPE;
  v_version INT;
  v_termino TIMESTAMPTZ := coalesce(p_fecha_termino, now());
  v_inicio  TIMESTAMPTZ;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ejecucion:declarar_trabajo');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF btrim(coalesce(p_descripcion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','Describa el trabajo realizado','descripcion'));
  END IF;

  SELECT inicio_real INTO v_inicio FROM core.ejecucion WHERE ot_id = p_ot_id;
  IF v_inicio IS NOT NULL AND v_termino < v_inicio THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','El término no puede ser anterior al inicio','fecha_termino'));
  END IF;

  -- Valida también que no haya una pausa vigente sin resolver (QA-13).
  PERFORM internal.validar_transicion_ot(p_ot_id, o.estado, 'trabajo_realizado', NULL);

  SELECT coalesce(max(version),0)+1 INTO v_version FROM core.trabajo_realizado WHERE ot_id = p_ot_id;
  UPDATE core.trabajo_realizado SET vigente = false, updated_by = p_user_id
   WHERE ot_id = p_ot_id AND vigente;

  INSERT INTO core.trabajo_realizado (
    tenant_id, ot_id, version, vigente, descripcion, resultado_id, resultado_texto,
    fecha_termino, observaciones, declarado_por, created_by, updated_by)
  VALUES (p_tenant_id, p_ot_id, v_version, true, btrim(p_descripcion),
          p_resultado_id, p_resultado_texto, v_termino, p_observaciones,
          p_user_id, p_user_id, p_user_id)
  RETURNING * INTO v;

  UPDATE core.ejecucion SET termino_real = v_termino, updated_by = p_user_id WHERE ot_id = p_ot_id;
  UPDATE core.orden_trabajo
     SET estado = 'trabajo_realizado', fecha_termino_real = v_termino, updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id)
  VALUES (p_tenant_id, p_ot_id, o.estado, 'trabajo_realizado', p_user_id);

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'trabajo_declarado',
    p_user_id, 'trabajo_realizado', v.id, jsonb_build_object('estado', o.estado),
    jsonb_build_object('estado','trabajo_realizado','version', v_version,'termino', v_termino));

  -- El coordinador DEBE revisar: es lo siguiente que tiene que ocurrir (cap. 14.1).
  PERFORM internal.notificar(p_tenant_id, o.coordinador_id, 'trabajo_realizado',
    format('La OT %s está declarada como trabajo realizado', o.numero_ot),
    'Requiere su revisión para poder cerrarse.', p_ot_id, 'trabajo_realizado', v.id);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'declarar', 'trabajo_realizado',
                                       v.id, NULL, to_jsonb(v));
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'id', v.id, 'version', v_version, 'estado','trabajo_realizado'));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_trabajo_revisar(uuid, uuid, boolean, uuid, text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_trabajo_revisar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_ot_id uuid, p_resultado text, p_observacion text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  o core.orden_trabajo%ROWTYPE;
  t core.trabajo_realizado%ROWTYPE;
  v_res core.resultado_revision := p_resultado::core.resultado_revision;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'ot:revisar');

  o := internal.ot_visible(p_ot_id, p_user_id, p_tenant_id, p_is_super_admin);
  IF o.id IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','La OT no existe'));
  END IF;
  IF o.estado <> 'trabajo_realizado' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'BUSINESS_RULE','Sólo se revisa una OT en trabajo realizado'));
  END IF;

  SELECT * INTO t FROM core.trabajo_realizado WHERE ot_id = p_ot_id AND vigente;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('NOT_FOUND','No hay trabajo realizado vigente que revisar'));
  END IF;

  -- Devolver a corrección exige observación: el ejecutor tiene que saber qué
  -- corregir (cap. 14.2, QA-14).
  IF v_res = 'correccion_solicitada' AND btrim(coalesce(p_observacion,'')) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','Solicitar correcciones exige registrar la observación','observacion'));
  END IF;

  UPDATE core.trabajo_realizado
     SET resultado_revision = v_res, revision_observacion = p_observacion,
         revisado_por = p_user_id, revisado_at = now(), updated_by = p_user_id
   WHERE id = t.id;

  IF v_res = 'correccion_solicitada' THEN
    UPDATE core.orden_trabajo SET estado = 'en_trabajo', fecha_termino_real = NULL, updated_by = p_user_id
     WHERE id = p_ot_id;
    INSERT INTO core.ot_estado_historial (tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
    VALUES (p_tenant_id, p_ot_id, 'trabajo_realizado', 'en_trabajo', p_user_id, p_observacion);

    PERFORM internal.notificar(p_tenant_id, coalesce(t.declarado_por, o.ejecutor_id),
      'correccion_solicitada', format('Se solicitaron correcciones en la OT %s', o.numero_ot),
      p_observacion, p_ot_id, 'trabajo_realizado', t.id);
  END IF;

  PERFORM internal.registrar_evento_ot(p_tenant_id, p_ot_id, 'ejecucion', 'trabajo_revisado',
    p_user_id, 'trabajo_realizado', t.id, NULL,
    jsonb_build_object('resultado', v_res), p_observacion);

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'revisar', 'trabajo_realizado',
                                       t.id, NULL, jsonb_build_object('resultado', v_res), p_observacion);
  PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'resultado', v_res,
    'estado', CASE WHEN v_res = 'correccion_solicitada' THEN 'en_trabajo' ELSE o.estado END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_trazabilidad_refrescar_pendientes(integer); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_trazabilidad_refrescar_pendientes(p_limite integer DEFAULT 500) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  v_ot      RECORD;
  v_contador INT := 0;
BEGIN
  -- De las hojas hacia la raíz: refrescar primero las derivadas evita rehacer el
  -- árbol del padre dos veces.
  FOR v_ot IN
    SELECT id FROM core.orden_trabajo
     WHERE trazabilidad_dirty = true
     ORDER BY nivel DESC, created_at
     LIMIT p_limite
  LOOP
    PERFORM app.sp_ot_trazabilidad_refrescar(v_ot.id, true);
    v_contador := v_contador + 1;
  END LOOP;

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('refrescadas', v_contador));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_usuario_actualizar(uuid, uuid, boolean, uuid, text, text, text, text, text, text[], text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_usuario_actualizar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_usuario_id uuid, p_nombres text DEFAULT NULL::text, p_apellidos text DEFAULT NULL::text, p_cargo text DEFAULT NULL::text, p_documento text DEFAULT NULL::text, p_telefono text DEFAULT NULL::text, p_rol_codigos text[] DEFAULT NULL::text[], p_estado text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE
  u core.usuario%ROWTYPE;
  v_antes JSONB;
  c TEXT;
  v_rol UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:editar');

  SELECT * INTO u FROM core.usuario
   WHERE id = p_usuario_id AND deleted_at IS NULL
     AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','El usuario no existe'));
  END IF;
  v_antes := to_jsonb(u);

  IF p_nombres IS NOT NULL AND btrim(p_nombres) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('VALIDATION','Los nombres no pueden quedar vacíos','nombres'));
  END IF;
  IF p_apellidos IS NOT NULL AND btrim(p_apellidos) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('VALIDATION','Los apellidos no pueden quedar vacíos','apellidos'));
  END IF;

  UPDATE core.usuario SET
    nombres   = coalesce(nullif(btrim(coalesce(p_nombres,'')),''), nombres),
    apellidos = coalesce(nullif(btrim(coalesce(p_apellidos,'')),''), apellidos),
    -- Cargo, documento y teléfono SÍ se pueden vaciar: son opcionales.
    cargo     = CASE WHEN p_cargo     IS NULL THEN cargo     ELSE nullif(btrim(p_cargo),'')     END,
    documento = CASE WHEN p_documento IS NULL THEN documento ELSE nullif(btrim(p_documento),'') END,
    telefono  = CASE WHEN p_telefono  IS NULL THEN telefono  ELSE nullif(btrim(p_telefono),'')  END,
    estado    = coalesce(nullif(p_estado,'')::core.estado_usuario, estado),
    updated_by = p_user_id
  WHERE id = p_usuario_id;

  -- Reasignar roles sólo si vienen: un array vacío deja al usuario sin ninguno,
  -- y eso tiene que poder hacerse a propósito.
  IF p_rol_codigos IS NOT NULL THEN
    DELETE FROM core.usuario_rol WHERE usuario_id = p_usuario_id;
    FOREACH c IN ARRAY p_rol_codigos LOOP
      SELECT id INTO v_rol FROM core.rol
       WHERE codigo = c AND (tenant_id IS NULL OR tenant_id = u.tenant_id)
       ORDER BY tenant_id NULLS LAST LIMIT 1;
      IF v_rol IS NOT NULL THEN
        INSERT INTO core.usuario_rol (usuario_id, rol_id) VALUES (p_usuario_id, v_rol)
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END IF;

  SELECT * INTO u FROM core.usuario WHERE id = p_usuario_id;
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'editar', 'usuario', p_usuario_id,
                                       v_antes, to_jsonb(u));

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('id', u.id, 'actualizado', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_usuario_crear(uuid, uuid, boolean, text, text, text, text, text[], text, text, text, jsonb); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_usuario_crear(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_email text, p_nombres text, p_apellidos text, p_password text, p_rol_codigos text[] DEFAULT NULL::text[], p_cargo text DEFAULT NULL::text, p_documento text DEFAULT NULL::text, p_telefono text DEFAULT NULL::text, p_alcance jsonb DEFAULT '[]'::jsonb) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v core.usuario%ROWTYPE; c TEXT; a JSONB; v_rol UUID;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:crear');

  IF length(coalesce(p_password,'')) < 10 THEN
    RETURN jsonb_build_object('ok', false,
      'error', internal.error_jsonb('VALIDATION','La contraseña debe tener al menos 10 caracteres','password'));
  END IF;

  INSERT INTO core.usuario (tenant_id, email, password_hash, nombres, apellidos,
                            documento, telefono, cargo, created_by, updated_by)
  VALUES (p_tenant_id, lower(btrim(p_email)), crypt(p_password, gen_salt('bf', 12)),
          btrim(p_nombres), btrim(p_apellidos), p_documento, p_telefono, p_cargo,
          p_user_id, p_user_id)
  RETURNING * INTO v;

  IF p_rol_codigos IS NOT NULL THEN
    FOREACH c IN ARRAY p_rol_codigos LOOP
      SELECT id INTO v_rol FROM core.rol
       WHERE codigo = c AND (tenant_id = p_tenant_id OR tenant_id IS NULL)
       ORDER BY tenant_id NULLS LAST LIMIT 1;
      IF v_rol IS NOT NULL THEN
        INSERT INTO core.usuario_rol (usuario_id, rol_id, created_by)
        VALUES (v.id, v_rol, p_user_id) ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
  END IF;

  -- Alcance organizacional: [{sucursal_id, empresa_ruc_id, area_id}, …]. NULL en
  -- un nivel significa "todo ese nivel" (cap. 4.1).
  FOR a IN SELECT * FROM jsonb_array_elements(coalesce(p_alcance,'[]'::jsonb)) LOOP
    INSERT INTO core.usuario_alcance (tenant_id, usuario_id, sucursal_id, empresa_ruc_id, area_id, created_by)
    VALUES (p_tenant_id, v.id,
            nullif(a->>'sucursal_id','')::uuid,
            nullif(a->>'empresa_ruc_id','')::uuid,
            nullif(a->>'area_id','')::uuid, p_user_id);
  END LOOP;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'crear', 'usuario', v.id,
                                       NULL, to_jsonb(v) - 'password_hash');
  RETURN app.fn_auth_perfil(v.id);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_usuario_inactivar(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_usuario_inactivar(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_usuario_id uuid, p_motivo text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_antes JSONB; v_ot INT;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:editar');

  SELECT to_jsonb(u) - 'password_hash' INTO v_antes FROM core.usuario u WHERE u.id = p_usuario_id;
  IF v_antes IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','Usuario no encontrado'));
  END IF;

  SELECT count(*) INTO v_ot
    FROM core.orden_trabajo
   WHERE (coordinador_id = p_usuario_id OR ejecutor_id = p_usuario_id)
     AND estado NOT IN ('cerrada','cancelada') AND deleted_at IS NULL;

  UPDATE core.usuario SET estado = 'inactivo', updated_by = p_user_id WHERE id = p_usuario_id;

  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'inactivar', 'usuario',
                                       p_usuario_id, v_antes, NULL, p_motivo);
  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object(
    'inactivado', true,
    'ot_asignadas_abiertas', v_ot,
    'alerta', CASE WHEN v_ot > 0
                   THEN format('El usuario tiene %s OT abiertas asignadas; reasígnelas.', v_ot) END));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: sp_usuario_restablecer_password(uuid, uuid, boolean, uuid, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.sp_usuario_restablecer_password(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean, p_usuario_id uuid, p_password_nueva text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE u core.usuario%ROWTYPE;
BEGIN
  PERFORM internal.assert_acceso_tenant(p_user_id, p_tenant_id, p_is_super_admin);
  PERFORM internal.assert_permiso(p_user_id, 'usuarios:editar');

  IF length(coalesce(p_password_nueva,'')) < 10 THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(
      'VALIDATION','La contraseña necesita al menos 10 caracteres','password_nueva'));
  END IF;

  SELECT * INTO u FROM core.usuario
   WHERE id = p_usuario_id AND deleted_at IS NULL
     AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb('NOT_FOUND','El usuario no existe'));
  END IF;

  UPDATE core.usuario
     SET password_hash = crypt(p_password_nueva, gen_salt('bf', 12)),
         -- Un restablecimiento levanta cualquier bloqueo por intentos fallidos.
         intentos_fallidos = 0, bloqueado_hasta = NULL,
         updated_by = p_user_id
   WHERE id = p_usuario_id;

  -- Sin valores: una auditoría de contraseñas no guarda contraseñas.
  PERFORM internal.registrar_auditoria(p_user_id, p_tenant_id, 'restablecer_password', 'usuario', p_usuario_id);

  RETURN jsonb_build_object('ok', true, 'data', jsonb_build_object('restablecida', true));
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', internal.error_jsonb(SQLSTATE, SQLERRM));
END; $$;


--
-- Name: bloquear_mutacion_bitacora(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.bloquear_mutacion_bitacora() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'core.ot_evento es append-only: no admite % (cap. 18.1)', TG_OP
    USING ERRCODE = 'MIP01';
END; $$;


--
-- Name: consolidar_estado_administrativo(uuid); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.consolidar_estado_administrativo(p_ot_id uuid) RETURNS core.estado_administrativo
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_solped    core.solped%ROWTYPE;
  v_tiene_oc  BOOLEAN;
  v_liberacion core.estado_liberacion;
  v_estado    core.estado_administrativo;
BEGIN
  SELECT * INTO v_solped
    FROM core.solped
   WHERE ot_id = p_ot_id AND vigente = true AND anulada = false
   LIMIT 1;

  SELECT EXISTS (SELECT 1 FROM core.orden_compra WHERE ot_id = p_ot_id AND anulada = false)
    INTO v_tiene_oc;

  -- Por secuencia, no por created_at: ver la nota en core.liberacion_historial.
  SELECT estado_nuevo INTO v_liberacion
    FROM core.liberacion_historial
   WHERE ot_id = p_ot_id
   ORDER BY secuencia DESC
   LIMIT 1;

  IF v_solped.id IS NULL THEN
    RETURN 'sin_solped';
  ELSIF v_solped.estado_integracion <> 'creada_en_sap' OR v_solped.numero_sap IS NULL THEN
    RETURN 'solped_pendiente';
  END IF;

  -- A partir de aquí la SOLPED está confirmada en SAP.
  IF NOT v_tiene_oc THEN
    RETURN 'oc_pendiente';
  END IF;

  v_estado := CASE v_liberacion
                WHEN 'total'   THEN 'administracion_completa'::core.estado_administrativo
                WHEN 'parcial' THEN 'liberacion_parcial'::core.estado_administrativo
                WHEN 'pendiente' THEN 'liberacion_pendiente'::core.estado_administrativo
                ELSE 'oc_registrada'::core.estado_administrativo
              END;
  RETURN v_estado;
END; $$;


--
-- Name: guardar_ot_cerrada(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.guardar_ot_cerrada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF OLD.estado <> 'cerrada' THEN
    RETURN NEW;
  END IF;

  IF coalesce(current_setting('mip.permitir_update_cerrada', true), 'off') = 'on' THEN
    RETURN NEW;
  END IF;

  -- Exentos: seguimiento administrativo (QA-20) y el snapshot de trazabilidad.
  IF ROW(NEW.*) IS NOT DISTINCT FROM ROW(OLD.*) THEN
    RETURN NEW;
  END IF;

  IF NEW.estado             IS DISTINCT FROM OLD.estado
     OR NEW.fecha_cierre    IS DISTINCT FROM OLD.fecha_cierre
     OR NEW.fecha_inicio_real  IS DISTINCT FROM OLD.fecha_inicio_real
     OR NEW.fecha_termino_real IS DISTINCT FROM OLD.fecha_termino_real
     OR NEW.coordinador_id  IS DISTINCT FROM OLD.coordinador_id
     OR NEW.ejecutor_id     IS DISTINCT FROM OLD.ejecutor_id
     OR NEW.prioridad_tecnica IS DISTINCT FROM OLD.prioridad_tecnica
     OR NEW.ot_padre_id     IS DISTINCT FROM OLD.ot_padre_id
     OR NEW.es_emergencia   IS DISTINCT FROM OLD.es_emergencia
  THEN
    RAISE EXCEPTION 'Una OT cerrada sólo puede modificarse mediante reapertura auditada'
      USING ERRCODE = 'MIP01';
  END IF;

  RETURN NEW;
END; $$;


--
-- Name: refrescar_condicion_ot(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.refrescar_condicion_ot() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_ot_id     UUID := coalesce(NEW.ot_id, OLD.ot_id);
  v_hay_pausa BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM core.ot_pausa WHERE ot_id = v_ot_id AND fecha_reanudacion IS NULL
  ) INTO v_hay_pausa;

  UPDATE core.orden_trabajo
     SET condicion = CASE WHEN v_hay_pausa THEN 'pausada'::core.ot_condicion
                          ELSE 'activa'::core.ot_condicion END
   WHERE id = v_ot_id
     AND condicion IS DISTINCT FROM (CASE WHEN v_hay_pausa THEN 'pausada'::core.ot_condicion
                                          ELSE 'activa'::core.ot_condicion END);

  RETURN coalesce(NEW, OLD);
END; $$;


--
-- Name: refrescar_estado_administrativo(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.refrescar_estado_administrativo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_ot_id  UUID := coalesce(NEW.ot_id, OLD.ot_id);
  v_estado core.estado_administrativo;
  v_monto  NUMERIC(14,2);
BEGIN
  v_estado := core.consolidar_estado_administrativo(v_ot_id);

  SELECT coalesce(monto_nuevo, 0) INTO v_monto
    FROM core.liberacion_historial
   WHERE ot_id = v_ot_id
   ORDER BY secuencia DESC
   LIMIT 1;

  -- El seguimiento existe siempre que la OT exista; se crea perezosamente aquí.
  INSERT INTO core.seguimiento_administrativo (tenant_id, ot_id, estado_consolidado, monto_liberado_total)
  SELECT ot.tenant_id, ot.id, v_estado, coalesce(v_monto, 0)
    FROM core.orden_trabajo ot WHERE ot.id = v_ot_id
  ON CONFLICT (ot_id) DO UPDATE
    SET estado_consolidado   = EXCLUDED.estado_consolidado,
        monto_liberado_total = EXCLUDED.monto_liberado_total,
        updated_at           = now();

  -- Actualizar la OT no debe chocar con la guarda de OT cerrada: el cap. 14.3 dice
  -- justamente que actualizar OC/liberación no reabre la OT.
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);
  UPDATE core.orden_trabajo SET estado_administrativo = v_estado WHERE id = v_ot_id;
  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);

  RETURN coalesce(NEW, OLD);
END; $$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END; $$;


--
-- Name: trg_dirty_ot_self(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.trg_dirty_ot_self() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Si lo único que cambió fueron las columnas del propio snapshot, no hay nada
  -- de negocio que reflejar: se sale sin marcar nada. Sin esto, cada refresco
  -- volvería a ensuciar la fila que acaba de limpiar.
  IF TG_OP = 'UPDATE' THEN
    IF (to_jsonb(NEW) - 'trazabilidad' - 'trazabilidad_dirty'
                      - 'trazabilidad_version' - 'trazabilidad_at' - 'updated_at')
       IS NOT DISTINCT FROM
       (to_jsonb(OLD) - 'trazabilidad' - 'trazabilidad_dirty'
                      - 'trazabilidad_version' - 'trazabilidad_at' - 'updated_at')
    THEN
      RETURN NEW;
    END IF;
  END IF;

  PERFORM internal.marcar_ot_dirty(NEW.id);        -- esta OT y toda su cadena de ancestros
  PERFORM internal.marcar_ot_dirty_hijas(NEW.id);  -- las hijas, que embeben el resumen del padre

  -- Al reasignar el padre, el árbol del padre ANTERIOR también deja de ser válido.
  IF TG_OP = 'UPDATE' AND OLD.ot_padre_id IS DISTINCT FROM NEW.ot_padre_id THEN
    PERFORM internal.marcar_ot_dirty(OLD.ot_padre_id);
  END IF;

  RETURN NEW;
END; $$;


--
-- Name: trg_dirty_por_conversacion(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.trg_dirty_por_conversacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_ot UUID;
BEGIN
  SELECT ot_id INTO v_ot FROM core.conversacion
   WHERE id = coalesce(NEW.conversacion_id, OLD.conversacion_id);
  PERFORM internal.marcar_ot_dirty(v_ot);
  RETURN coalesce(NEW, OLD);
END; $$;


--
-- Name: trg_dirty_por_organizacion(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.trg_dirty_por_organizacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  v_col TEXT := TG_ARGV[0];
  r RECORD;
BEGIN
  -- Un UPDATE que sólo toca la marca de tiempo no cambia nada del árbol.
  IF TG_OP = 'UPDATE'
     AND (to_jsonb(OLD) - 'updated_at' - 'updated_by')
       = (to_jsonb(NEW) - 'updated_at' - 'updated_by') THEN
    RETURN NULL;
  END IF;

  FOR r IN EXECUTE
    format('SELECT id FROM core.orden_trabajo WHERE %I = $1 AND deleted_at IS NULL', v_col)
    USING NEW.id
  LOOP
    -- marcar_ot_dirty sube por la cadena de ancestros, que también embeben el
    -- contexto organizacional de sus descendientes.
    PERFORM internal.marcar_ot_dirty(r.id);
  END LOOP;
  RETURN NULL;
END; $_$;


--
-- Name: trg_dirty_por_ot_id(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.trg_dirty_por_ot_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM internal.marcar_ot_dirty(coalesce(NEW.ot_id, OLD.ot_id));
  RETURN coalesce(NEW, OLD);
END; $$;


--
-- Name: trg_dirty_por_solicitud(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.trg_dirty_por_solicitud() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_ot UUID;
BEGIN
  SELECT id INTO v_ot FROM core.orden_trabajo
   WHERE solicitud_origen_id = coalesce(NEW.id, OLD.id);
  PERFORM internal.marcar_ot_dirty(v_ot);
  RETURN coalesce(NEW, OLD);
END; $$;


--
-- Name: trg_dirty_por_solicitud_hija(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.trg_dirty_por_solicitud_hija() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_ot UUID;
BEGIN
  SELECT id INTO v_ot FROM core.orden_trabajo
   WHERE solicitud_origen_id = coalesce(NEW.solicitud_id, OLD.solicitud_id);
  PERFORM internal.marcar_ot_dirty(v_ot);
  RETURN coalesce(NEW, OLD);
END; $$;


--
-- Name: validar_jerarquia_ot(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.validar_jerarquia_ot() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_ancestro UUID := NEW.ot_padre_id;
  v_nivel    INT  := 0;
  v_saltos   INT  := 0;
BEGIN
  IF NEW.ot_padre_id IS NULL THEN
    NEW.nivel := 0;
    RETURN NEW;
  END IF;

  IF NEW.ot_padre_id = NEW.id THEN
    RAISE EXCEPTION 'Una OT no puede ser padre de sí misma' USING ERRCODE = 'MIP01';
  END IF;

  -- Subimos por la cadena de padres. Si volvemos a encontrar a NEW.id, hay ciclo.
  WHILE v_ancestro IS NOT NULL LOOP
    v_saltos := v_saltos + 1;
    IF v_ancestro = NEW.id THEN
      RAISE EXCEPTION 'La jerarquía de OT derivadas no admite ciclos' USING ERRCODE = 'MIP01';
    END IF;
    -- Cinturón de seguridad ante datos corruptos preexistentes: sin esto, un ciclo
    -- ya grabado colgaría el bucle en lugar de fallar.
    IF v_saltos > 100 THEN
      RAISE EXCEPTION 'Jerarquía de OT demasiado profunda o corrupta' USING ERRCODE = 'MIP01';
    END IF;
    v_nivel := v_saltos;
    SELECT ot_padre_id INTO v_ancestro FROM core.orden_trabajo WHERE id = v_ancestro;
  END LOOP;

  NEW.nivel := v_nivel;
  RETURN NEW;
END; $$;


--
-- Name: assert_acceso_tenant(uuid, uuid, boolean); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.assert_acceso_tenant(p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
DECLARE v_tenant_user UUID; v_super BOOLEAN; v_estado core.estado_usuario;
BEGIN
  IF p_is_super_admin THEN RETURN; END IF;
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no autenticado' USING ERRCODE = '42501';
  END IF;

  SELECT tenant_id, is_super_admin, estado INTO v_tenant_user, v_super, v_estado
    FROM core.usuario WHERE id = p_user_id AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Usuario no existe' USING ERRCODE = '42501';
  END IF;
  IF v_estado <> 'activo' THEN
    RAISE EXCEPTION 'Usuario inactivo o bloqueado' USING ERRCODE = '42501';
  END IF;
  IF v_super THEN RETURN; END IF;
  IF internal.es_acceso_global(p_user_id, false) THEN RETURN; END IF;

  IF v_tenant_user IS NULL OR v_tenant_user <> p_tenant_id THEN
    RAISE EXCEPTION 'Sin acceso al tenant indicado' USING ERRCODE = '42501';
  END IF;
END; $$;


--
-- Name: assert_alcance(uuid, uuid, uuid, uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.assert_alcance(p_user_id uuid, p_sucursal_id uuid, p_empresa_ruc_id uuid, p_area_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
DECLARE v_super BOOLEAN;
BEGIN
  SELECT is_super_admin INTO v_super FROM core.usuario WHERE id = p_user_id AND deleted_at IS NULL;
  IF coalesce(v_super, false) THEN RETURN; END IF;
  IF internal.es_acceso_global(p_user_id, false) THEN RETURN; END IF;

  -- Sin filas de alcance el usuario no está restringido a nivel organizacional:
  -- su límite es el tenant, que ya validó assert_acceso_tenant.
  IF NOT EXISTS (SELECT 1 FROM core.usuario_alcance WHERE usuario_id = p_user_id) THEN
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM core.usuario_alcance a
     WHERE a.usuario_id = p_user_id
       AND (a.sucursal_id    IS NULL OR p_sucursal_id    IS NULL OR a.sucursal_id    = p_sucursal_id)
       AND (a.empresa_ruc_id IS NULL OR p_empresa_ruc_id IS NULL OR a.empresa_ruc_id = p_empresa_ruc_id)
       AND (a.area_id        IS NULL OR p_area_id        IS NULL OR a.area_id        = p_area_id))
  THEN
    RAISE EXCEPTION 'Fuera del alcance organizacional autorizado' USING ERRCODE = '42501';
  END IF;
END; $$;


--
-- Name: assert_permiso(uuid, text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.assert_permiso(p_user_id uuid, p_permiso text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
DECLARE v_super BOOLEAN;
BEGIN
  SELECT is_super_admin INTO v_super FROM core.usuario WHERE id = p_user_id AND deleted_at IS NULL;
  IF coalesce(v_super, false) THEN RETURN; END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM core.usuario_rol ur
      JOIN core.rol_permiso rp ON rp.rol_id = ur.rol_id
      JOIN core.permiso p      ON p.id = rp.permiso_id
     WHERE ur.usuario_id = p_user_id AND p.codigo = p_permiso)
  THEN
    RAISE EXCEPTION 'Permiso denegado: %', p_permiso USING ERRCODE = '42501';
  END IF;
END; $$;


--
-- Name: avanzar_estado_ot(uuid, uuid, core.ot_estado, core.ot_estado, uuid, text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.avanzar_estado_ot(p_tenant_id uuid, p_ot_id uuid, p_desde core.ot_estado, p_hacia core.ot_estado, p_user_id uuid, p_motivo text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
BEGIN
  IF p_desde = p_hacia THEN RETURN; END IF;

  PERFORM internal.validar_transicion_ot(p_ot_id, p_desde, p_hacia, p_motivo);

  UPDATE core.orden_trabajo
     SET estado = p_hacia, updated_by = p_user_id
   WHERE id = p_ot_id;

  INSERT INTO core.ot_estado_historial (
    tenant_id, ot_id, estado_anterior, estado_nuevo, actor_id, motivo_texto)
  VALUES (p_tenant_id, p_ot_id, p_desde, p_hacia, p_user_id, p_motivo);

  PERFORM internal.registrar_evento_ot(
    p_tenant_id, p_ot_id, 'ot', 'estado_cambiado', p_user_id, 'orden_trabajo', p_ot_id,
    jsonb_build_object('estado', p_desde), jsonb_build_object('estado', p_hacia), p_motivo);
END; $$;


--
-- Name: claves_configurables(); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.claves_configurables() RETURNS text[]
    LANGUAGE sql IMMUTABLE
    AS $$
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


--
-- Name: codigo_error(text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.codigo_error(p_sqlstate text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT CASE p_sqlstate
    WHEN 'MIP01' THEN 'VALIDATION'
    WHEN 'MIP02' THEN 'NOT_FOUND'
    WHEN 'MIP03' THEN 'CONFLICT'
    WHEN 'MIP04' THEN 'BUSINESS_RULE'
    WHEN '42501' THEN 'FORBIDDEN'
    WHEN 'P0001' THEN 'VALIDATION'      -- raise_exception sin ERRCODE explícito
    WHEN 'P0002' THEN 'NOT_FOUND'       -- no_data_found
    WHEN '23505' THEN 'CONFLICT'        -- unique_violation
    WHEN '23503' THEN 'CONFLICT'        -- foreign_key_violation
    WHEN '23514' THEN 'VALIDATION'      -- check_violation
    WHEN '23502' THEN 'VALIDATION'      -- not_null_violation
    WHEN '22P02' THEN 'VALIDATION'      -- invalid_text_representation
    ELSE 'INTERNAL_ERROR'
  END;
$$;


--
-- Name: config(uuid, text, jsonb); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.config(p_tenant_id uuid, p_clave text, p_default jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT coalesce((SELECT valor FROM core.tenant_configuracion
                    WHERE tenant_id = p_tenant_id AND clave = p_clave), p_default);
$$;


--
-- Name: error_jsonb(text, text, text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.error_jsonb(p_code text, p_message text, p_field text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE sql IMMUTABLE
    AS $_$
  SELECT jsonb_strip_nulls(jsonb_build_object(
    -- Si llega un SQLSTATE crudo (5 caracteres) se traduce; si llega ya un código
    -- semántico ('NOT_FOUND', 'FORBIDDEN'...) se respeta tal cual.
    'code',    CASE WHEN p_code ~ '^[0-9A-Z]{5}$' THEN internal.codigo_error(p_code) ELSE p_code END,
    'message', p_message,
    'field',   p_field,
    'sqlstate', CASE WHEN p_code ~ '^[0-9A-Z]{5}$' THEN p_code END));
$_$;


--
-- Name: es_acceso_global(uuid, boolean); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.es_acceso_global(p_user_id uuid, p_is_super_admin boolean) RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
BEGIN
  IF p_is_super_admin THEN RETURN true; END IF;
  IF p_user_id IS NULL THEN RETURN false; END IF;
  RETURN EXISTS (
    SELECT 1 FROM core.usuario u
      JOIN core.usuario_rol ur ON ur.usuario_id = u.id
      JOIN core.rol r          ON r.id = ur.rol_id
     WHERE u.id = p_user_id AND u.deleted_at IS NULL AND u.estado = 'activo'
       AND r.scope IN ('global','global_restricted'));
END; $$;


--
-- Name: fn_adjuntos_de(text, uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_adjuntos_de(p_entidad_tipo text, p_entidad_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id',       a.id,
           'nombre',   a.nombre,
           'tipo',     a.tipo,
           'etapa',    a.etapa,
           'mime',     a.mime_type,
           'tamano',   a.tamano_bytes,
           'estado',   a.estado,
           'autor',    u.nombres || ' ' || u.apellidos,
           'fecha',    a.created_at
         ) ORDER BY a.created_at, a.id), '[]'::jsonb)
  FROM core.adjunto a
  LEFT JOIN core.usuario u ON u.id = a.autor_id
  WHERE a.entidad_tipo = p_entidad_tipo AND a.entidad_id = p_entidad_id
    AND a.estado = 'vigente';
$$;


--
-- Name: fn_ot_administrativo(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_administrativo(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT jsonb_build_object(
    'estado_consolidado', coalesce(sa.estado_consolidado, o.estado_administrativo),
    'monto_liberado_total', coalesce(sa.monto_liberado_total, 0),
    'moneda',             coalesce(sa.moneda, 'PEN'),
    'revisado_por',       rv.nombres || ' ' || rv.apellidos,
    'revisado_at',        sa.revisado_at,
    'observacion',        sa.observacion,
    'solped', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', s.id, 'version', s.version, 'vigente', s.vigente AND NOT s.anulada,
               'numero_interno', s.numero_interno,
               -- Referencia no editable sin flujo auditado (cap. 22.2)
               'numero_sap',     s.numero_sap,
               'referencia_externa', s.referencia_externa,
               'estado_integracion', s.estado_integracion,
               'formulario',     s.formulario,
               'monto', s.monto, 'moneda', s.moneda, 'fecha', s.fecha_solped,
               'cotizacion_id',  s.cotizacion_id,
               'mensaje_sap',    s.mensaje_sap, 'intentos', s.intentos,
               -- Anulación LÓGICA: el registro permanece con motivo (cap. 15.1, QA-30)
               'anulada', s.anulada, 'motivo_anulacion', s.motivo_anulacion,
               'reemplaza_a', s.reemplaza_a,
               'creada_at', s.created_at
             ) ORDER BY s.version)
        FROM core.solped s WHERE s.ot_id = p_ot_id), '[]'::jsonb),
    'oc', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', oc.id, 'numero', oc.numero_oc, 'fecha', oc.fecha_oc,
               'monto', oc.monto, 'moneda', oc.moneda,
               'observacion', oc.observacion, 'anulada', oc.anulada,
               'solped_id', oc.solped_id,
               'registrada_por', ou.nombres || ' ' || ou.apellidos,
               'registrada_at', oc.created_at
             ) ORDER BY oc.created_at, oc.id)
        FROM core.orden_compra oc LEFT JOIN core.usuario ou ON ou.id = oc.registrada_por
       WHERE oc.ot_id = p_ot_id), '[]'::jsonb),
    'liberaciones', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', l.id,
               'estado_anterior', l.estado_anterior, 'estado_nuevo', l.estado_nuevo,
               -- Cada cambio guarda valor anterior y nuevo (cap. 31.3, QA-21)
               'monto_anterior', l.monto_anterior, 'monto_nuevo', l.monto_nuevo,
               'moneda', l.moneda, 'observacion', l.observacion,
               'actor', lu.nombres || ' ' || lu.apellidos, 'fecha', l.created_at,
               'secuencia', l.secuencia
             ) ORDER BY l.secuencia)
        FROM core.liberacion_historial l LEFT JOIN core.usuario lu ON lu.id = l.actor_id
       WHERE l.ot_id = p_ot_id), '[]'::jsonb)
  )
  FROM core.orden_trabajo o
  LEFT JOIN core.seguimiento_administrativo sa ON sa.ot_id = o.id
  LEFT JOIN core.usuario rv ON rv.id = sa.revisado_por
  WHERE o.id = p_ot_id;
$$;


--
-- Name: fn_ot_cabecera(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_cabecera(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT jsonb_build_object(
    'id',                  o.id,
    'numero',              o.numero_ot,
    'estado',              o.estado,
    'condicion',           o.condicion,
    'estado_administrativo', o.estado_administrativo,
    'prioridad_tecnica',   o.prioridad_tecnica,
    'es_emergencia',       o.es_emergencia,
    'emergencia', CASE WHEN o.es_emergencia THEN jsonb_build_object(
                         'justificacion', o.emergencia_justificacion,
                         'declarada_por', eu.nombres || ' ' || eu.apellidos,
                         'declarada_at',  o.emergencia_declarada_at,
                         -- La emergencia cambia el orden administrativo, no elimina
                         -- la regularización posterior (cap. 3, principio 5).
                         'regularizacion_pendiente', o.regularizacion_pendiente) END,
    'tipo_mantenimiento',  tm.nombre,
    'tipo_trabajo',        tt.nombre,
    'nivel',               o.nivel,
    'es_derivada',         o.ot_padre_id IS NOT NULL,
    'es_bloqueante_para_padre', o.es_bloqueante_para_padre,
    'coordinador',         co.nombres || ' ' || co.apellidos,
    'ejecutor',            ej.nombres || ' ' || ej.apellidos,
    'fechas', jsonb_build_object(
      'creacion',    o.fecha_creacion,
      'inicio_real', o.fecha_inicio_real,
      'termino_real', o.fecha_termino_real,
      'cierre',      o.fecha_cierre,
      'cancelacion', o.fecha_cancelacion),
    'veces_reabierta', o.veces_reabierta,
    'cancelacion', CASE WHEN o.estado = 'cancelada' THEN jsonb_build_object(
                          'motivo',      cc.nombre,
                          'observacion', o.cancelacion_observacion,
                          'fecha',       o.fecha_cancelacion) END
  )
  FROM core.orden_trabajo o
  LEFT JOIN core.usuario co       ON co.id = o.coordinador_id
  LEFT JOIN core.usuario ej       ON ej.id = o.ejecutor_id
  LEFT JOIN core.usuario eu       ON eu.id = o.emergencia_declarada_por
  LEFT JOIN core.catalogo_item tm ON tm.id = o.tipo_mantenimiento_id
  LEFT JOIN core.tipo_trabajo  tt ON tt.id = o.tipo_trabajo_id
  LEFT JOIN core.catalogo_item cc ON cc.id = o.motivo_cancelacion_id
  WHERE o.id = p_ot_id;
$$;


--
-- Name: fn_ot_cierre(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_cierre(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT jsonb_build_object(
    'trabajo_realizado', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', t.id, 'version', t.version, 'vigente', t.vigente,
               'descripcion', t.descripcion,
               'resultado', coalesce(cr.nombre, t.resultado_texto),
               'fecha_termino', t.fecha_termino,
               'observaciones', t.observaciones,
               'declarado_por', dp.nombres || ' ' || dp.apellidos,
               'revision', jsonb_build_object(
                 'resultado',   t.resultado_revision,
                 'observacion', t.revision_observacion,
                 'revisor',     rv.nombres || ' ' || rv.apellidos,
                 'fecha',       t.revisado_at),
               'conformidad_solicitante', jsonb_build_object(
                 'estado',     t.conformidad,
                 'comentario', t.conformidad_comentario,
                 'fecha',      t.conformidad_at),
               'adjuntos', internal.fn_adjuntos_de('trabajo_realizado', t.id)
             ) ORDER BY t.version)
        FROM core.trabajo_realizado t
        LEFT JOIN core.usuario dp       ON dp.id = t.declarado_por
        LEFT JOIN core.usuario rv       ON rv.id = t.revisado_por
        LEFT JOIN core.catalogo_item cr ON cr.id = t.resultado_id
       WHERE t.ot_id = p_ot_id), '[]'::jsonb),
    'cierres', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', c.id, 'secuencia', c.secuencia, 'vigente', c.vigente,
               'fecha', c.fecha_cierre,
               'cerrado_por', cu.nombres || ' ' || cu.apellidos,
               'admin_revisado', c.admin_revisado,
               'estado_admin_al_cierre', c.estado_admin_al_cierre,
               -- Cierre con pendiente administrativo: observación obligatoria (cap. 31.2, QA-19)
               'observacion_pendiente', c.observacion_pendiente,
               'derivadas_bloqueantes_resueltas', c.derivadas_bloqueantes_resueltas
             ) ORDER BY c.secuencia)
        FROM core.ot_cierre c LEFT JOIN core.usuario cu ON cu.id = c.cerrado_por
       WHERE c.ot_id = p_ot_id), '[]'::jsonb),
    'reaperturas', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', r.id, 'fecha', r.created_at,
               'motivo', coalesce(cm.nombre, r.motivo_texto),
               'motivo_texto', r.motivo_texto,
               'estado_retorno', r.estado_retorno,
               'reabierta_por', ru.nombres || ' ' || ru.apellidos,
               'cierre_revertido', r.cierre_id
             ) ORDER BY r.created_at, r.id)
        FROM core.ot_reapertura r
        LEFT JOIN core.usuario ru       ON ru.id = r.reabierta_por
        LEFT JOIN core.catalogo_item cm ON cm.id = r.motivo_id
       WHERE r.ot_id = p_ot_id), '[]'::jsonb)
  );
$$;


--
-- Name: fn_ot_conversacion(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_conversacion(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT jsonb_build_object(
    'id',           c.id,
    'solo_lectura', coalesce(c.solo_lectura, false),
    'participantes', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'usuario_id', pu.id,
               'nombre', pu.nombres || ' ' || pu.apellidos,
               'puede_escribir', pp.puede_escribir,
               've_notas_internas', pp.ve_notas_internas,
               'activo', pp.activo
             ) ORDER BY pp.created_at, pp.usuario_id)
        FROM core.conversacion_participante pp
        JOIN core.usuario pu ON pu.id = pp.usuario_id
       WHERE pp.conversacion_id = c.id), '[]'::jsonb),
    'mensajes', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', m.id, 'tipo', m.tipo, 'visibilidad', m.visibilidad, 'estado', m.estado,
               'cuerpo', CASE WHEN m.estado = 'retirado' THEN NULL ELSE m.cuerpo END,
               'responde_a', m.responde_a,
               'autor', mu.nombres || ' ' || mu.apellidos,
               'editado', m.editado_at IS NOT NULL,
               'retirado', m.estado = 'retirado',
               'fecha', m.created_at,
               'adjuntos', internal.fn_adjuntos_de('mensaje', m.id)
             ) ORDER BY m.created_at, m.id)
        FROM core.mensaje m LEFT JOIN core.usuario mu ON mu.id = m.autor_id
       WHERE m.conversacion_id = c.id), '[]'::jsonb)
  )
  FROM core.conversacion c WHERE c.ot_id = p_ot_id;
$$;


--
-- Name: fn_ot_costos(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_costos(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT jsonb_build_object(
    'cotizado', (SELECT jsonb_build_object('monto', c.monto, 'moneda', c.moneda,
                                           'fuente', 'cotizacion_vigente')
                   FROM core.cotizacion c
                  WHERE c.ot_id = p_ot_id AND c.vigente AND NOT c.invalidada LIMIT 1),
    'liberado', (SELECT jsonb_build_object('monto', sa.monto_liberado_total, 'moneda', sa.moneda,
                                           'fuente', 'liberacion_manual')
                   FROM core.seguimiento_administrativo sa WHERE sa.ot_id = p_ot_id),
    -- No hay integración contable definida (cap. 22.4): declararlo explícitamente
    -- evita que alguien lea el liberado como si fuera el costo final.
    'contable', NULL,
    'registros', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', cu.id, 'fuente', cu.fuente,
               'texto_original', cu.texto_original,
               'descripcion_normalizada', dn.etiqueta,
               'tipo_trabajo', tt.nombre, 'concepto', cu.concepto,
               'cantidad', cu.cantidad, 'unidad', cu.unidad,
               'monto_total', cu.monto_total, 'costo_unitario', cu.costo_unitario,
               'moneda', cu.moneda, 'fecha_referencia', cu.fecha_referencia,
               'proveedor', pr.razon_social,
               'calidad', jsonb_build_object(
                 'estado_validacion', cu.estado_validacion,
                 'confianza',   cu.confianza,
                 'es_outlier',  cu.es_outlier,
                 'justificacion_outlier', cu.outlier_justificacion,
                 'es_comparable', cu.es_comparable)
             ) ORDER BY cu.created_at, cu.id)
        FROM core.costo_unitario cu
        LEFT JOIN core.descripcion_normalizada dn ON dn.id = cu.descripcion_normalizada_id
        LEFT JOIN core.tipo_trabajo tt            ON tt.id = cu.tipo_trabajo_id
        LEFT JOIN core.proveedor pr               ON pr.id = cu.proveedor_id
       WHERE cu.ot_id = p_ot_id), '[]'::jsonb)
  );
$$;


--
-- Name: fn_ot_cotizaciones(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_cotizaciones(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id',               c.id,
           'version',          c.version,
           'vigente',          c.vigente AND NOT c.invalidada,
           'invalidada',       c.invalidada,
           'proveedor',        coalesce(p.razon_social, c.proveedor_nombre),
           'proveedor_ruc',    coalesce(p.ruc, c.proveedor_ruc),
           'numero',           c.numero_cotizacion,
           'fecha',            c.fecha_cotizacion,
           'monto',            c.monto,
           'moneda',           c.moneda,
           'plazo_ofrecido_dias', c.plazo_ofrecido_dias,
           'validez_dias',     c.validez_dias,
           'observaciones',    c.observaciones,
           'motivo_reemplazo', c.motivo_reemplazo,
           'reemplaza_a',      c.reemplaza_a,
           'cargada_por',      u.nombres || ' ' || u.apellidos,
           'cargada_at',       c.created_at,
           'adjuntos',         internal.fn_adjuntos_de('cotizacion', c.id)
         ) ORDER BY c.version), '[]'::jsonb)
  FROM core.cotizacion c
  LEFT JOIN core.proveedor p ON p.id = c.proveedor_id
  LEFT JOIN core.usuario u   ON u.id = c.cargada_por
  WHERE c.ot_id = p_ot_id;
$$;


--
-- Name: fn_ot_diagnosticos(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_diagnosticos(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object(
           'id',                 d.id,
           'version',            d.version,
           'vigente',            d.vigente,
           'diagnostico',        d.diagnostico,
           'causa_probable',     d.causa_probable,
           'alcance',            d.alcance,
           'trabajo_a_realizar', d.trabajo_a_realizar,
           'observaciones',      d.observaciones,
           'lecturas_instrumentos', d.lecturas_instrumentos,
           'autor',              a.nombres || ' ' || a.apellidos,
           'aprobado_por',       ap.nombres || ' ' || ap.apellidos,
           'aprobado_at',        d.aprobado_at,
           'motivo_cambio',      d.motivo_cambio,
           'reemplaza_a',        d.reemplaza_a,
           'fecha',              d.created_at,
           'adjuntos',           internal.fn_adjuntos_de('diagnostico', d.id)
         ) ORDER BY d.version), '[]'::jsonb)
  FROM core.diagnostico d
  LEFT JOIN core.usuario a  ON a.id = d.autor_id
  LEFT JOIN core.usuario ap ON ap.id = d.aprobado_por
  WHERE d.ot_id = p_ot_id;
$$;


--
-- Name: fn_ot_ejecucion(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_ejecucion(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT jsonb_build_object(
    'inicio_real',   e.inicio_real,
    'termino_real',  e.termino_real,
    'responsable',   r.nombres || ' ' || r.apellidos,
    'confirmado_por', cf.nombres || ' ' || cf.apellidos,
    'inicio_sin_cotizacion', coalesce(e.inicio_sin_cotizacion, false),
    'observaciones', e.observaciones,
    -- Duración en días calendario (cap. 12.3, 35.2). Las pausas se reportan
    -- aparte: el MVP no exige calcular tiempo efectivo.
    'duracion_dias', CASE WHEN e.inicio_real IS NOT NULL AND e.termino_real IS NOT NULL
                          THEN round(extract(epoch FROM (e.termino_real - e.inicio_real)) / 86400.0, 2)
                          END,
    'avances', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', av.id, 'descripcion', av.descripcion, 'porcentaje', av.porcentaje,
               'autor', au.nombres || ' ' || au.apellidos, 'fecha', av.created_at,
               'adjuntos', internal.fn_adjuntos_de('ot_avance', av.id)
             ) ORDER BY av.created_at, av.id)
        FROM core.ot_avance av LEFT JOIN core.usuario au ON au.id = av.autor_id
       WHERE av.ot_id = p_ot_id), '[]'::jsonb),
    'incidencias', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', i.id, 'tipo', ct.nombre, 'descripcion', i.descripcion,
               'resuelta', i.resuelta, 'resuelta_at', i.resuelta_at, 'resolucion', i.resolucion,
               'autor', iu.nombres || ' ' || iu.apellidos, 'fecha', i.created_at,
               'adjuntos', internal.fn_adjuntos_de('ot_incidencia', i.id)
             ) ORDER BY i.created_at, i.id)
        FROM core.ot_incidencia i
        LEFT JOIN core.usuario iu       ON iu.id = i.autor_id
        LEFT JOIN core.catalogo_item ct ON ct.id = i.tipo_id
       WHERE i.ot_id = p_ot_id), '[]'::jsonb),
    'pausas', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'id', pa.id, 'motivo', coalesce(cp.nombre, pa.motivo_texto),
               'motivo_texto', pa.motivo_texto,
               'fecha_pausa', pa.fecha_pausa, 'fecha_reanudacion', pa.fecha_reanudacion,
               'abierta', pa.fecha_reanudacion IS NULL,
               'horas', CASE WHEN pa.fecha_reanudacion IS NOT NULL
                             THEN round(extract(epoch FROM (pa.fecha_reanudacion - pa.fecha_pausa)) / 3600.0, 2)
                             END,
               'pausada_por', pu.nombres || ' ' || pu.apellidos,
               'reanudada_por', ru.nombres || ' ' || ru.apellidos,
               'observacion_reanudacion', pa.observacion_reanudacion
             ) ORDER BY pa.fecha_pausa, pa.id)
        FROM core.ot_pausa pa
        LEFT JOIN core.usuario pu       ON pu.id = pa.pausada_por
        LEFT JOIN core.usuario ru       ON ru.id = pa.reanudada_por
        LEFT JOIN core.catalogo_item cp ON cp.id = pa.motivo_id
       WHERE pa.ot_id = p_ot_id), '[]'::jsonb)
  )
  FROM core.orden_trabajo o
  LEFT JOIN core.ejecucion e ON e.ot_id = o.id
  LEFT JOIN core.usuario r   ON r.id = e.responsable_id
  LEFT JOIN core.usuario cf  ON cf.id = e.confirmado_por
  WHERE o.id = p_ot_id;
$$;


--
-- Name: fn_ot_eventos(uuid, integer); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_eventos(p_ot_id uuid, p_limite integer DEFAULT 500) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  -- Se ordena por (fecha, id): dentro de una misma transacción now() es idéntico
  -- para todos los eventos, y sin el id la línea de tiempo saldría desordenada.
  SELECT coalesce(jsonb_agg(e ORDER BY (e->>'fecha'), (e->>'id')::bigint), '[]'::jsonb)
  FROM (
    SELECT jsonb_build_object(
             'id', ev.id, 'dominio', ev.dominio, 'evento', ev.evento,
             'entidad_tipo', ev.entidad_tipo, 'entidad_id', ev.entidad_id,
             'anterior', ev.valor_anterior, 'nuevo', ev.valor_nuevo,
             'motivo', ev.motivo,
             'actor', eu.nombres || ' ' || eu.apellidos,
             'fecha', ev.created_at) AS e
      FROM core.ot_evento ev LEFT JOIN core.usuario eu ON eu.id = ev.actor_id
     WHERE ev.ot_id = p_ot_id
     ORDER BY ev.created_at DESC, ev.id DESC
     LIMIT p_limite
  ) s;
$$;


--
-- Name: fn_ot_organizacion(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_organizacion(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT jsonb_build_object(
    'tenant',      jsonb_build_object('id', t.id, 'nombre', t.nombre),
    'sucursal',    CASE WHEN su.id IS NULL THEN NULL
                        ELSE jsonb_build_object('id', su.id, 'codigo', su.codigo, 'nombre', su.nombre) END,
    'empresa_ruc', CASE WHEN er.id IS NULL THEN NULL
                        ELSE jsonb_build_object('id', er.id, 'ruc', er.ruc,
                                                'razon_social', er.razon_social,
                                                'estado', er.estado) END,
    'area',        CASE WHEN ar.id IS NULL THEN NULL
                        ELSE jsonb_build_object('id', ar.id, 'codigo', ar.codigo, 'nombre', ar.nombre) END,
    'cecos',       CASE WHEN ce.id IS NULL THEN NULL
                        ELSE jsonb_build_object('id', ce.id, 'codigo', ce.codigo,
                                                'descripcion', ce.descripcion) END
  )
  FROM core.orden_trabajo o
  JOIN core.tenant t            ON t.id = o.tenant_id
  LEFT JOIN core.sucursal su    ON su.id = o.sucursal_id
  LEFT JOIN core.empresa_ruc er ON er.id = o.empresa_ruc_id
  LEFT JOIN core.area ar        ON ar.id = o.area_id
  LEFT JOIN core.cecos ce       ON ce.id = o.cecos_id
  WHERE o.id = p_ot_id;
$$;


--
-- Name: fn_ot_origen(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_origen(p_ot_id uuid) RETURNS jsonb
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT jsonb_build_object(
    'solicitud',
      CASE WHEN s.id IS NULL THEN NULL ELSE jsonb_build_object(
        'id',                  s.id,
        'numero',              s.numero,
        'estado',              s.estado,
        'titulo',              s.titulo,
        -- El reporte original se conserva literalmente y no lo altera la OT (cap. 7.2, 24.1).
        'descripcion_original', s.descripcion,
        'lugar',               s.lugar,
        'impacto',             ci.nombre,
        'impacto_comentario',  s.impacto_comentario,
        'prioridad_percibida', s.prioridad_percibida,
        'solicitante',         jsonb_build_object('id', u.id, 'nombre', u.nombres || ' ' || u.apellidos),
        'fecha_envio',         s.fecha_envio,
        'fecha_primera_revision', s.fecha_primera_revision
      ) END,
    'decisiones', coalesce((
      SELECT jsonb_agg(jsonb_build_object(
               'tipo',            d.tipo,
               'estado_anterior', d.estado_anterior,
               'estado_nuevo',    d.estado_nuevo,
               'motivo',          cm.nombre,
               'comentario',      d.comentario,
               'actor',           du.nombres || ' ' || du.apellidos,
               'fecha',           d.created_at
             ) ORDER BY d.created_at, d.id)
        FROM core.solicitud_decision d
        LEFT JOIN core.usuario du      ON du.id = d.actor_id
        LEFT JOIN core.catalogo_item cm ON cm.id = d.motivo_id
       WHERE d.solicitud_id = s.id), '[]'::jsonb),
    'ot_padre',
      CASE WHEN p.id IS NULL THEN NULL ELSE jsonb_build_object(
        'id',      p.id,
        'numero',  p.numero_ot,
        'estado',  p.estado,
        'motivo_derivacion', coalesce(cd.nombre, o.motivo_derivacion_texto),
        'es_bloqueante',     o.es_bloqueante_para_padre,
        'independizada',     o.independizada_de_padre
      ) END
  )
  FROM core.orden_trabajo o
  LEFT JOIN core.solicitud_trabajo s ON s.id = o.solicitud_origen_id
  LEFT JOIN core.usuario u           ON u.id = s.solicitante_id
  LEFT JOIN core.catalogo_item ci    ON ci.id = s.impacto_operativo_id
  LEFT JOIN core.orden_trabajo p     ON p.id = o.ot_padre_id
  LEFT JOIN core.catalogo_item cd    ON cd.id = o.motivo_derivacion_id
  WHERE o.id = p_ot_id;
$$;


--
-- Name: fn_ot_trazabilidad(uuid, integer, boolean); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_trazabilidad(p_ot_id uuid, p_profundidad integer DEFAULT 10, p_resumido boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
DECLARE
  v_arbol      JSONB;
  v_derivadas  JSONB := '[]'::jsonb;
  v_hija       RECORD;
  v_total      INT := 1;
  v_max_nivel  INT := 0;
BEGIN
  IF p_ot_id IS NULL THEN RETURN '{}'::jsonb; END IF;
  IF NOT EXISTS (SELECT 1 FROM core.orden_trabajo WHERE id = p_ot_id) THEN
    RETURN '{}'::jsonb;
  END IF;

  -- Derivadas: recursión en profundidad. Cada hija trae su propio subárbol
  -- completo, de modo que el JSON del padre contiene literalmente todo lo que la
  -- OT generó, incluidas las nietas (cap. 10, 27.1).
  IF p_profundidad > 0 THEN
    FOR v_hija IN
      SELECT id FROM core.orden_trabajo
       WHERE ot_padre_id = p_ot_id AND deleted_at IS NULL
       -- Por número, no por created_at: el número es único y no empata dentro
       -- de una misma transacción.
       ORDER BY numero_ot
    LOOP
      v_derivadas := v_derivadas || jsonb_build_array(
        internal.fn_ot_trazabilidad(v_hija.id, p_profundidad - 1, true)
      );
    END LOOP;
  END IF;

  SELECT coalesce(sum(coalesce((d->'_meta'->>'total_nodos')::int, 1)), 0) + 1,
         coalesce(max(coalesce((d->'_meta'->>'profundidad_arbol')::int, 0)), -1) + 1
    INTO v_total, v_max_nivel
    FROM jsonb_array_elements(v_derivadas) d;

  v_arbol := jsonb_build_object(
    'ot',             internal.fn_ot_cabecera(p_ot_id),
    'organizacion',   internal.fn_ot_organizacion(p_ot_id),
    'origen',         internal.fn_ot_origen(p_ot_id),
    'diagnosticos',   internal.fn_ot_diagnosticos(p_ot_id),
    'cotizaciones',   internal.fn_ot_cotizaciones(p_ot_id),
    'ejecucion',      internal.fn_ot_ejecucion(p_ot_id),
    'cierre',         internal.fn_ot_cierre(p_ot_id),
    'administrativo', internal.fn_ot_administrativo(p_ot_id),
    'derivadas',      v_derivadas,
    'adjuntos',       coalesce((
        SELECT jsonb_agg(jsonb_build_object(
                 'id', a.id, 'nombre', a.nombre, 'tipo', a.tipo, 'etapa', a.etapa,
                 'mime', a.mime_type, 'tamano', a.tamano_bytes, 'estado', a.estado,
                 'entidad_tipo', a.entidad_tipo, 'entidad_id', a.entidad_id,
                 'autor', au.nombres || ' ' || au.apellidos, 'fecha', a.created_at
               ) ORDER BY a.created_at, a.id)
          FROM core.adjunto a LEFT JOIN core.usuario au ON au.id = a.autor_id
         WHERE a.ot_id = p_ot_id), '[]'::jsonb),
    'costos',         internal.fn_ot_costos(p_ot_id)
  );

  -- Bloques pesados: sólo en el nodo por el que se preguntó, no en cada nieta.
  IF NOT p_resumido THEN
    v_arbol := v_arbol
      || jsonb_build_object('conversacion', internal.fn_ot_conversacion(p_ot_id))
      || jsonb_build_object('eventos',      internal.fn_ot_eventos(p_ot_id));
  END IF;

  -- El instante de generación va SÓLO en el nodo raíz. Si cada derivada anidada
  -- llevara el suyo, dos llamadas consecutivas producirían árboles distintos y
  -- sería imposible comparar el snapshot cacheado con la función autoritativa
  -- para verificar la integridad del motor.
  RETURN v_arbol || jsonb_build_object('_meta',
    jsonb_build_object(
      'version',            1,
      'profundidad_arbol',  v_max_nivel,
      'total_nodos',        v_total,
      'resumido',           p_resumido)
    || CASE WHEN p_resumido THEN '{}'::jsonb
            ELSE jsonb_build_object('generado_en', now()) END);
END; $$;


--
-- Name: FUNCTION fn_ot_trazabilidad(p_ot_id uuid, p_profundidad integer, p_resumido boolean); Type: COMMENT; Schema: internal; Owner: -
--

COMMENT ON FUNCTION internal.fn_ot_trazabilidad(p_ot_id uuid, p_profundidad integer, p_resumido boolean) IS 'AUTORIDAD del árbol de trazabilidad. Lo arma desde las tablas reales, que son la fuente de verdad. La columna orden_trabajo.trazabilidad es sólo una proyección cacheada de esta función.';


--
-- Name: fn_ot_trazabilidad_fresca(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.fn_ot_trazabilidad_fresca(p_ot_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'app', 'internal', 'public'
    AS $$
DECLARE v_arbol JSONB;
BEGIN
  IF EXISTS (SELECT 1 FROM core.orden_trabajo WHERE id = p_ot_id AND trazabilidad_dirty) THEN
    PERFORM app.sp_ot_trazabilidad_refrescar(p_ot_id, true);
  END IF;
  SELECT trazabilidad INTO v_arbol FROM core.orden_trabajo WHERE id = p_ot_id;
  RETURN coalesce(v_arbol, '{}'::jsonb);
END; $$;


--
-- Name: limite_adjunto(uuid, core.tipo_adjunto); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.limite_adjunto(p_tenant_id uuid, p_tipo core.tipo_adjunto) RETURNS bigint
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
  SELECT coalesce(
    (internal.config(p_tenant_id, 'limites_adjunto')->>(p_tipo::text))::bigint,
    CASE p_tipo
      WHEN 'pdf'        THEN 25  * 1024 * 1024
      WHEN 'imagen'     THEN 10  * 1024 * 1024
      WHEN 'video'      THEN 100 * 1024 * 1024
      WHEN 'documento'  THEN 25  * 1024 * 1024
      ELSE 25 * 1024 * 1024
    END);
$$;


--
-- Name: marcar_ot_dirty(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.marcar_ot_dirty(p_ot_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
BEGIN
  IF p_ot_id IS NULL THEN RETURN; END IF;

  -- La guarda de OT cerrada no debe impedir marcar la bandera: mantener el árbol
  -- al día no es "modificar" la OT en el sentido del cap. 21.3.
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);

  WITH RECURSIVE ancestros AS (
    SELECT id, ot_padre_id, 0 AS salto
      FROM core.orden_trabajo
     WHERE id = p_ot_id
    UNION ALL
    SELECT ot.id, ot.ot_padre_id, a.salto + 1
      FROM core.orden_trabajo ot
      JOIN ancestros a ON ot.id = a.ot_padre_id
     WHERE a.salto < 100          -- cinturón de seguridad ante datos corruptos
  )
  UPDATE core.orden_trabajo o
     SET trazabilidad_dirty = true
    FROM ancestros a
   WHERE o.id = a.id
     AND o.trazabilidad_dirty = false;

  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);
END; $$;


--
-- Name: marcar_ot_dirty_hijas(uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.marcar_ot_dirty_hijas(p_ot_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
BEGIN
  IF p_ot_id IS NULL THEN RETURN; END IF;
  PERFORM set_config('mip.permitir_update_cerrada', 'on', true);
  UPDATE core.orden_trabajo
     SET trazabilidad_dirty = true
   WHERE ot_padre_id = p_ot_id AND trazabilidad_dirty = false;
  PERFORM set_config('mip.permitir_update_cerrada', 'off', true);
END; $$;


--
-- Name: meta_paginacion(integer, integer, integer); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.meta_paginacion(p_total integer, p_page integer, p_size integer) RETURNS jsonb
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT jsonb_build_object(
    'total', p_total, 'page', greatest(p_page,1), 'page_size', p_size,
    'pages', CASE WHEN p_total = 0 THEN 0 ELSE ceil(p_total::numeric / p_size)::int END);
$$;


--
-- Name: normalizar_busqueda(text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.normalizar_busqueda(p_texto text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT lower(unaccent(coalesce(p_texto,'')));
$$;


--
-- Name: notificar(uuid, uuid, text, text, text, uuid, text, uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.notificar(p_tenant_id uuid, p_destinatario_id uuid, p_evento text, p_titulo text, p_cuerpo text DEFAULT NULL::text, p_ot_id uuid DEFAULT NULL::uuid, p_entidad_tipo text DEFAULT NULL::text, p_entidad_id uuid DEFAULT NULL::uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
BEGIN
  IF p_destinatario_id IS NULL THEN RETURN; END IF;
  INSERT INTO core.notificacion (tenant_id, destinatario_id, evento, titulo, cuerpo,
                                 ot_id, entidad_tipo, entidad_id, canal, estado)
  VALUES (p_tenant_id, p_destinatario_id, p_evento, p_titulo, p_cuerpo,
          p_ot_id, p_entidad_tipo, p_entidad_id, 'interno', 'pendiente');
END; $$;


--
-- Name: notificar_coordinadores(uuid, uuid, text, text, text, text, uuid); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.notificar_coordinadores(p_tenant_id uuid, p_area_id uuid, p_evento text, p_titulo text, p_cuerpo text DEFAULT NULL::text, p_entidad_tipo text DEFAULT NULL::text, p_entidad_id uuid DEFAULT NULL::uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT u.id
      FROM core.usuario u
      JOIN core.usuario_rol ur ON ur.usuario_id = u.id
      JOIN core.rol rr         ON rr.id = ur.rol_id
     WHERE u.tenant_id = p_tenant_id AND u.estado = 'activo' AND u.deleted_at IS NULL
       AND rr.codigo = 'coordinador'
       AND (NOT EXISTS (SELECT 1 FROM core.usuario_alcance a WHERE a.usuario_id = u.id)
            OR EXISTS (SELECT 1 FROM core.usuario_alcance a
                        WHERE a.usuario_id = u.id
                          AND (a.area_id IS NULL OR a.area_id = p_area_id)))
  LOOP
    PERFORM internal.notificar(p_tenant_id, r.id, p_evento, p_titulo, p_cuerpo,
                               NULL, p_entidad_tipo, p_entidad_id);
  END LOOP;
END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: orden_trabajo; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.orden_trabajo (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    numero_ot character varying(30) NOT NULL,
    solicitud_origen_id uuid,
    ot_padre_id uuid,
    nivel integer DEFAULT 0 NOT NULL,
    motivo_derivacion_id uuid,
    motivo_derivacion_texto text,
    es_bloqueante_para_padre boolean DEFAULT true NOT NULL,
    independizada_de_padre boolean DEFAULT false NOT NULL,
    sucursal_id uuid,
    empresa_ruc_id uuid,
    area_id uuid,
    cecos_id uuid,
    tipo_mantenimiento_id uuid,
    tipo_trabajo_id uuid,
    prioridad_tecnica core.prioridad,
    es_emergencia boolean DEFAULT false NOT NULL,
    emergencia_justificacion text,
    emergencia_declarada_por uuid,
    emergencia_declarada_at timestamp with time zone,
    regularizacion_pendiente boolean DEFAULT false NOT NULL,
    estado core.ot_estado DEFAULT 'creada'::core.ot_estado NOT NULL,
    condicion core.ot_condicion DEFAULT 'activa'::core.ot_condicion NOT NULL,
    estado_administrativo core.estado_administrativo DEFAULT 'sin_solped'::core.estado_administrativo NOT NULL,
    coordinador_id uuid,
    ejecutor_id uuid,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_inicio_real timestamp with time zone,
    fecha_termino_real timestamp with time zone,
    fecha_cierre timestamp with time zone,
    motivo_cancelacion_id uuid,
    cancelacion_observacion text,
    fecha_cancelacion timestamp with time zone,
    veces_reabierta integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid,
    trazabilidad_version integer DEFAULT 0 NOT NULL,
    trazabilidad_dirty boolean DEFAULT true NOT NULL,
    trazabilidad_at timestamp with time zone,
    trazabilidad jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT ck_ot_cierre_tras_termino CHECK (((fecha_cierre IS NULL) OR (fecha_termino_real IS NULL) OR (fecha_cierre >= fecha_termino_real))),
    CONSTRAINT ck_ot_emergencia_justificada CHECK (((es_emergencia = false) OR (btrim(COALESCE(emergencia_justificacion, ''::text)) <> ''::text))),
    CONSTRAINT ck_ot_no_autopadre CHECK (((ot_padre_id IS NULL) OR (ot_padre_id <> id))),
    CONSTRAINT ck_ot_termino_tras_inicio CHECK (((fecha_termino_real IS NULL) OR (fecha_inicio_real IS NULL) OR (fecha_termino_real >= fecha_inicio_real)))
);


--
-- Name: TABLE orden_trabajo; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON TABLE core.orden_trabajo IS 'TABLA PRINCIPAL de MIP. Contenedor del ciclo técnico de una intervención (cap. 8.1). La columna trazabilidad guarda el árbol completo de todo lo que la OT generó.';


--
-- Name: COLUMN orden_trabajo.trazabilidad; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON COLUMN core.orden_trabajo.trazabilidad IS 'Árbol JSONB de TODO lo que generó esta OT: solicitud origen, diagnósticos versionados, derivadas recursivas, cotizaciones, ejecución, cierre, administrativo, adjuntos, conversación, costos y eventos. Proyección — la fuente de verdad son las tablas.';


--
-- Name: ot_visible(uuid, uuid, uuid, boolean); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.ot_visible(p_ot_id uuid, p_user_id uuid, p_tenant_id uuid, p_is_super_admin boolean) RETURNS core.orden_trabajo
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
DECLARE o core.orden_trabajo%ROWTYPE;
BEGIN
  SELECT * INTO o FROM core.orden_trabajo
   WHERE id = p_ot_id
     AND deleted_at IS NULL
     AND (tenant_id = p_tenant_id OR internal.es_acceso_global(p_user_id, p_is_super_admin));
  RETURN o;
END; $$;


--
-- Name: registrar_auditoria(uuid, uuid, text, text, uuid, jsonb, jsonb, text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.registrar_auditoria(p_actor_id uuid, p_tenant_id uuid, p_accion text, p_entidad text, p_entidad_id uuid, p_antes jsonb DEFAULT NULL::jsonb, p_despues jsonb DEFAULT NULL::jsonb, p_motivo text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'audit', 'internal', 'public'
    AS $$
DECLARE v_diff JSONB := '{}'::jsonb; k TEXT;
BEGIN
  -- El diff campo a campo es lo que pide el cap. 33: "valores anteriores/nuevos".
  IF p_antes IS NOT NULL AND p_despues IS NOT NULL THEN
    FOR k IN SELECT jsonb_object_keys(p_antes) UNION SELECT jsonb_object_keys(p_despues) LOOP
      IF (p_antes->k) IS DISTINCT FROM (p_despues->k) THEN
        v_diff := v_diff || jsonb_build_object(k, jsonb_build_object(
          'antes', p_antes->k, 'despues', p_despues->k));
      END IF;
    END LOOP;
  END IF;

  INSERT INTO audit.audit_log (tenant_id, actor_id, accion, entidad, entidad_id,
                               valor_anterior, valor_nuevo, diff, motivo, request_id)
  VALUES (p_tenant_id, p_actor_id, p_accion, p_entidad, p_entidad_id,
          p_antes, p_despues, nullif(v_diff, '{}'::jsonb), p_motivo,
          nullif(current_setting('mip.request_id', true), ''));
END; $$;


--
-- Name: registrar_evento_ot(uuid, uuid, core.dominio_evento, text, uuid, text, uuid, jsonb, jsonb, text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.registrar_evento_ot(p_tenant_id uuid, p_ot_id uuid, p_dominio core.dominio_evento, p_evento text, p_actor_id uuid, p_entidad_tipo text DEFAULT NULL::text, p_entidad_id uuid DEFAULT NULL::uuid, p_anterior jsonb DEFAULT NULL::jsonb, p_nuevo jsonb DEFAULT NULL::jsonb, p_motivo text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
BEGIN
  INSERT INTO core.ot_evento (tenant_id, ot_id, dominio, evento, entidad_tipo, entidad_id,
                              valor_anterior, valor_nuevo, motivo, actor_id)
  VALUES (p_tenant_id, p_ot_id, p_dominio, p_evento, p_entidad_tipo, p_entidad_id,
          p_anterior, p_nuevo, p_motivo, p_actor_id);
END; $$;


--
-- Name: siguiente_numero(uuid, text, text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.siguiente_numero(p_tenant_id uuid, p_tipo_documento text, p_prefijo text DEFAULT NULL::text) RETURNS character varying
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
DECLARE v_prefijo TEXT := coalesce(p_prefijo, p_tipo_documento); v_numero INT;
BEGIN
  INSERT INTO core.correlativo (tenant_id, tipo_documento, prefijo, ultimo_numero)
  VALUES (p_tenant_id, p_tipo_documento, v_prefijo, 0)
  ON CONFLICT (tenant_id, tipo_documento) DO NOTHING;

  UPDATE core.correlativo
     SET ultimo_numero = ultimo_numero + 1, updated_at = now()
   WHERE tenant_id = p_tenant_id AND tipo_documento = p_tipo_documento
  RETURNING ultimo_numero, prefijo INTO v_numero, v_prefijo;

  RETURN v_prefijo || '-' || lpad(v_numero::text, 6, '0');   -- OT-000042
END; $$;


--
-- Name: validar_ruc(text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.validar_ruc(p_ruc text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE v TEXT := regexp_replace(coalesce(p_ruc,''), '\D', '', 'g');
        pesos INT[] := ARRAY[5,4,3,2,7,6,5,4,3,2]; s INT := 0; i INT; d INT;
BEGIN
  IF length(v) <> 11 THEN RETURN false; END IF;
  IF substr(v,1,2) NOT IN ('10','15','16','17','20') THEN RETURN false; END IF;
  FOR i IN 1..10 LOOP s := s + substr(v,i,1)::int * pesos[i]; END LOOP;
  d := 11 - (s % 11);
  IF d = 10 THEN d := 0; ELSIF d = 11 THEN d := 1; END IF;
  RETURN d = substr(v,11,1)::int;
END; $$;


--
-- Name: validar_transicion_ot(uuid, core.ot_estado, core.ot_estado, text); Type: FUNCTION; Schema: internal; Owner: -
--

CREATE FUNCTION internal.validar_transicion_ot(p_ot_id uuid, p_desde core.ot_estado, p_hacia core.ot_estado, p_motivo text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'core', 'internal', 'public'
    AS $$
DECLARE
  o            core.orden_trabajo%ROWTYPE;
  v_legal      BOOLEAN := false;
  v_hay_diag   BOOLEAN;
  v_hay_cotiz  BOOLEAN;
  v_hay_pausa  BOOLEAN;
  v_hijas      INT;
BEGIN
  SELECT * INTO o FROM core.orden_trabajo WHERE id = p_ot_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'La OT no existe' USING ERRCODE = 'MIP02';
  END IF;

  -- Cancelar es legal desde cualquier estado no terminal (Anexo A, fila "Varios").
  IF p_hacia = 'cancelada' THEN
    IF p_desde IN ('cerrada','cancelada') THEN
      RAISE EXCEPTION 'No se puede cancelar una OT % ', p_desde USING ERRCODE = 'MIP04';
    END IF;
    IF btrim(coalesce(p_motivo,'')) = '' THEN
      RAISE EXCEPTION 'La cancelación exige motivo' USING ERRCODE = 'MIP01';
    END IF;
    RETURN;
  END IF;

  v_legal := CASE
    WHEN p_desde = 'creada'            AND p_hacia = 'en_diagnostico'    THEN true
    WHEN p_desde = 'en_diagnostico'    AND p_hacia = 'en_cotizacion'     THEN true
    WHEN p_desde = 'en_cotizacion'     AND p_hacia = 'en_trabajo'        THEN true
    WHEN p_desde = 'en_diagnostico'    AND p_hacia = 'en_trabajo'        THEN true  -- sólo emergencia
    WHEN p_desde = 'en_trabajo'        AND p_hacia = 'trabajo_realizado' THEN true
    WHEN p_desde = 'trabajo_realizado' AND p_hacia = 'en_trabajo'        THEN true  -- corrección
    WHEN p_desde = 'trabajo_realizado' AND p_hacia = 'cerrada'           THEN true
    WHEN p_desde = 'en_cotizacion'     AND p_hacia = 'en_diagnostico'    THEN true  -- cambio de alcance
    WHEN p_desde = 'en_trabajo'        AND p_hacia = 'en_diagnostico'    THEN true  -- replanteamiento
    WHEN p_desde = 'cerrada'           AND p_hacia IN ('en_trabajo','en_diagnostico') THEN true  -- reapertura
    ELSE false END;

  IF NOT v_legal THEN
    RAISE EXCEPTION 'Transición no permitida: % -> % (Anexo A)', p_desde, p_hacia
      USING ERRCODE = 'MIP04';
  END IF;

  -- CREADA -> EN DIAGNOSTICO: contexto técnico completo. El activo NO es requisito
  -- del MVP (cap. 25.2), y eso es deliberado.
  IF p_desde = 'creada' AND p_hacia = 'en_diagnostico' THEN
    IF o.coordinador_id IS NULL OR o.sucursal_id IS NULL OR o.empresa_ruc_id IS NULL
       OR o.area_id IS NULL OR o.prioridad_tecnica IS NULL OR o.tipo_mantenimiento_id IS NULL THEN
      RAISE EXCEPTION 'Para pasar a diagnóstico faltan: coordinador, sucursal, empresa/RUC, área, prioridad técnica o tipo de mantenimiento'
        USING ERRCODE = 'MIP01';
    END IF;
  END IF;

  -- EN DIAGNOSTICO -> EN COTIZACION: los cuatro campos técnicos obligatorios (QA-07).
  IF p_hacia = 'en_cotizacion' THEN
    SELECT EXISTS (SELECT 1 FROM core.diagnostico d WHERE d.ot_id = p_ot_id AND d.vigente)
      INTO v_hay_diag;
    IF NOT v_hay_diag THEN
      RAISE EXCEPTION 'No se puede pasar a cotización sin un diagnóstico vigente completo'
        USING ERRCODE = 'MIP04';
    END IF;
  END IF;

  -- Entrar a EN TRABAJO.
  IF p_hacia = 'en_trabajo' AND p_desde IN ('en_cotizacion','en_diagnostico') THEN
    IF o.ejecutor_id IS NULL THEN
      RAISE EXCEPTION 'El inicio exige un responsable de ejecución' USING ERRCODE = 'MIP01';
    END IF;
    IF p_desde = 'en_diagnostico' AND NOT o.es_emergencia THEN
      -- Saltarse la cotización sólo es legal en emergencia (Anexo A, QA-11).
      RAISE EXCEPTION 'Sólo una OT de emergencia puede iniciar trabajo sin pasar por cotización'
        USING ERRCODE = 'MIP04';
    END IF;
    IF p_desde = 'en_cotizacion' THEN
      SELECT EXISTS (SELECT 1 FROM core.cotizacion c
                      WHERE c.ot_id = p_ot_id AND c.vigente AND NOT c.invalidada)
        INTO v_hay_cotiz;
      IF NOT v_hay_cotiz THEN
        RAISE EXCEPTION 'El inicio normal exige una cotización vigente' USING ERRCODE = 'MIP04';
      END IF;
    END IF;
  END IF;

  -- EN TRABAJO -> TRABAJO REALIZADO: no con una pausa vigente sin resolver (cap. 29.3, QA-13).
  IF p_hacia = 'trabajo_realizado' THEN
    SELECT EXISTS (SELECT 1 FROM core.ot_pausa WHERE ot_id = p_ot_id AND fecha_reanudacion IS NULL)
      INTO v_hay_pausa;
    IF v_hay_pausa THEN
      RAISE EXCEPTION 'No se puede declarar trabajo realizado con una pausa vigente; reanude primero'
        USING ERRCODE = 'MIP04';
    END IF;
  END IF;

  -- TRABAJO REALIZADO -> CERRADA: revisión aprobada y derivadas bloqueantes resueltas.
  -- El seguimiento administrativo NO bloquea (cap. 14.3): eso lo maneja el SP de
  -- cierre exigiendo confirmación y observación.
  IF p_hacia = 'cerrada' THEN
    IF NOT EXISTS (SELECT 1 FROM core.trabajo_realizado t
                    WHERE t.ot_id = p_ot_id AND t.vigente
                      AND t.resultado_revision = 'aprobado') THEN
      RAISE EXCEPTION 'El cierre exige un trabajo realizado revisado y aprobado' USING ERRCODE = 'MIP04';
    END IF;

    SELECT count(*) INTO v_hijas
      FROM core.orden_trabajo h
     WHERE h.ot_padre_id = p_ot_id
       AND h.deleted_at IS NULL
       AND h.es_bloqueante_para_padre = true
       AND h.estado NOT IN ('cerrada','cancelada');
    IF v_hijas > 0 THEN
      -- Cap. 10: la OT superior no cierra si tiene derivadas activas, salvo que se
      -- marquen no bloqueantes conforme a regla y permiso configurados (QA-16).
      RAISE EXCEPTION 'La OT tiene % derivada(s) bloqueante(s) sin resolver', v_hijas
        USING ERRCODE = 'MIP04';
    END IF;
  END IF;

  -- Salir de CERRADA es reapertura: siempre con motivo (cap. 14.4, QA-22).
  IF p_desde = 'cerrada' THEN
    IF btrim(coalesce(p_motivo,'')) = '' THEN
      RAISE EXCEPTION 'La reapertura exige motivo obligatorio' USING ERRCODE = 'MIP01';
    END IF;
  END IF;

  -- Volver atrás por cambio de alcance o replanteamiento exige motivo (Anexo A).
  IF p_hacia = 'en_diagnostico' AND p_desde IN ('en_cotizacion','en_trabajo') THEN
    IF btrim(coalesce(p_motivo,'')) = '' THEN
      RAISE EXCEPTION 'Regresar a diagnóstico exige registrar el motivo' USING ERRCODE = 'MIP01';
    END IF;
  END IF;
END; $$;


--
-- Name: t_div(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.t_div() RETURNS integer
    LANGUAGE sql
    AS $$ SELECT 1/0; $$;


--
-- Name: t_raise(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.t_raise() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN RAISE EXCEPTION 'boom' USING ERRCODE='P0004'; END; $$;


--
-- Name: audit_log; Type: TABLE; Schema: audit; Owner: -
--

CREATE TABLE audit.audit_log (
    id bigint NOT NULL,
    tenant_id uuid,
    actor_id uuid,
    accion character varying(40) NOT NULL,
    entidad character varying(60) NOT NULL,
    entidad_id uuid,
    valor_anterior jsonb,
    valor_nuevo jsonb,
    diff jsonb,
    motivo text,
    ip inet,
    user_agent text,
    request_id character varying(60),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: audit; Owner: -
--

CREATE SEQUENCE audit.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: -
--

ALTER SEQUENCE audit.audit_log_id_seq OWNED BY audit.audit_log.id;


--
-- Name: adjunto; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.adjunto (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid,
    entidad_tipo character varying(40) NOT NULL,
    entidad_id uuid NOT NULL,
    etapa core.etapa_adjunto NOT NULL,
    tipo core.tipo_adjunto NOT NULL,
    nombre character varying(255) NOT NULL,
    nombre_original character varying(255),
    mime_type character varying(120),
    tamano_bytes bigint,
    storage_key text NOT NULL,
    checksum character varying(80),
    estado core.estado_adjunto DEFAULT 'vigente'::core.estado_adjunto NOT NULL,
    visibilidad core.visibilidad_mensaje DEFAULT 'canal'::core.visibilidad_mensaje NOT NULL,
    autor_id uuid NOT NULL,
    retirado_at timestamp with time zone,
    retirado_por uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_adjunto_tamano CHECK (((tamano_bytes IS NULL) OR (tamano_bytes >= 0)))
);


--
-- Name: area; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.area (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    empresa_ruc_id uuid NOT NULL,
    codigo character varying(30) NOT NULL,
    nombre character varying(150) NOT NULL,
    estado core.estado_registro DEFAULT 'activo'::core.estado_registro NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


--
-- Name: catalogo_item; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.catalogo_item (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    tipo core.tipo_catalogo NOT NULL,
    codigo character varying(60) NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    orden integer DEFAULT 0 NOT NULL,
    requiere_comentario boolean DEFAULT false NOT NULL,
    estado core.estado_registro DEFAULT 'activo'::core.estado_registro NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


--
-- Name: cecos; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.cecos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    empresa_ruc_id uuid NOT NULL,
    area_id uuid,
    codigo character varying(40) NOT NULL,
    descripcion character varying(200) NOT NULL,
    estado core.estado_registro DEFAULT 'activo'::core.estado_registro NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


--
-- Name: conversacion; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.conversacion (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    solo_lectura boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: conversacion_participante; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.conversacion_participante (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    conversacion_id uuid NOT NULL,
    usuario_id uuid NOT NULL,
    puede_escribir boolean DEFAULT true NOT NULL,
    ve_notas_internas boolean DEFAULT false NOT NULL,
    invitado_por uuid,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: correlativo; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.correlativo (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    tipo_documento character varying(20) NOT NULL,
    prefijo character varying(10) NOT NULL,
    ultimo_numero integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: costo_unitario; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.costo_unitario (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    cotizacion_id uuid,
    fuente core.fuente_costo NOT NULL,
    texto_original text NOT NULL,
    descripcion_normalizada_id uuid,
    tipo_trabajo_id uuid,
    concepto core.concepto_costo,
    cantidad numeric(14,4),
    unidad character varying(30),
    monto_total numeric(14,2) NOT NULL,
    costo_unitario numeric(14,4),
    moneda core.moneda_codigo DEFAULT 'PEN'::core.moneda_codigo NOT NULL,
    fecha_referencia date,
    proveedor_id uuid,
    sucursal_id uuid,
    empresa_ruc_id uuid,
    area_id uuid,
    fue_emergencia boolean DEFAULT false NOT NULL,
    ot_es_derivada boolean DEFAULT false NOT NULL,
    estado_validacion core.estado_validacion_costo DEFAULT 'sin_validar'::core.estado_validacion_costo NOT NULL,
    confianza numeric(4,3),
    es_outlier boolean DEFAULT false NOT NULL,
    outlier_justificacion text,
    es_comparable boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT ck_costo_cantidad CHECK (((cantidad IS NULL) OR (cantidad > (0)::numeric))),
    CONSTRAINT ck_costo_confianza CHECK (((confianza IS NULL) OR ((confianza >= (0)::numeric) AND (confianza <= (1)::numeric)))),
    CONSTRAINT ck_costo_monto CHECK ((monto_total >= (0)::numeric))
);


--
-- Name: cotizacion; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.cotizacion (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    version integer NOT NULL,
    vigente boolean DEFAULT true NOT NULL,
    proveedor_id uuid,
    proveedor_ruc character varying(20),
    proveedor_nombre character varying(200),
    numero_cotizacion character varying(60),
    fecha_cotizacion date,
    monto numeric(14,2),
    moneda core.moneda_codigo DEFAULT 'PEN'::core.moneda_codigo NOT NULL,
    plazo_ofrecido_dias integer,
    observaciones text,
    motivo_reemplazo text,
    reemplaza_a uuid,
    invalidada boolean DEFAULT false NOT NULL,
    cargada_por uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    validez_dias integer,
    CONSTRAINT ck_cotizacion_monto CHECK (((monto IS NULL) OR (monto >= (0)::numeric))),
    CONSTRAINT ck_cotizacion_plazo CHECK (((plazo_ofrecido_dias IS NULL) OR (plazo_ofrecido_dias >= 0))),
    CONSTRAINT ck_cotizacion_validez CHECK (((validez_dias IS NULL) OR (validez_dias >= 0)))
);


--
-- Name: descripcion_normalizada; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.descripcion_normalizada (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    etiqueta character varying(200) NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    vigente boolean DEFAULT true NOT NULL,
    tipo_trabajo_id uuid,
    aprobada_por uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: diagnostico; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.diagnostico (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    version integer NOT NULL,
    vigente boolean DEFAULT true NOT NULL,
    diagnostico text NOT NULL,
    causa_probable text NOT NULL,
    alcance text NOT NULL,
    trabajo_a_realizar text NOT NULL,
    observaciones text,
    lecturas_instrumentos text,
    autor_id uuid NOT NULL,
    aprobado_por uuid,
    aprobado_at timestamp with time zone,
    motivo_cambio text,
    reemplaza_a uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT ck_diagnostico_campos CHECK (((btrim(diagnostico) <> ''::text) AND (btrim(causa_probable) <> ''::text) AND (btrim(alcance) <> ''::text) AND (btrim(trabajo_a_realizar) <> ''::text)))
);


--
-- Name: ejecucion; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.ejecucion (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    responsable_id uuid NOT NULL,
    inicio_real timestamp with time zone NOT NULL,
    termino_real timestamp with time zone,
    confirmado_por uuid,
    inicio_sin_cotizacion boolean DEFAULT false NOT NULL,
    observaciones text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT ck_ejecucion_termino CHECK (((termino_real IS NULL) OR (termino_real >= inicio_real)))
);


--
-- Name: empresa_ruc; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.empresa_ruc (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ruc character varying(20) NOT NULL,
    razon_social character varying(200) NOT NULL,
    nombre_corto character varying(80),
    estado core.estado_registro DEFAULT 'activo'::core.estado_registro NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


--
-- Name: liberacion_historial; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.liberacion_historial (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    secuencia bigint NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    orden_compra_id uuid,
    estado_anterior core.estado_liberacion,
    estado_nuevo core.estado_liberacion NOT NULL,
    monto_anterior numeric(14,2),
    monto_nuevo numeric(14,2) DEFAULT 0 NOT NULL,
    moneda core.moneda_codigo DEFAULT 'PEN'::core.moneda_codigo NOT NULL,
    observacion text,
    actor_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_liberacion_monto_anterior CHECK (((monto_anterior IS NULL) OR (monto_anterior >= (0)::numeric))),
    CONSTRAINT ck_liberacion_monto_positivo CHECK ((monto_nuevo >= (0)::numeric))
);


--
-- Name: liberacion_historial_secuencia_seq; Type: SEQUENCE; Schema: core; Owner: -
--

CREATE SEQUENCE core.liberacion_historial_secuencia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: liberacion_historial_secuencia_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: -
--

ALTER SEQUENCE core.liberacion_historial_secuencia_seq OWNED BY core.liberacion_historial.secuencia;


--
-- Name: mensaje; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.mensaje (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    conversacion_id uuid NOT NULL,
    tipo core.tipo_mensaje DEFAULT 'humano'::core.tipo_mensaje NOT NULL,
    visibilidad core.visibilidad_mensaje DEFAULT 'canal'::core.visibilidad_mensaje NOT NULL,
    estado core.estado_mensaje DEFAULT 'publicado'::core.estado_mensaje NOT NULL,
    cuerpo text NOT NULL,
    cuerpo_anterior text,
    responde_a uuid,
    autor_id uuid,
    menciones uuid[] DEFAULT '{}'::uuid[] NOT NULL,
    editado_at timestamp with time zone,
    retirado_at timestamp with time zone,
    retirado_por uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_mensaje_autor CHECK (((tipo = 'sistema'::core.tipo_mensaje) OR (autor_id IS NOT NULL)))
);


--
-- Name: notificacion; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.notificacion (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    destinatario_id uuid NOT NULL,
    evento character varying(60) NOT NULL,
    titulo character varying(200) NOT NULL,
    cuerpo text,
    entidad_tipo character varying(40),
    entidad_id uuid,
    ot_id uuid,
    canal core.canal_notificacion DEFAULT 'interno'::core.canal_notificacion NOT NULL,
    estado core.estado_notificacion DEFAULT 'pendiente'::core.estado_notificacion NOT NULL,
    leida_at timestamp with time zone,
    error_envio text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: orden_compra; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.orden_compra (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    solped_id uuid,
    numero_oc character varying(40) NOT NULL,
    fecha_oc date,
    monto numeric(14,2),
    moneda core.moneda_codigo DEFAULT 'PEN'::core.moneda_codigo NOT NULL,
    observacion text,
    anulada boolean DEFAULT false NOT NULL,
    motivo_anulacion text,
    registrada_por uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT ck_orden_compra_monto CHECK (((monto IS NULL) OR (monto >= (0)::numeric)))
);


--
-- Name: ot_avance; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.ot_avance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    descripcion text NOT NULL,
    porcentaje numeric(5,2),
    autor_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_avance_descripcion CHECK ((btrim(descripcion) <> ''::text)),
    CONSTRAINT ck_avance_porcentaje CHECK (((porcentaje IS NULL) OR ((porcentaje >= (0)::numeric) AND (porcentaje <= (100)::numeric))))
);


--
-- Name: ot_cierre; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.ot_cierre (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    secuencia integer NOT NULL,
    vigente boolean DEFAULT true NOT NULL,
    fecha_cierre timestamp with time zone DEFAULT now() NOT NULL,
    cerrado_por uuid NOT NULL,
    admin_revisado boolean DEFAULT false NOT NULL,
    estado_admin_al_cierre core.estado_administrativo,
    observacion_pendiente text,
    derivadas_bloqueantes_resueltas boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ot_estado_historial; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.ot_estado_historial (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    estado_anterior core.ot_estado,
    estado_nuevo core.ot_estado NOT NULL,
    motivo_id uuid,
    motivo_texto text,
    actor_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ot_evento; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.ot_evento (
    id bigint NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    dominio core.dominio_evento NOT NULL,
    evento character varying(60) NOT NULL,
    entidad_tipo character varying(40),
    entidad_id uuid,
    valor_anterior jsonb,
    valor_nuevo jsonb,
    motivo text,
    actor_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE ot_evento; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON TABLE core.ot_evento IS 'Bitácora append-only e inmutable de la OT (cap. 18, 33). Sin UPDATE ni DELETE: los privilegios se revocan en 90_grants.sql.';


--
-- Name: ot_evento_id_seq; Type: SEQUENCE; Schema: core; Owner: -
--

CREATE SEQUENCE core.ot_evento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ot_evento_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: -
--

ALTER SEQUENCE core.ot_evento_id_seq OWNED BY core.ot_evento.id;


--
-- Name: ot_incidencia; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.ot_incidencia (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    tipo_id uuid,
    descripcion text NOT NULL,
    resuelta boolean DEFAULT false NOT NULL,
    resuelta_at timestamp with time zone,
    resolucion text,
    autor_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ot_pausa; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.ot_pausa (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    motivo_id uuid,
    motivo_texto text NOT NULL,
    fecha_pausa timestamp with time zone DEFAULT now() NOT NULL,
    fecha_reanudacion timestamp with time zone,
    observacion_reanudacion text,
    pausada_por uuid NOT NULL,
    reanudada_por uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_pausa_reanudacion CHECK (((fecha_reanudacion IS NULL) OR (fecha_reanudacion >= fecha_pausa)))
);


--
-- Name: ot_reapertura; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.ot_reapertura (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    cierre_id uuid,
    motivo_id uuid,
    motivo_texto text NOT NULL,
    estado_retorno core.ot_estado NOT NULL,
    reabierta_por uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_reapertura_estado CHECK ((estado_retorno = ANY (ARRAY['en_trabajo'::core.ot_estado, 'en_diagnostico'::core.ot_estado]))),
    CONSTRAINT ck_reapertura_motivo CHECK ((btrim(motivo_texto) <> ''::text))
);


--
-- Name: permiso; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.permiso (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    codigo character varying(80) NOT NULL,
    modulo character varying(40) NOT NULL,
    accion character varying(40) NOT NULL,
    descripcion text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: proveedor; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.proveedor (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ruc character varying(20),
    razon_social character varying(200) NOT NULL,
    contacto character varying(150),
    telefono character varying(30),
    email character varying(180),
    estado core.estado_registro DEFAULT 'activo'::core.estado_registro NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


--
-- Name: regla_normalizacion; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.regla_normalizacion (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patron text NOT NULL,
    descripcion_normalizada_id uuid NOT NULL,
    confianza numeric(4,3) DEFAULT 1.0 NOT NULL,
    aprobada boolean DEFAULT false NOT NULL,
    aprobada_por uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_regla_confianza CHECK (((confianza >= (0)::numeric) AND (confianza <= (1)::numeric)))
);


--
-- Name: rol; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.rol (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    codigo character varying(40) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    scope core.scope_rol DEFAULT 'tenant'::core.scope_rol NOT NULL,
    es_sistema boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: rol_permiso; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.rol_permiso (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rol_id uuid NOT NULL,
    permiso_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: seguimiento_administrativo; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.seguimiento_administrativo (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    estado_consolidado core.estado_administrativo DEFAULT 'sin_solped'::core.estado_administrativo NOT NULL,
    monto_liberado_total numeric(14,2) DEFAULT 0 NOT NULL,
    moneda core.moneda_codigo DEFAULT 'PEN'::core.moneda_codigo NOT NULL,
    revisado_por uuid,
    revisado_at timestamp with time zone,
    observacion text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT ck_seguimiento_monto CHECK ((monto_liberado_total >= (0)::numeric))
);


--
-- Name: solicitud_decision; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.solicitud_decision (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    solicitud_id uuid NOT NULL,
    tipo core.tipo_decision_solicitud NOT NULL,
    estado_anterior core.solicitud_estado,
    estado_nuevo core.solicitud_estado NOT NULL,
    motivo_id uuid,
    comentario text,
    destinatario_id uuid,
    solicitud_relacionada_id uuid,
    actor_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: solicitud_trabajo; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.solicitud_trabajo (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    numero character varying(30) NOT NULL,
    estado core.solicitud_estado DEFAULT 'borrador'::core.solicitud_estado NOT NULL,
    titulo character varying(180) NOT NULL,
    descripcion text NOT NULL,
    lugar text NOT NULL,
    impacto_operativo_id uuid,
    impacto_comentario text,
    prioridad_percibida core.prioridad,
    area_id uuid NOT NULL,
    empresa_ruc_id uuid NOT NULL,
    sucursal_id uuid,
    solicitante_id uuid NOT NULL,
    fecha_envio timestamp with time zone,
    fecha_primera_revision timestamp with time zone,
    coordinador_revisor_id uuid,
    solicitud_principal_id uuid,
    motivo_rechazo_id uuid,
    observacion_actual text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT ck_solicitud_descripcion CHECK ((char_length(btrim(descripcion)) >= 10)),
    CONSTRAINT ck_solicitud_no_autoduplicada CHECK (((solicitud_principal_id IS NULL) OR (solicitud_principal_id <> id))),
    CONSTRAINT ck_solicitud_titulo_largo CHECK (((char_length(btrim((titulo)::text)) >= 5) AND (char_length(btrim((titulo)::text)) <= 180)))
);


--
-- Name: solped; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.solped (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    version integer NOT NULL,
    vigente boolean DEFAULT true NOT NULL,
    numero_interno character varying(40),
    numero_sap character varying(40),
    referencia_externa character varying(80),
    estado_integracion core.solped_estado_integracion DEFAULT 'borrador'::core.solped_estado_integracion NOT NULL,
    formulario jsonb DEFAULT '{}'::jsonb NOT NULL,
    cotizacion_id uuid,
    monto numeric(14,2),
    moneda core.moneda_codigo DEFAULT 'PEN'::core.moneda_codigo NOT NULL,
    fecha_solped date,
    mensaje_sap text,
    intentos integer DEFAULT 0 NOT NULL,
    ultimo_intento_at timestamp with time zone,
    anulada boolean DEFAULT false NOT NULL,
    motivo_anulacion text,
    anulada_por uuid,
    anulada_at timestamp with time zone,
    reemplaza_a uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT ck_solped_anulacion CHECK (((anulada = false) OR (btrim(COALESCE(motivo_anulacion, ''::text)) <> ''::text))),
    CONSTRAINT ck_solped_monto CHECK (((monto IS NULL) OR (monto >= (0)::numeric)))
);


--
-- Name: sucursal; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.sucursal (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    codigo character varying(30) NOT NULL,
    nombre character varying(150) NOT NULL,
    direccion text,
    estado core.estado_registro DEFAULT 'activo'::core.estado_registro NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


--
-- Name: sucursal_empresa_ruc; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.sucursal_empresa_ruc (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    sucursal_id uuid NOT NULL,
    empresa_ruc_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tenant; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.tenant (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    codigo character varying(30) NOT NULL,
    nombre character varying(150) NOT NULL,
    zona_horaria character varying(60) DEFAULT 'America/Lima'::character varying NOT NULL,
    moneda_base core.moneda_codigo DEFAULT 'PEN'::core.moneda_codigo NOT NULL,
    estado core.estado_registro DEFAULT 'activo'::core.estado_registro NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


--
-- Name: tenant_configuracion; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.tenant_configuracion (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    clave character varying(80) NOT NULL,
    valor jsonb NOT NULL,
    descripcion text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid
);


--
-- Name: tipo_trabajo; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.tipo_trabajo (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    codigo character varying(60) NOT NULL,
    nombre character varying(150) NOT NULL,
    padre_id uuid,
    descripcion text,
    es_base boolean DEFAULT false NOT NULL,
    estado core.estado_registro DEFAULT 'activo'::core.estado_registro NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


--
-- Name: trabajo_realizado; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.trabajo_realizado (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    ot_id uuid NOT NULL,
    version integer NOT NULL,
    vigente boolean DEFAULT true NOT NULL,
    descripcion text NOT NULL,
    resultado_id uuid,
    resultado_texto text,
    fecha_termino timestamp with time zone NOT NULL,
    observaciones text,
    declarado_por uuid NOT NULL,
    resultado_revision core.resultado_revision,
    revision_observacion text,
    revisado_por uuid,
    revisado_at timestamp with time zone,
    conformidad core.conformidad_solicitante DEFAULT 'sin_pronunciarse'::core.conformidad_solicitante NOT NULL,
    conformidad_comentario text,
    conformidad_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT ck_trabajo_descripcion CHECK ((btrim(descripcion) <> ''::text))
);


--
-- Name: usuario; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.usuario (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    email character varying(180) NOT NULL,
    password_hash text,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    documento character varying(20),
    telefono character varying(30),
    cargo character varying(100),
    estado core.estado_usuario DEFAULT 'activo'::core.estado_usuario NOT NULL,
    is_super_admin boolean DEFAULT false NOT NULL,
    ultimo_acceso_at timestamp with time zone,
    preferencias jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by uuid,
    updated_by uuid,
    intentos_fallidos integer DEFAULT 0 NOT NULL,
    bloqueado_hasta timestamp with time zone,
    ultimo_intento_fallido_at timestamp with time zone
);


--
-- Name: usuario_alcance; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.usuario_alcance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    usuario_id uuid NOT NULL,
    sucursal_id uuid,
    empresa_ruc_id uuid,
    area_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);


--
-- Name: usuario_rol; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.usuario_rol (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    rol_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);


--
-- Name: audit_log id; Type: DEFAULT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_log ALTER COLUMN id SET DEFAULT nextval('audit.audit_log_id_seq'::regclass);


--
-- Name: liberacion_historial secuencia; Type: DEFAULT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.liberacion_historial ALTER COLUMN secuencia SET DEFAULT nextval('core.liberacion_historial_secuencia_seq'::regclass);


--
-- Name: ot_evento id; Type: DEFAULT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_evento ALTER COLUMN id SET DEFAULT nextval('core.ot_evento_id_seq'::regclass);


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: audit; Owner: -
--

COPY audit.audit_log (id, tenant_id, actor_id, accion, entidad, entidad_id, valor_anterior, valor_nuevo, diff, motivo, ip, user_agent, request_id, created_at) FROM stdin;
1	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	login	usuario	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:11.145058-05
2	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	login	usuario	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:11.389308-05
3	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	{"id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "cargo": "Coordinadora de mantenimiento", "email": "rosa.quispe@demoindustrial.pe", "estado": "activo", "nombres": "Rosa", "telefono": null, "apellidos": "Quispe Vargas", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:11.609412-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:11.609412-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:11.609412-05
4	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	login	usuario	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:11.790116-05
5	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	\N	{"id": "8b99e5c2-f44f-4d1e-84e5-f658747ba01c", "cargo": "Coordinador de taller", "email": "julio.paredes@demoindustrial.pe", "estado": "activo", "nombres": "Julio", "telefono": null, "apellidos": "Paredes Ramos", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:11.973119-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:11.973119-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:11.973119-05
6	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	login	usuario	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:12.153295-05
7	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	5a11b0c5-7640-494f-9c8b-64a9a4e30673	\N	{"id": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "cargo": "Técnico mecánico", "email": "marco.tuesta@demoindustrial.pe", "estado": "activo", "nombres": "Marco", "telefono": null, "apellidos": "Tuesta Ríos", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:12.3373-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:12.3373-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:12.3373-05
8	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	login	usuario	5a11b0c5-7640-494f-9c8b-64a9a4e30673	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:12.520818-05
9	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	a7ee34e2-43bd-496d-99b0-ad8013072cea	\N	{"id": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "cargo": "Técnica electricista", "email": "elena.chavez@demoindustrial.pe", "estado": "activo", "nombres": "Elena", "telefono": null, "apellidos": "Chávez Soto", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:12.703354-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:12.703354-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:12.703354-05
10	5c921062-21ab-4a01-8f9a-2e2500e95893	a7ee34e2-43bd-496d-99b0-ad8013072cea	login	usuario	a7ee34e2-43bd-496d-99b0-ad8013072cea	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:12.8839-05
11	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	\N	{"id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "cargo": "Técnico hidráulico", "email": "victor.ramos@demoindustrial.pe", "estado": "activo", "nombres": "Víctor", "telefono": null, "apellidos": "Ramos Núñez", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:13.065438-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:13.065438-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:13.065438-05
12	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	login	usuario	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:13.249163-05
13	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	96364941-9f48-4525-8edd-565c4d37949d	\N	{"id": "96364941-9f48-4525-8edd-565c4d37949d", "cargo": "Analista de abastecimiento", "email": "carla.mendoza@demoindustrial.pe", "estado": "activo", "nombres": "Carla", "telefono": null, "apellidos": "Mendoza León", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:13.428616-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:13.428616-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:13.428616-05
14	5c921062-21ab-4a01-8f9a-2e2500e95893	96364941-9f48-4525-8edd-565c4d37949d	login	usuario	96364941-9f48-4525-8edd-565c4d37949d	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:13.61196-05
15	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	f71701ef-202b-4563-9c16-10f1d41b8135	\N	{"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "cargo": "Supervisor de producción", "email": "pedro.aliaga@demoindustrial.pe", "estado": "activo", "nombres": "Pedro", "telefono": null, "apellidos": "Aliaga Vera", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:13.796344-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:13.796344-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:13.796344-05
16	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	login	usuario	f71701ef-202b-4563-9c16-10f1d41b8135	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:13.980139-05
17	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	89f7a8be-5af2-4d60-b578-9d01db2edce0	\N	{"id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "cargo": "Jefa de almacén", "email": "nancy.ortiz@demoindustrial.pe", "estado": "activo", "nombres": "Nancy", "telefono": null, "apellidos": "Ortiz Huamán", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:14.163446-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:14.163446-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:14.163446-05
18	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	login	usuario	89f7a8be-5af2-4d60-b578-9d01db2edce0	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:14.353549-05
19	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	usuario	3f242551-ee85-4b4e-aa57-c7ab67215e58	\N	{"id": "3f242551-ee85-4b4e-aa57-c7ab67215e58", "cargo": "Gerente de operaciones", "email": "andres.ferrer@demoindustrial.pe", "estado": "activo", "nombres": "Andrés", "telefono": null, "apellidos": "Ferrer Díaz", "documento": null, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:14.551007-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:14.551007-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "preferencias": {}, "is_super_admin": false, "bloqueado_hasta": null, "ultimo_acceso_at": null, "intentos_fallidos": 0, "ultimo_intento_fallido_at": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:14.551007-05
20	5c921062-21ab-4a01-8f9a-2e2500e95893	3f242551-ee85-4b4e-aa57-c7ab67215e58	login	usuario	3f242551-ee85-4b4e-aa57-c7ab67215e58	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:14.743039-05
21	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	c5d4a2a9-9988-4d7a-ad76-555e3020bafe	\N	{"id": "c5d4a2a9-9988-4d7a-ad76-555e3020bafe", "lugar": "Sala de compresores, nivel 1", "estado": "enviada", "numero": "ST-000001", "titulo": "Compresor de planta pierde presión", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:14.965094-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:14.965094-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Desde el martes el compresor no mantiene los 8 bar y la línea de pintura se queda sin aire a media jornada.", "fecha_envio": "2026-09-20T15:34:14.965094-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "alta", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:14.965094-05
23	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	crear	diagnostico	6aaf55e9-be62-46ac-a9bb-9689b116d49f	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "6aaf55e9-be62-46ac-a9bb-9689b116d49f", "ot_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "alcance": "Segunda etapa del compresor; el motor eléctrico queda fuera.", "version": 1, "vigente": true, "autor_id": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.003489-05:00", "created_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "updated_at": "2026-09-20T15:34:15.003489-05:00", "updated_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "aprobado_at": null, "diagnostico": "Válvula de admisión de la segunda etapa con fuga y anillos desgastados.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Horas de servicio por encima del plan de mantenimiento.", "trabajo_a_realizar": "Reemplazar kit de válvulas y anillos, cambiar aceite y probar cuatro horas.", "lecturas_instrumentos": "Presión 5,8 bar · temperatura de descarga 96 °C"}	{"id": {"antes": null, "despues": "6aaf55e9-be62-46ac-a9bb-9689b116d49f"}, "ot_id": {"antes": null, "despues": "be7b33db-85f9-4955-953c-f4e24d864dcc"}, "alcance": {"antes": null, "despues": "Segunda etapa del compresor; el motor eléctrico queda fuera."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.003489-05:00"}, "created_by": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.003489-05:00"}, "updated_by": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "diagnostico": {"antes": null, "despues": "Válvula de admisión de la segunda etapa con fuga y anillos desgastados."}, "causa_probable": {"antes": null, "despues": "Horas de servicio por encima del plan de mantenimiento."}, "trabajo_a_realizar": {"antes": null, "despues": "Reemplazar kit de válvulas y anillos, cambiar aceite y probar cuatro horas."}, "lecturas_instrumentos": {"antes": null, "despues": "Presión 5,8 bar · temperatura de descarga 96 °C"}}	\N	\N	\N	\N	2026-09-20 15:34:15.003489-05
24	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cargar	cotizacion	8ae2a1b6-3d59-429f-abbf-8ea949d00930	{"id": null, "monto": null, "ot_id": null, "moneda": null, "version": null, "vigente": null, "tenant_id": null, "created_at": null, "created_by": null, "invalidada": null, "updated_at": null, "updated_by": null, "cargada_por": null, "reemplaza_a": null, "proveedor_id": null, "validez_dias": null, "observaciones": null, "proveedor_ruc": null, "fecha_cotizacion": null, "motivo_reemplazo": null, "proveedor_nombre": null, "numero_cotizacion": null, "plazo_ofrecido_dias": null}	{"id": "8ae2a1b6-3d59-429f-abbf-8ea949d00930", "monto": 4850.00, "ot_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "moneda": "PEN", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.024621-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "invalidada": false, "updated_at": "2026-09-20T15:34:15.024621-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "cargada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "reemplaza_a": null, "proveedor_id": "65d951bb-e837-4af9-9d40-218eb27f8abc", "validez_dias": 30, "observaciones": "Incluye kit original, mano de obra y puesta en marcha.", "proveedor_ruc": "20512345671", "fecha_cotizacion": "2026-09-14", "motivo_reemplazo": null, "proveedor_nombre": "SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C.", "numero_cotizacion": "COT-2026-0412", "plazo_ofrecido_dias": 7}	{"id": {"antes": null, "despues": "8ae2a1b6-3d59-429f-abbf-8ea949d00930"}, "monto": {"antes": null, "despues": 4850.00}, "ot_id": {"antes": null, "despues": "be7b33db-85f9-4955-953c-f4e24d864dcc"}, "moneda": {"antes": null, "despues": "PEN"}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.024621-05:00"}, "created_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "invalidada": {"antes": null, "despues": false}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.024621-05:00"}, "updated_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "cargada_por": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "proveedor_id": {"antes": null, "despues": "65d951bb-e837-4af9-9d40-218eb27f8abc"}, "validez_dias": {"antes": null, "despues": 30}, "observaciones": {"antes": null, "despues": "Incluye kit original, mano de obra y puesta en marcha."}, "proveedor_ruc": {"antes": null, "despues": "20512345671"}, "fecha_cotizacion": {"antes": null, "despues": "2026-09-14"}, "proveedor_nombre": {"antes": null, "despues": "SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C."}, "numero_cotizacion": {"antes": null, "despues": "COT-2026-0412"}, "plazo_ofrecido_dias": {"antes": null, "despues": 7}}	\N	\N	\N	\N	2026-09-20 15:34:15.024621-05
26	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	declarar	trabajo_realizado	b02261e6-c664-4abb-bf31-fa2cf4420cce	\N	{"id": "b02261e6-c664-4abb-bf31-fa2cf4420cce", "ot_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.13043-05:00", "created_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "updated_at": "2026-09-20T15:34:15.13043-05:00", "updated_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "conformidad": "sin_pronunciarse", "descripcion": "Kit de válvulas y anillos reemplazados. Cuatro horas de prueba sostenidas a 8,1 bar y 71 °C.", "revisado_at": null, "resultado_id": null, "revisado_por": null, "declarado_por": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "fecha_termino": "2026-09-20T15:34:15.13043-05:00", "observaciones": null, "conformidad_at": null, "resultado_texto": null, "resultado_revision": null, "revision_observacion": null, "conformidad_comentario": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.13043-05
27	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	revisar	trabajo_realizado	b02261e6-c664-4abb-bf31-fa2cf4420cce	\N	{"resultado": "aprobado"}	\N		\N	\N	\N	2026-09-20 15:34:15.151084-05
25	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	iniciar	ejecucion	be7b33db-85f9-4955-953c-f4e24d864dcc	\N	\N	\N	\N	\N	\N	\N	2026-08-16 08:34:15.044115-05
28	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	preparar	solped	7c3a47d5-5bb4-4a19-928e-836c0b5386f0	\N	{"id": "7c3a47d5-5bb4-4a19-928e-836c0b5386f0", "monto": 4850.00, "ot_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "moneda": "PEN", "anulada": false, "version": 1, "vigente": true, "intentos": 0, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "anulada_at": null, "created_at": "2026-09-20T15:34:15.168676-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "formulario": {}, "numero_sap": null, "updated_at": "2026-09-20T15:34:15.168676-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "anulada_por": null, "mensaje_sap": null, "reemplaza_a": null, "fecha_solped": "2026-09-20", "cotizacion_id": "8ae2a1b6-3d59-429f-abbf-8ea949d00930", "numero_interno": "OT-000001-SP1", "motivo_anulacion": null, "ultimo_intento_at": null, "estado_integracion": "borrador", "referencia_externa": "OT-000001-1-c648b37a"}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.168676-05
29	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	registrar_numero_sap	solped	7c3a47d5-5bb4-4a19-928e-836c0b5386f0	{"numero_sap": null}	{"numero_sap": "0010045612"}	{"numero_sap": {"antes": null, "despues": "0010045612"}}	\N	\N	\N	\N	2026-09-20 15:34:15.209901-05
30	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	registrar	orden_compra	a4885b26-f263-44c9-a0c0-27a9b056d34e	\N	{"id": "a4885b26-f263-44c9-a0c0-27a9b056d34e", "monto": 4850.00, "ot_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "moneda": "PEN", "anulada": false, "fecha_oc": null, "numero_oc": "4500231188", "solped_id": "7c3a47d5-5bb4-4a19-928e-836c0b5386f0", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.229154-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "updated_at": "2026-09-20T15:34:15.229154-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "observacion": null, "registrada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "motivo_anulacion": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.229154-05
33	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	crear	solicitud_trabajo	99d4f059-ece9-4360-9490-c612a98ede66	\N	{"id": "99d4f059-ece9-4360-9490-c612a98ede66", "lugar": "Taller 2", "estado": "enviada", "numero": "ST-000002", "titulo": "Puente grúa se detiene en el tramo central", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.292016-05:00", "created_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.292016-05:00", "updated_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "descripcion": "El puente grúa del taller 2 se corta a media carrera y hay que reiniciarlo desde el tablero.", "fecha_envio": "2026-09-20T15:34:15.292016-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "alta", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.292016-05
35	5c921062-21ab-4a01-8f9a-2e2500e95893	a7ee34e2-43bd-496d-99b0-ad8013072cea	crear	diagnostico	0d9044ca-0479-4db1-b404-af45ca79d91d	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "0d9044ca-0479-4db1-b404-af45ca79d91d", "ot_id": "14cd082a-4bcd-4661-8837-c47c4f762342", "alcance": "Tablero del carro principal.", "version": 1, "vigente": true, "autor_id": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.317312-05:00", "created_by": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "updated_at": "2026-09-20T15:34:15.317312-05:00", "updated_by": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "aprobado_at": null, "diagnostico": "Contactor del carro principal con carbonización en los contactos.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Arranques repetidos con carga máxima.", "trabajo_a_realizar": "Reemplazar contactor y revisar el ajuste del relé térmico.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "0d9044ca-0479-4db1-b404-af45ca79d91d"}, "ot_id": {"antes": null, "despues": "14cd082a-4bcd-4661-8837-c47c4f762342"}, "alcance": {"antes": null, "despues": "Tablero del carro principal."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.317312-05:00"}, "created_by": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.317312-05:00"}, "updated_by": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "diagnostico": {"antes": null, "despues": "Contactor del carro principal con carbonización en los contactos."}, "causa_probable": {"antes": null, "despues": "Arranques repetidos con carga máxima."}, "trabajo_a_realizar": {"antes": null, "despues": "Reemplazar contactor y revisar el ajuste del relé térmico."}}	\N	\N	\N	\N	2026-09-20 15:34:15.317312-05
32	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cerrar	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	{"estado": "trabajo_realizado"}	{"estado": "cerrada", "estado_administrativo": "administracion_completa"}	{"estado": {"antes": "trabajo_realizado", "despues": "cerrada"}, "estado_administrativo": {"antes": null, "despues": "administracion_completa"}}	\N	\N	\N	\N	2026-08-16 08:34:15.270008-05
36	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cargar	cotizacion	941e9e9a-0613-4288-a4f9-17a68d17668f	{"id": null, "monto": null, "ot_id": null, "moneda": null, "version": null, "vigente": null, "tenant_id": null, "created_at": null, "created_by": null, "invalidada": null, "updated_at": null, "updated_by": null, "cargada_por": null, "reemplaza_a": null, "proveedor_id": null, "validez_dias": null, "observaciones": null, "proveedor_ruc": null, "fecha_cotizacion": null, "motivo_reemplazo": null, "proveedor_nombre": null, "numero_cotizacion": null, "plazo_ofrecido_dias": null}	{"id": "941e9e9a-0613-4288-a4f9-17a68d17668f", "monto": 2140.00, "ot_id": "14cd082a-4bcd-4661-8837-c47c4f762342", "moneda": "PEN", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.333867-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "invalidada": false, "updated_at": "2026-09-20T15:34:15.333867-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "cargada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "reemplaza_a": null, "proveedor_id": "2dc1f1f5-4c5b-40d8-aeaf-1cad7d293eb7", "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20487654320", "fecha_cotizacion": "2026-09-14", "motivo_reemplazo": null, "proveedor_nombre": "ELECTROMONTAJES ANDINOS S.R.L.", "numero_cotizacion": "COT-2026-0418", "plazo_ofrecido_dias": 5}	{"id": {"antes": null, "despues": "941e9e9a-0613-4288-a4f9-17a68d17668f"}, "monto": {"antes": null, "despues": 2140.00}, "ot_id": {"antes": null, "despues": "14cd082a-4bcd-4661-8837-c47c4f762342"}, "moneda": {"antes": null, "despues": "PEN"}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.333867-05:00"}, "created_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "invalidada": {"antes": null, "despues": false}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.333867-05:00"}, "updated_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "cargada_por": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "proveedor_id": {"antes": null, "despues": "2dc1f1f5-4c5b-40d8-aeaf-1cad7d293eb7"}, "validez_dias": {"antes": null, "despues": 30}, "proveedor_ruc": {"antes": null, "despues": "20487654320"}, "fecha_cotizacion": {"antes": null, "despues": "2026-09-14"}, "proveedor_nombre": {"antes": null, "despues": "ELECTROMONTAJES ANDINOS S.R.L."}, "numero_cotizacion": {"antes": null, "despues": "COT-2026-0418"}, "plazo_ofrecido_dias": {"antes": null, "despues": 5}}	\N	\N	\N	\N	2026-09-20 15:34:15.333867-05
38	5c921062-21ab-4a01-8f9a-2e2500e95893	a7ee34e2-43bd-496d-99b0-ad8013072cea	declarar	trabajo_realizado	f5c474b7-fd66-41e9-8ef4-d907862cdd95	\N	{"id": "f5c474b7-fd66-41e9-8ef4-d907862cdd95", "ot_id": "14cd082a-4bcd-4661-8837-c47c4f762342", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.386203-05:00", "created_by": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "updated_at": "2026-09-20T15:34:15.386203-05:00", "updated_by": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "conformidad": "sin_pronunciarse", "descripcion": "Contactor nuevo instalado. Diez ciclos de prueba con carga nominal sin cortes.", "revisado_at": null, "resultado_id": null, "revisado_por": null, "declarado_por": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "fecha_termino": "2026-09-20T15:34:15.386203-05:00", "observaciones": null, "conformidad_at": null, "resultado_texto": null, "resultado_revision": null, "revision_observacion": null, "conformidad_comentario": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.386203-05
39	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	revisar	trabajo_realizado	f5c474b7-fd66-41e9-8ef4-d907862cdd95	\N	{"resultado": "aprobado"}	\N		\N	\N	\N	2026-09-20 15:34:15.405957-05
40	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	preparar	solped	ca6be66a-aa2f-4744-b6b3-77e1d9a58429	\N	{"id": "ca6be66a-aa2f-4744-b6b3-77e1d9a58429", "monto": 2140.00, "ot_id": "14cd082a-4bcd-4661-8837-c47c4f762342", "moneda": "PEN", "anulada": false, "version": 1, "vigente": true, "intentos": 0, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "anulada_at": null, "created_at": "2026-09-20T15:34:15.422972-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "formulario": {}, "numero_sap": null, "updated_at": "2026-09-20T15:34:15.422972-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "anulada_por": null, "mensaje_sap": null, "reemplaza_a": null, "fecha_solped": "2026-09-20", "cotizacion_id": "941e9e9a-0613-4288-a4f9-17a68d17668f", "numero_interno": "OT-000002-SP1", "motivo_anulacion": null, "ultimo_intento_at": null, "estado_integracion": "borrador", "referencia_externa": "OT-000002-1-3dd0e535"}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.422972-05
42	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	5787000f-3be4-46c8-849b-51b922142d11	\N	{"id": "5787000f-3be4-46c8-849b-51b922142d11", "lugar": "Nave de prensas", "estado": "enviada", "numero": "ST-000003", "titulo": "Fuga de aceite en la prensa hidráulica 3", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.460481-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.460481-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Hay un charco bajo la prensa al final de cada turno y el nivel del tanque baja.", "fecha_envio": "2026-09-20T15:34:15.460481-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "alta", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.460481-05
41	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cerrar	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	{"estado": "trabajo_realizado"}	{"estado": "cerrada", "estado_administrativo": "solped_pendiente"}	{"estado": {"antes": "trabajo_realizado", "despues": "cerrada"}, "estado_administrativo": {"antes": null, "despues": "solped_pendiente"}}	Compras emite la OC la próxima semana; el equipo ya está operativo.	\N	\N	\N	2026-08-15 12:34:15.441202-05
37	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	iniciar	ejecucion	14cd082a-4bcd-4661-8837-c47c4f762342	\N	\N	\N	\N	\N	\N	\N	2026-08-15 12:34:15.350916-05
44	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	crear	diagnostico	dd9a49f5-646a-4dbb-ac19-9b87263fc462	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "dd9a49f5-646a-4dbb-ac19-9b87263fc462", "ot_id": "569b23e3-2a8b-4dd7-9f5a-262524af1c93", "alcance": "Cilindro principal y filtro de retorno.", "version": 1, "vigente": true, "autor_id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.490058-05:00", "created_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "updated_at": "2026-09-20T15:34:15.490058-05:00", "updated_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "aprobado_at": null, "diagnostico": "Retén del cilindro principal vencido; pérdida continua por el vástago.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Desgaste por horas de servicio y partículas en el aceite.", "trabajo_a_realizar": "Reemplazar retenes, cambiar filtro y reponer aceite.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "dd9a49f5-646a-4dbb-ac19-9b87263fc462"}, "ot_id": {"antes": null, "despues": "569b23e3-2a8b-4dd7-9f5a-262524af1c93"}, "alcance": {"antes": null, "despues": "Cilindro principal y filtro de retorno."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.490058-05:00"}, "created_by": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.490058-05:00"}, "updated_by": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "diagnostico": {"antes": null, "despues": "Retén del cilindro principal vencido; pérdida continua por el vástago."}, "causa_probable": {"antes": null, "despues": "Desgaste por horas de servicio y partículas en el aceite."}, "trabajo_a_realizar": {"antes": null, "despues": "Reemplazar retenes, cambiar filtro y reponer aceite."}}	\N	\N	\N	\N	2026-09-20 15:34:15.490058-05
45	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cargar	cotizacion	8145f65b-f63d-4121-96eb-3a1e7775f9af	{"id": null, "monto": null, "ot_id": null, "moneda": null, "version": null, "vigente": null, "tenant_id": null, "created_at": null, "created_by": null, "invalidada": null, "updated_at": null, "updated_by": null, "cargada_por": null, "reemplaza_a": null, "proveedor_id": null, "validez_dias": null, "observaciones": null, "proveedor_ruc": null, "fecha_cotizacion": null, "motivo_reemplazo": null, "proveedor_nombre": null, "numero_cotizacion": null, "plazo_ofrecido_dias": null}	{"id": "8145f65b-f63d-4121-96eb-3a1e7775f9af", "monto": 3290.00, "ot_id": "569b23e3-2a8b-4dd7-9f5a-262524af1c93", "moneda": "PEN", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.508809-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "invalidada": false, "updated_at": "2026-09-20T15:34:15.508809-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "cargada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "reemplaza_a": null, "proveedor_id": "e33609de-3734-4b1b-badf-f08ce365c2a2", "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20456789014", "fecha_cotizacion": "2026-09-14", "motivo_reemplazo": null, "proveedor_nombre": "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", "numero_cotizacion": "COT-2026-0421", "plazo_ofrecido_dias": 10}	{"id": {"antes": null, "despues": "8145f65b-f63d-4121-96eb-3a1e7775f9af"}, "monto": {"antes": null, "despues": 3290.00}, "ot_id": {"antes": null, "despues": "569b23e3-2a8b-4dd7-9f5a-262524af1c93"}, "moneda": {"antes": null, "despues": "PEN"}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.508809-05:00"}, "created_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "invalidada": {"antes": null, "despues": false}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.508809-05:00"}, "updated_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "cargada_por": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "proveedor_id": {"antes": null, "despues": "e33609de-3734-4b1b-badf-f08ce365c2a2"}, "validez_dias": {"antes": null, "despues": 30}, "proveedor_ruc": {"antes": null, "despues": "20456789014"}, "fecha_cotizacion": {"antes": null, "despues": "2026-09-14"}, "proveedor_nombre": {"antes": null, "despues": "HIDRÁULICA INDUSTRIAL LIMA S.A.C."}, "numero_cotizacion": {"antes": null, "despues": "COT-2026-0421"}, "plazo_ofrecido_dias": {"antes": null, "despues": 10}}	\N	\N	\N	\N	2026-09-20 15:34:15.508809-05
47	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	0c01b409-e417-4a5b-baad-acba87bbf851	\N	{"id": "0c01b409-e417-4a5b-baad-acba87bbf851", "lugar": "Laboratorio de pruebas", "estado": "enviada", "numero": "ST-000004", "titulo": "Banco de pruebas sin lectura de par", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.599742-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.599742-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "El banco no muestra el par en pantalla; marca cero con el motor girando.", "fecha_envio": "2026-09-20T15:34:15.599742-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "media", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.599742-05
46	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	iniciar	ejecucion	569b23e3-2a8b-4dd7-9f5a-262524af1c93	\N	\N	\N	\N	\N	\N	\N	2026-09-08 05:34:15.529557-05
49	5c921062-21ab-4a01-8f9a-2e2500e95893	a7ee34e2-43bd-496d-99b0-ad8013072cea	crear	diagnostico	ea9f0825-89c1-4aae-a404-c87094cfea37	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "ea9f0825-89c1-4aae-a404-c87094cfea37", "ot_id": "1400addf-2f07-4784-a1f6-62c95da13ef1", "alcance": "Celda de carga y su cableado.", "version": 1, "vigente": true, "autor_id": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.627826-05:00", "created_by": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "updated_at": "2026-09-20T15:34:15.627826-05:00", "updated_by": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "aprobado_at": null, "diagnostico": "Celda de carga sin señal; el amplificador entrega 0 mV con carga aplicada.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Celda dañada por sobrecarga en la última prueba.", "trabajo_a_realizar": "Reemplazar la celda, recalibrar el banco y emitir certificado.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "ea9f0825-89c1-4aae-a404-c87094cfea37"}, "ot_id": {"antes": null, "despues": "1400addf-2f07-4784-a1f6-62c95da13ef1"}, "alcance": {"antes": null, "despues": "Celda de carga y su cableado."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.627826-05:00"}, "created_by": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.627826-05:00"}, "updated_by": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "diagnostico": {"antes": null, "despues": "Celda de carga sin señal; el amplificador entrega 0 mV con carga aplicada."}, "causa_probable": {"antes": null, "despues": "Celda dañada por sobrecarga en la última prueba."}, "trabajo_a_realizar": {"antes": null, "despues": "Reemplazar la celda, recalibrar el banco y emitir certificado."}}	\N	\N	\N	\N	2026-09-20 15:34:15.627826-05
50	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cargar	cotizacion	20dd8496-ea84-44bb-8740-a36c597b1147	{"id": null, "monto": null, "ot_id": null, "moneda": null, "version": null, "vigente": null, "tenant_id": null, "created_at": null, "created_by": null, "invalidada": null, "updated_at": null, "updated_by": null, "cargada_por": null, "reemplaza_a": null, "proveedor_id": null, "validez_dias": null, "observaciones": null, "proveedor_ruc": null, "fecha_cotizacion": null, "motivo_reemplazo": null, "proveedor_nombre": null, "numero_cotizacion": null, "plazo_ofrecido_dias": null}	{"id": "20dd8496-ea84-44bb-8740-a36c597b1147", "monto": 7800.00, "ot_id": "1400addf-2f07-4784-a1f6-62c95da13ef1", "moneda": "PEN", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.645482-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "invalidada": false, "updated_at": "2026-09-20T15:34:15.645482-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "cargada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "reemplaza_a": null, "proveedor_id": "74322f64-4408-4da3-b4af-f6e53dbcf203", "validez_dias": 30, "observaciones": "Celda importada; incluye certificado de calibración.", "proveedor_ruc": "20398765436", "fecha_cotizacion": "2026-09-14", "motivo_reemplazo": null, "proveedor_nombre": "INSTRUMENTACIÓN Y CONTROL S.A.", "numero_cotizacion": "COT-2026-0425", "plazo_ofrecido_dias": 21}	{"id": {"antes": null, "despues": "20dd8496-ea84-44bb-8740-a36c597b1147"}, "monto": {"antes": null, "despues": 7800.00}, "ot_id": {"antes": null, "despues": "1400addf-2f07-4784-a1f6-62c95da13ef1"}, "moneda": {"antes": null, "despues": "PEN"}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.645482-05:00"}, "created_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "invalidada": {"antes": null, "despues": false}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.645482-05:00"}, "updated_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "cargada_por": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "proveedor_id": {"antes": null, "despues": "74322f64-4408-4da3-b4af-f6e53dbcf203"}, "validez_dias": {"antes": null, "despues": 30}, "observaciones": {"antes": null, "despues": "Celda importada; incluye certificado de calibración."}, "proveedor_ruc": {"antes": null, "despues": "20398765436"}, "fecha_cotizacion": {"antes": null, "despues": "2026-09-14"}, "proveedor_nombre": {"antes": null, "despues": "INSTRUMENTACIÓN Y CONTROL S.A."}, "numero_cotizacion": {"antes": null, "despues": "COT-2026-0425"}, "plazo_ofrecido_dias": {"antes": null, "despues": 21}}	\N	\N	\N	\N	2026-09-20 15:34:15.645482-05
52	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	crear	solicitud_trabajo	15e5d80b-173b-451f-a58f-f49dd40813e9	\N	{"id": "15e5d80b-173b-451f-a58f-f49dd40813e9", "lugar": "Almacén central", "estado": "enviada", "numero": "ST-000005", "titulo": "Portón del almacén no cierra completo", "area_id": "a8d349a2-f03d-44c0-a268-42264076d560", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.716094-05:00", "created_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.716094-05:00", "updated_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "descripcion": "Queda una luz de veinte centímetros y entra polvo al almacén.", "fecha_envio": "2026-09-20T15:34:15.716094-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "baja", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.716094-05
54	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	crear	diagnostico	f02374ce-1ee7-40b8-99c8-e794d5c77646	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "f02374ce-1ee7-40b8-99c8-e794d5c77646", "ot_id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "alcance": "Guía inferior y sensores de final de carrera.", "version": 1, "vigente": true, "autor_id": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.742902-05:00", "created_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "updated_at": "2026-09-20T15:34:15.742902-05:00", "updated_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "aprobado_at": null, "diagnostico": "Guía inferior deformada y final de carrera descalibrado.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Golpe de montacargas contra la guía.", "trabajo_a_realizar": "Enderezar la guía, reemplazar el sensor y recalibrar recorrido.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "f02374ce-1ee7-40b8-99c8-e794d5c77646"}, "ot_id": {"antes": null, "despues": "bd61bf6d-abeb-487f-91eb-3281f93643f0"}, "alcance": {"antes": null, "despues": "Guía inferior y sensores de final de carrera."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.742902-05:00"}, "created_by": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.742902-05:00"}, "updated_by": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "diagnostico": {"antes": null, "despues": "Guía inferior deformada y final de carrera descalibrado."}, "causa_probable": {"antes": null, "despues": "Golpe de montacargas contra la guía."}, "trabajo_a_realizar": {"antes": null, "despues": "Enderezar la guía, reemplazar el sensor y recalibrar recorrido."}}	\N	\N	\N	\N	2026-09-20 15:34:15.742902-05
55	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cargar	cotizacion	fee02c0d-bc83-47cd-b082-7f25428e0fd3	{"id": null, "monto": null, "ot_id": null, "moneda": null, "version": null, "vigente": null, "tenant_id": null, "created_at": null, "created_by": null, "invalidada": null, "updated_at": null, "updated_by": null, "cargada_por": null, "reemplaza_a": null, "proveedor_id": null, "validez_dias": null, "observaciones": null, "proveedor_ruc": null, "fecha_cotizacion": null, "motivo_reemplazo": null, "proveedor_nombre": null, "numero_cotizacion": null, "plazo_ofrecido_dias": null}	{"id": "fee02c0d-bc83-47cd-b082-7f25428e0fd3", "monto": 1180.00, "ot_id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "moneda": "PEN", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.759791-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "invalidada": false, "updated_at": "2026-09-20T15:34:15.759791-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "cargada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "reemplaza_a": null, "proveedor_id": "b89663d0-2b51-40b1-8e21-488ff2328367", "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20567890121", "fecha_cotizacion": "2026-09-14", "motivo_reemplazo": null, "proveedor_nombre": "PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L.", "numero_cotizacion": "COT-2026-0430", "plazo_ofrecido_dias": 4}	{"id": {"antes": null, "despues": "fee02c0d-bc83-47cd-b082-7f25428e0fd3"}, "monto": {"antes": null, "despues": 1180.00}, "ot_id": {"antes": null, "despues": "bd61bf6d-abeb-487f-91eb-3281f93643f0"}, "moneda": {"antes": null, "despues": "PEN"}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.759791-05:00"}, "created_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "invalidada": {"antes": null, "despues": false}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.759791-05:00"}, "updated_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "cargada_por": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "proveedor_id": {"antes": null, "despues": "b89663d0-2b51-40b1-8e21-488ff2328367"}, "validez_dias": {"antes": null, "despues": 30}, "proveedor_ruc": {"antes": null, "despues": "20567890121"}, "fecha_cotizacion": {"antes": null, "despues": "2026-09-14"}, "proveedor_nombre": {"antes": null, "despues": "PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L."}, "numero_cotizacion": {"antes": null, "despues": "COT-2026-0430"}, "plazo_ofrecido_dias": {"antes": null, "despues": 4}}	\N	\N	\N	\N	2026-09-20 15:34:15.759791-05
57	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	declarar	trabajo_realizado	7f6624ce-bf77-4289-ba48-4ca5a7a3a478	\N	{"id": "7f6624ce-bf77-4289-ba48-4ca5a7a3a478", "ot_id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.795487-05:00", "created_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "updated_at": "2026-09-20T15:34:15.795487-05:00", "updated_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "conformidad": "sin_pronunciarse", "descripcion": "Guía enderezada, sensor nuevo y recorrido recalibrado. El portón cierra a ras de piso.", "revisado_at": null, "resultado_id": null, "revisado_por": null, "declarado_por": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "fecha_termino": "2026-09-20T15:34:15.795487-05:00", "observaciones": null, "conformidad_at": null, "resultado_texto": null, "resultado_revision": null, "revision_observacion": null, "conformidad_comentario": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.795487-05
58	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	6b1ecb72-330f-4e70-8e65-14b41fd94f77	\N	{"id": "6b1ecb72-330f-4e70-8e65-14b41fd94f77", "lugar": "Cabina de pintura", "estado": "enviada", "numero": "ST-000006", "titulo": "Ruido metálico en el ventilador de extracción", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.813004-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.813004-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Se oye un golpeteo al arrancar y vibra más de lo normal.", "fecha_envio": "2026-09-20T15:34:15.813004-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "media", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.813004-05
60	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	crear	diagnostico	58f91adb-9c05-4eb7-8d60-ceedb7194255	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "58f91adb-9c05-4eb7-8d60-ceedb7194255", "ot_id": "2b0e0c54-42f5-45ce-9ff5-10b069071a30", "alcance": "Conjunto motriz del ventilador.", "version": 1, "vigente": true, "autor_id": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.836675-05:00", "created_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "updated_at": "2026-09-20T15:34:15.836675-05:00", "updated_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "aprobado_at": null, "diagnostico": "Rodamiento del lado libre con juego axial de 0,6 mm.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Desalineación acumulada por asentamiento de la base.", "trabajo_a_realizar": "Reemplazar rodamientos, alinear con láser y balancear el rotor.", "lecturas_instrumentos": "Vibración 7,2 mm/s · temperatura 78 °C"}	{"id": {"antes": null, "despues": "58f91adb-9c05-4eb7-8d60-ceedb7194255"}, "ot_id": {"antes": null, "despues": "2b0e0c54-42f5-45ce-9ff5-10b069071a30"}, "alcance": {"antes": null, "despues": "Conjunto motriz del ventilador."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.836675-05:00"}, "created_by": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.836675-05:00"}, "updated_by": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "diagnostico": {"antes": null, "despues": "Rodamiento del lado libre con juego axial de 0,6 mm."}, "causa_probable": {"antes": null, "despues": "Desalineación acumulada por asentamiento de la base."}, "trabajo_a_realizar": {"antes": null, "despues": "Reemplazar rodamientos, alinear con láser y balancear el rotor."}, "lecturas_instrumentos": {"antes": null, "despues": "Vibración 7,2 mm/s · temperatura 78 °C"}}	\N	\N	\N	\N	2026-09-20 15:34:15.836675-05
56	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	iniciar	ejecucion	bd61bf6d-abeb-487f-91eb-3281f93643f0	\N	\N	\N	\N	\N	\N	\N	2026-09-06 13:34:15.777671-05
61	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cargar	cotizacion	f9af5c86-a168-40ec-a440-0c0fc849c120	{"id": null, "monto": null, "ot_id": null, "moneda": null, "version": null, "vigente": null, "tenant_id": null, "created_at": null, "created_by": null, "invalidada": null, "updated_at": null, "updated_by": null, "cargada_por": null, "reemplaza_a": null, "proveedor_id": null, "validez_dias": null, "observaciones": null, "proveedor_ruc": null, "fecha_cotizacion": null, "motivo_reemplazo": null, "proveedor_nombre": null, "numero_cotizacion": null, "plazo_ofrecido_dias": null}	{"id": "f9af5c86-a168-40ec-a440-0c0fc849c120", "monto": 2850.00, "ot_id": "2b0e0c54-42f5-45ce-9ff5-10b069071a30", "moneda": "PEN", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.853975-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "invalidada": false, "updated_at": "2026-09-20T15:34:15.853975-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "cargada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "reemplaza_a": null, "proveedor_id": "d78f64df-a44d-4ed8-a2b2-3ca5a7b26955", "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20555123451", "fecha_cotizacion": "2026-09-14", "motivo_reemplazo": null, "proveedor_nombre": "RECTIFICACIONES DEL SUR S.A.C.", "numero_cotizacion": "COT-2026-0433", "plazo_ofrecido_dias": 12}	{"id": {"antes": null, "despues": "f9af5c86-a168-40ec-a440-0c0fc849c120"}, "monto": {"antes": null, "despues": 2850.00}, "ot_id": {"antes": null, "despues": "2b0e0c54-42f5-45ce-9ff5-10b069071a30"}, "moneda": {"antes": null, "despues": "PEN"}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.853975-05:00"}, "created_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "invalidada": {"antes": null, "despues": false}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.853975-05:00"}, "updated_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "cargada_por": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "proveedor_id": {"antes": null, "despues": "d78f64df-a44d-4ed8-a2b2-3ca5a7b26955"}, "validez_dias": {"antes": null, "despues": 30}, "proveedor_ruc": {"antes": null, "despues": "20555123451"}, "fecha_cotizacion": {"antes": null, "despues": "2026-09-14"}, "proveedor_nombre": {"antes": null, "despues": "RECTIFICACIONES DEL SUR S.A.C."}, "numero_cotizacion": {"antes": null, "despues": "COT-2026-0433"}, "plazo_ofrecido_dias": {"antes": null, "despues": 12}}	\N	\N	\N	\N	2026-09-20 15:34:15.853975-05
62	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	e54dbab5-2c51-433d-9c19-0400620d5f99	\N	{"id": "e54dbab5-2c51-433d-9c19-0400620d5f99", "lugar": "Casa de fuerza", "estado": "enviada", "numero": "ST-000007", "titulo": "Caldera se apaga sola por las noches", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.870973-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.870973-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Amanece apagada dos o tres veces por semana y hay que reencenderla manualmente.", "fecha_envio": "2026-09-20T15:34:15.870973-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "alta", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.870973-05
64	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	crear	diagnostico	6c790e33-e72e-41e8-8b39-f674aee35b27	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "6c790e33-e72e-41e8-8b39-f674aee35b27", "ot_id": "f1c60e96-9925-4aa2-a68b-00a72489fd2f", "alcance": "Lazo de control de presión.", "version": 1, "vigente": true, "autor_id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.894171-05:00", "created_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "updated_at": "2026-09-20T15:34:15.894171-05:00", "updated_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "aprobado_at": null, "diagnostico": "Presostato de seguridad corta por presión baja durante la noche.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Ajuste del presostato demasiado cerca del mínimo de operación.", "trabajo_a_realizar": "Reajustar el presostato y monitorear una semana.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "6c790e33-e72e-41e8-8b39-f674aee35b27"}, "ot_id": {"antes": null, "despues": "f1c60e96-9925-4aa2-a68b-00a72489fd2f"}, "alcance": {"antes": null, "despues": "Lazo de control de presión."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.894171-05:00"}, "created_by": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.894171-05:00"}, "updated_by": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "diagnostico": {"antes": null, "despues": "Presostato de seguridad corta por presión baja durante la noche."}, "causa_probable": {"antes": null, "despues": "Ajuste del presostato demasiado cerca del mínimo de operación."}, "trabajo_a_realizar": {"antes": null, "despues": "Reajustar el presostato y monitorear una semana."}}	\N	\N	\N	\N	2026-09-20 15:34:15.894171-05
65	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	reemplazar	diagnostico	a7d1acee-a648-4a11-97e3-449d55bfd2a5	{"id": "6c790e33-e72e-41e8-8b39-f674aee35b27", "ot_id": "f1c60e96-9925-4aa2-a68b-00a72489fd2f", "alcance": "Lazo de control de presión.", "version": 1, "vigente": true, "autor_id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.894171-05:00", "created_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "updated_at": "2026-09-20T15:34:15.894171-05:00", "updated_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "aprobado_at": null, "diagnostico": "Presostato de seguridad corta por presión baja durante la noche.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Ajuste del presostato demasiado cerca del mínimo de operación.", "trabajo_a_realizar": "Reajustar el presostato y monitorear una semana.", "lecturas_instrumentos": null}	{"id": "a7d1acee-a648-4a11-97e3-449d55bfd2a5", "ot_id": "f1c60e96-9925-4aa2-a68b-00a72489fd2f", "alcance": "Se amplía al tren de válvulas y a la acometida de gas.", "version": 2, "vigente": true, "autor_id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.912279-05:00", "created_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "updated_at": "2026-09-20T15:34:15.912279-05:00", "updated_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "aprobado_at": null, "diagnostico": "El corte lo provoca la válvula de gas, que cierra por caída de presión en la red, no el presostato.", "reemplaza_a": "6c790e33-e72e-41e8-8b39-f674aee35b27", "aprobado_por": null, "motivo_cambio": "El registro nocturno descartó el presostato: la presión de red cae antes del corte.", "observaciones": null, "causa_probable": "Caída de presión de red en horario nocturno, cuando la planta vecina consume.", "trabajo_a_realizar": "Instalar registrador de presión en la acometida y evaluar regulador de mayor capacidad.", "lecturas_instrumentos": "Presión de red 18 mbar a las 02:40 (mínimo de operación 20 mbar)"}	{"id": {"antes": "6c790e33-e72e-41e8-8b39-f674aee35b27", "despues": "a7d1acee-a648-4a11-97e3-449d55bfd2a5"}, "alcance": {"antes": "Lazo de control de presión.", "despues": "Se amplía al tren de válvulas y a la acometida de gas."}, "version": {"antes": 1, "despues": 2}, "created_at": {"antes": "2026-09-20T15:34:15.894171-05:00", "despues": "2026-09-20T15:34:15.912279-05:00"}, "updated_at": {"antes": "2026-09-20T15:34:15.894171-05:00", "despues": "2026-09-20T15:34:15.912279-05:00"}, "diagnostico": {"antes": "Presostato de seguridad corta por presión baja durante la noche.", "despues": "El corte lo provoca la válvula de gas, que cierra por caída de presión en la red, no el presostato."}, "reemplaza_a": {"antes": null, "despues": "6c790e33-e72e-41e8-8b39-f674aee35b27"}, "motivo_cambio": {"antes": null, "despues": "El registro nocturno descartó el presostato: la presión de red cae antes del corte."}, "causa_probable": {"antes": "Ajuste del presostato demasiado cerca del mínimo de operación.", "despues": "Caída de presión de red en horario nocturno, cuando la planta vecina consume."}, "trabajo_a_realizar": {"antes": "Reajustar el presostato y monitorear una semana.", "despues": "Instalar registrador de presión en la acometida y evaluar regulador de mayor capacidad."}, "lecturas_instrumentos": {"antes": null, "despues": "Presión de red 18 mbar a las 02:40 (mínimo de operación 20 mbar)"}}	El registro nocturno descartó el presostato: la presión de red cae antes del corte.	\N	\N	\N	2026-09-20 15:34:15.912279-05
66	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	998d96e3-cb46-45ff-abf5-2f8885f40930	\N	{"id": "998d96e3-cb46-45ff-abf5-2f8885f40930", "lugar": "Subestación", "estado": "enviada", "numero": "ST-000008", "titulo": "Tablero principal con olor a quemado", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.92883-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.92883-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Huele a quemado en el tablero general y saltó el diferencial dos veces.", "fecha_envio": "2026-09-20T15:34:15.92883-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "critica", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:15.92883-05
68	5c921062-21ab-4a01-8f9a-2e2500e95893	a7ee34e2-43bd-496d-99b0-ad8013072cea	crear	diagnostico	b00067d2-e86e-4a23-adcf-13f448a9c1c0	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "b00067d2-e86e-4a23-adcf-13f448a9c1c0", "ot_id": "bf832c74-c7c4-4cdd-a316-2a92dbbfc301", "alcance": "Barra principal y bornes de salida.", "version": 1, "vigente": true, "autor_id": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.953977-05:00", "created_by": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "updated_at": "2026-09-20T15:34:15.953977-05:00", "updated_by": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "aprobado_at": null, "diagnostico": "Borne de la barra principal flojo con marcas de arco eléctrico.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Ajuste perdido por ciclos térmicos.", "trabajo_a_realizar": "Reajustar con torquímetro, reemplazar el borne dañado y termografiar.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "b00067d2-e86e-4a23-adcf-13f448a9c1c0"}, "ot_id": {"antes": null, "despues": "bf832c74-c7c4-4cdd-a316-2a92dbbfc301"}, "alcance": {"antes": null, "despues": "Barra principal y bornes de salida."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:15.953977-05:00"}, "created_by": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:15.953977-05:00"}, "updated_by": {"antes": null, "despues": "a7ee34e2-43bd-496d-99b0-ad8013072cea"}, "diagnostico": {"antes": null, "despues": "Borne de la barra principal flojo con marcas de arco eléctrico."}, "causa_probable": {"antes": null, "despues": "Ajuste perdido por ciclos térmicos."}, "trabajo_a_realizar": {"antes": null, "despues": "Reajustar con torquímetro, reemplazar el borne dañado y termografiar."}}	\N	\N	\N	\N	2026-09-20 15:34:15.953977-05
70	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	crear	solicitud_trabajo	3c527e52-05d9-4490-b025-2785a2e0a7b2	\N	{"id": "3c527e52-05d9-4490-b025-2785a2e0a7b2", "lugar": "Patio de maniobras", "estado": "enviada", "numero": "ST-000009", "titulo": "Montacargas 4 sin fuerza y con falla eléctrica", "area_id": "a8d349a2-f03d-44c0-a268-42264076d560", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.003112-05:00", "created_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.003112-05:00", "updated_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "descripcion": "Levanta a media carga y en el tablero se prende una luz que no conocemos.", "fecha_envio": "2026-09-20T15:34:16.003112-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "alta", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.003112-05
69	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	iniciar	ejecucion	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	\N	\N	\N	\N	\N	\N	\N	2026-09-03 14:34:15.970837-05
72	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	crear	diagnostico	18354423-f450-4025-9dd2-d33d2f45b580	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "18354423-f450-4025-9dd2-d33d2f45b580", "ot_id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "alcance": "Sistema hidráulico de elevación; el eléctrico se separa.", "version": 1, "vigente": true, "autor_id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.033936-05:00", "created_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "updated_at": "2026-09-20T15:34:16.033936-05:00", "updated_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "aprobado_at": null, "diagnostico": "Dos problemas independientes: caída de presión en el circuito de elevación y falla en el módulo de control.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Bomba desgastada por un lado; módulo con avería de fábrica por otro.", "trabajo_a_realizar": "Reparar el circuito hidráulico y derivar la parte eléctrica a un especialista.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "18354423-f450-4025-9dd2-d33d2f45b580"}, "ot_id": {"antes": null, "despues": "c7dd4771-3654-4aff-89a5-f7661193fb03"}, "alcance": {"antes": null, "despues": "Sistema hidráulico de elevación; el eléctrico se separa."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:16.033936-05:00"}, "created_by": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:16.033936-05:00"}, "updated_by": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "diagnostico": {"antes": null, "despues": "Dos problemas independientes: caída de presión en el circuito de elevación y falla en el módulo de control."}, "causa_probable": {"antes": null, "despues": "Bomba desgastada por un lado; módulo con avería de fábrica por otro."}, "trabajo_a_realizar": {"antes": null, "despues": "Reparar el circuito hidráulico y derivar la parte eléctrica a un especialista."}}	\N	\N	\N	\N	2026-09-20 15:34:16.033936-05
75	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	crear	diagnostico	791fa998-20f5-400d-878e-5ee9b4313624	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "791fa998-20f5-400d-878e-5ee9b4313624", "ot_id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "alcance": "Bomba de elevación.", "version": 1, "vigente": true, "autor_id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.122692-05:00", "created_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "updated_at": "2026-09-20T15:34:16.122692-05:00", "updated_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "aprobado_at": null, "diagnostico": "Bomba de engranajes con holgura fuera de tolerancia.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Desgaste normal por horas de servicio.", "trabajo_a_realizar": "Rectificar la bomba y reemplazar sellos.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "791fa998-20f5-400d-878e-5ee9b4313624"}, "ot_id": {"antes": null, "despues": "a9859198-0a21-4309-8a00-2ca9a2cdc917"}, "alcance": {"antes": null, "despues": "Bomba de elevación."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:16.122692-05:00"}, "created_by": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:16.122692-05:00"}, "updated_by": {"antes": null, "despues": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df"}, "diagnostico": {"antes": null, "despues": "Bomba de engranajes con holgura fuera de tolerancia."}, "causa_probable": {"antes": null, "despues": "Desgaste normal por horas de servicio."}, "trabajo_a_realizar": {"antes": null, "despues": "Rectificar la bomba y reemplazar sellos."}}	\N	\N	\N	\N	2026-09-20 15:34:16.122692-05
93	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	30e96f19-2a6f-4224-a207-1e96e32a5bbb	\N	{"id": "30e96f19-2a6f-4224-a207-1e96e32a5bbb", "lugar": "Zona de soldadura", "estado": "enviada", "numero": "ST-000012", "titulo": "Vibración en el extractor de la zona de soldadura", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.453022-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.453022-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "El extractor vibra y hace más ruido que de costumbre desde el lunes.", "fecha_envio": "2026-09-20T15:34:16.453022-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "media", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.453022-05
76	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cargar	cotizacion	64dc018a-0a2e-45e7-913d-e1dcdf82baf9	{"id": null, "monto": null, "ot_id": null, "moneda": null, "version": null, "vigente": null, "tenant_id": null, "created_at": null, "created_by": null, "invalidada": null, "updated_at": null, "updated_by": null, "cargada_por": null, "reemplaza_a": null, "proveedor_id": null, "validez_dias": null, "observaciones": null, "proveedor_ruc": null, "fecha_cotizacion": null, "motivo_reemplazo": null, "proveedor_nombre": null, "numero_cotizacion": null, "plazo_ofrecido_dias": null}	{"id": "64dc018a-0a2e-45e7-913d-e1dcdf82baf9", "monto": 1960.00, "ot_id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "moneda": "PEN", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.140996-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "invalidada": false, "updated_at": "2026-09-20T15:34:16.140996-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "cargada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "reemplaza_a": null, "proveedor_id": "e33609de-3734-4b1b-badf-f08ce365c2a2", "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20456789014", "fecha_cotizacion": "2026-09-14", "motivo_reemplazo": null, "proveedor_nombre": "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", "numero_cotizacion": "COT-2026-0436", "plazo_ofrecido_dias": 8}	{"id": {"antes": null, "despues": "64dc018a-0a2e-45e7-913d-e1dcdf82baf9"}, "monto": {"antes": null, "despues": 1960.00}, "ot_id": {"antes": null, "despues": "a9859198-0a21-4309-8a00-2ca9a2cdc917"}, "moneda": {"antes": null, "despues": "PEN"}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:16.140996-05:00"}, "created_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "invalidada": {"antes": null, "despues": false}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:16.140996-05:00"}, "updated_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "cargada_por": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "proveedor_id": {"antes": null, "despues": "e33609de-3734-4b1b-badf-f08ce365c2a2"}, "validez_dias": {"antes": null, "despues": 30}, "proveedor_ruc": {"antes": null, "despues": "20456789014"}, "fecha_cotizacion": {"antes": null, "despues": "2026-09-14"}, "proveedor_nombre": {"antes": null, "despues": "HIDRÁULICA INDUSTRIAL LIMA S.A.C."}, "numero_cotizacion": {"antes": null, "despues": "COT-2026-0436"}, "plazo_ofrecido_dias": {"antes": null, "despues": 8}}	\N	\N	\N	\N	2026-09-20 15:34:16.140996-05
78	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	declarar	trabajo_realizado	204401ea-b3e8-4e6e-a8b1-6d503b51fe4e	\N	{"id": "204401ea-b3e8-4e6e-a8b1-6d503b51fe4e", "ot_id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.17693-05:00", "created_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "updated_at": "2026-09-20T15:34:16.17693-05:00", "updated_by": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "conformidad": "sin_pronunciarse", "descripcion": "Bomba rectificada y sellos nuevos. Presión de elevación restituida a 180 bar.", "revisado_at": null, "resultado_id": null, "revisado_por": null, "declarado_por": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "fecha_termino": "2026-09-20T15:34:16.17693-05:00", "observaciones": null, "conformidad_at": null, "resultado_texto": null, "resultado_revision": null, "revision_observacion": null, "conformidad_comentario": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.17693-05
79	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	revisar	trabajo_realizado	204401ea-b3e8-4e6e-a8b1-6d503b51fe4e	\N	{"resultado": "aprobado"}	\N		\N	\N	\N	2026-09-20 15:34:16.194661-05
81	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	48ebc1d1-f4de-4401-9cca-06e3d91e3621	\N	{"id": "48ebc1d1-f4de-4401-9cca-06e3d91e3621", "lugar": "Pasillo 3", "estado": "enviada", "numero": "ST-000010", "titulo": "Cambiar luminarias del pasillo 3", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.251273-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.251273-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Las luminarias parpadean y algunas ya no encienden.", "fecha_envio": "2026-09-20T15:34:16.251273-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "baja", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.251273-05
84	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	9d56b79e-e16a-497a-a936-985e184807c1	\N	{"id": "9d56b79e-e16a-497a-a936-985e184807c1", "lugar": "Cuarto de bombas", "estado": "enviada", "numero": "ST-000011", "titulo": "Bomba de agua del sistema contra incendios pierde presión", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.293498-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.293498-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "El manómetro del sistema baja durante la noche.", "fecha_envio": "2026-09-20T15:34:16.293498-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "alta", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.293498-05
77	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	iniciar	ejecucion	a9859198-0a21-4309-8a00-2ca9a2cdc917	\N	\N	\N	\N	\N	\N	\N	2026-08-06 15:34:16.158376-05
86	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	crear	diagnostico	d0368a13-9b72-498c-8baa-8b92ca667a0e	{"id": null, "ot_id": null, "alcance": null, "version": null, "vigente": null, "autor_id": null, "tenant_id": null, "created_at": null, "created_by": null, "updated_at": null, "updated_by": null, "aprobado_at": null, "diagnostico": null, "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": null, "trabajo_a_realizar": null, "lecturas_instrumentos": null}	{"id": "d0368a13-9b72-498c-8baa-8b92ca667a0e", "ot_id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "alcance": "Válvula de retención de la bomba principal.", "version": 1, "vigente": true, "autor_id": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.320121-05:00", "created_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "updated_at": "2026-09-20T15:34:16.320121-05:00", "updated_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "aprobado_at": null, "diagnostico": "Válvula de retención con asiento marcado; permite retorno.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Sedimento acumulado en el asiento.", "trabajo_a_realizar": "Desmontar, limpiar el asiento y reemplazar el resorte.", "lecturas_instrumentos": null}	{"id": {"antes": null, "despues": "d0368a13-9b72-498c-8baa-8b92ca667a0e"}, "ot_id": {"antes": null, "despues": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3"}, "alcance": {"antes": null, "despues": "Válvula de retención de la bomba principal."}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "autor_id": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:16.320121-05:00"}, "created_by": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:16.320121-05:00"}, "updated_by": {"antes": null, "despues": "5a11b0c5-7640-494f-9c8b-64a9a4e30673"}, "diagnostico": {"antes": null, "despues": "Válvula de retención con asiento marcado; permite retorno."}, "causa_probable": {"antes": null, "despues": "Sedimento acumulado en el asiento."}, "trabajo_a_realizar": {"antes": null, "despues": "Desmontar, limpiar el asiento y reemplazar el resorte."}}	\N	\N	\N	\N	2026-09-20 15:34:16.320121-05
87	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cargar	cotizacion	c04db5da-741c-4f8c-af00-8f461a5a55f3	{"id": null, "monto": null, "ot_id": null, "moneda": null, "version": null, "vigente": null, "tenant_id": null, "created_at": null, "created_by": null, "invalidada": null, "updated_at": null, "updated_by": null, "cargada_por": null, "reemplaza_a": null, "proveedor_id": null, "validez_dias": null, "observaciones": null, "proveedor_ruc": null, "fecha_cotizacion": null, "motivo_reemplazo": null, "proveedor_nombre": null, "numero_cotizacion": null, "plazo_ofrecido_dias": null}	{"id": "c04db5da-741c-4f8c-af00-8f461a5a55f3", "monto": 980.00, "ot_id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "moneda": "PEN", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.336221-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "invalidada": false, "updated_at": "2026-09-20T15:34:16.336221-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "cargada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "reemplaza_a": null, "proveedor_id": "6347f0eb-53cf-41d2-8df5-32cf26fb5a74", "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20601234565", "fecha_cotizacion": "2026-09-14", "motivo_reemplazo": null, "proveedor_nombre": "SISTEMAS CONTRA INCENDIO S.A.C.", "numero_cotizacion": "COT-2026-0440", "plazo_ofrecido_dias": 3}	{"id": {"antes": null, "despues": "c04db5da-741c-4f8c-af00-8f461a5a55f3"}, "monto": {"antes": null, "despues": 980.00}, "ot_id": {"antes": null, "despues": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3"}, "moneda": {"antes": null, "despues": "PEN"}, "version": {"antes": null, "despues": 1}, "vigente": {"antes": null, "despues": true}, "tenant_id": {"antes": null, "despues": "5c921062-21ab-4a01-8f9a-2e2500e95893"}, "created_at": {"antes": null, "despues": "2026-09-20T15:34:16.336221-05:00"}, "created_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "invalidada": {"antes": null, "despues": false}, "updated_at": {"antes": null, "despues": "2026-09-20T15:34:16.336221-05:00"}, "updated_by": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "cargada_por": {"antes": null, "despues": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b"}, "proveedor_id": {"antes": null, "despues": "6347f0eb-53cf-41d2-8df5-32cf26fb5a74"}, "validez_dias": {"antes": null, "despues": 30}, "proveedor_ruc": {"antes": null, "despues": "20601234565"}, "fecha_cotizacion": {"antes": null, "despues": "2026-09-14"}, "proveedor_nombre": {"antes": null, "despues": "SISTEMAS CONTRA INCENDIO S.A.C."}, "numero_cotizacion": {"antes": null, "despues": "COT-2026-0440"}, "plazo_ofrecido_dias": {"antes": null, "despues": 3}}	\N	\N	\N	\N	2026-09-20 15:34:16.336221-05
89	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	declarar	trabajo_realizado	b847fac3-a71a-4834-87b7-ffc96912e573	\N	{"id": "b847fac3-a71a-4834-87b7-ffc96912e573", "ot_id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "version": 1, "vigente": true, "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.372475-05:00", "created_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "updated_at": "2026-09-20T15:34:16.372475-05:00", "updated_by": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "conformidad": "sin_pronunciarse", "descripcion": "Válvula limpia y resorte nuevo. Presión estable en la prueba de dos horas.", "revisado_at": null, "resultado_id": null, "revisado_por": null, "declarado_por": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "fecha_termino": "2026-09-20T15:34:16.372475-05:00", "observaciones": null, "conformidad_at": null, "resultado_texto": null, "resultado_revision": null, "revision_observacion": null, "conformidad_comentario": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.372475-05
90	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	revisar	trabajo_realizado	b847fac3-a71a-4834-87b7-ffc96912e573	\N	{"resultado": "aprobado"}	\N		\N	\N	\N	2026-09-20 15:34:16.391197-05
92	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	reabrir	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	{"estado": "cerrada"}	{"estado": "en_trabajo"}	{"estado": {"antes": "cerrada", "despues": "en_trabajo"}}	La presión volvió a caer a los cuatro días; la fuga no era sólo la retención.	\N	\N	\N	2026-08-29 12:34:16.42939-05
94	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	crear	solicitud_trabajo	5c591e07-051b-4dfa-9890-a6f964c9bcc4	\N	{"id": "5c591e07-051b-4dfa-9890-a6f964c9bcc4", "lugar": "Almacén central", "estado": "enviada", "numero": "ST-000013", "titulo": "Gotera sobre el estante de repuestos", "area_id": "a8d349a2-f03d-44c0-a268-42264076d560", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.458687-05:00", "created_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.458687-05:00", "updated_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "descripcion": "Cuando llueve cae agua justo encima del estante A del almacén.", "fecha_envio": "2026-09-20T15:34:16.458687-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "alta", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.458687-05
95	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	crear	solicitud_trabajo	ded455bf-93a0-4484-b8b2-c9f4785f173c	\N	{"id": "ded455bf-93a0-4484-b8b2-c9f4785f173c", "lugar": "Recepción de materiales", "estado": "enviada", "numero": "ST-000014", "titulo": "Balanza de recepción descuadra 3 kg", "area_id": "a8d349a2-f03d-44c0-a268-42264076d560", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.466756-05:00", "created_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.466756-05:00", "updated_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "descripcion": "Pesa de más comparada con la balanza patrón; ya nos rechazaron un despacho.", "fecha_envio": "2026-09-20T15:34:16.466756-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "alta", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.466756-05
96	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	5accb670-c0d4-4e81-a5da-d4d9634614eb	\N	{"id": "5accb670-c0d4-4e81-a5da-d4d9634614eb", "lugar": "Sala de control", "estado": "enviada", "numero": "ST-000015", "titulo": "Aire acondicionado de la sala de control no enfría", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.475637-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.475637-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "La sala está a 31 °C y los tableros se calientan.", "fecha_envio": "2026-09-20T15:34:16.475637-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "critica", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.475637-05
97	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	35a97525-51a5-4a29-bdec-97d0e29e563c	\N	{"id": "35a97525-51a5-4a29-bdec-97d0e29e563c", "lugar": "Línea de empaque", "estado": "enviada", "numero": "ST-000016", "titulo": "Faja transportadora se desalinea sola", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.482433-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.482433-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Se corre hacia la derecha y hay que centrarla dos veces por turno.", "fecha_envio": "2026-09-20T15:34:16.482433-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": "media", "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.482433-05
98	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	c4432d97-1ac8-49c5-9bb8-c072cd287501	\N	{"id": "c4432d97-1ac8-49c5-9bb8-c072cd287501", "lugar": "Taller 1", "estado": "enviada", "numero": "ST-000017", "titulo": "Algo suena raro en el taller", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.490087-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.490087-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Se escucha un ruido, no sé de dónde viene.", "fecha_envio": "2026-09-20T15:34:16.490087-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": null, "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.490087-05
99	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	observar	solicitud_trabajo	c4432d97-1ac8-49c5-9bb8-c072cd287501	{"estado": "en_revision"}	{"estado": "observada"}	{"estado": {"antes": "en_revision", "despues": "observada"}}	Indique en qué máquina se oye y en qué momento del turno, para poder asignar al técnico correcto.	\N	\N	\N	2026-09-20 15:34:16.502291-05
100	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	crear	solicitud_trabajo	8cdd7cb1-4234-473c-b22d-43133e531194	\N	{"id": "8cdd7cb1-4234-473c-b22d-43133e531194", "lugar": "Oficina administrativa", "estado": "enviada", "numero": "ST-000018", "titulo": "Compra de una cafetera para la oficina", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.507979-05:00", "created_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.507979-05:00", "updated_by": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "descripcion": "La cafetera de la oficina administrativa dejó de funcionar.", "fecha_envio": "2026-09-20T15:34:16.507979-05:00", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": null, "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.507979-05
101	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	rechazar	solicitud_trabajo	8cdd7cb1-4234-473c-b22d-43133e531194	{"estado": "en_revision"}	{"estado": "rechazada"}	{"estado": {"antes": "en_revision", "despues": "rechazada"}}	No corresponde a mantenimiento industrial; canalícelo con Administración como compra de bien de oficina.	\N	\N	\N	2026-09-20 15:34:16.51712-05
102	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	crear	solicitud_trabajo	cc74a708-0627-41be-85c8-57a4ad86cee2	\N	{"id": "cc74a708-0627-41be-85c8-57a4ad86cee2", "lugar": "Casa de fuerza", "estado": "borrador", "numero": "ST-000019", "titulo": "Revisión preventiva del grupo electrógeno", "area_id": "36883387-4f15-411a-83f2-c8dfea7f88ca", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.522589-05:00", "created_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.522589-05:00", "updated_by": "f71701ef-202b-4563-9c16-10f1d41b8135", "descripcion": "Borrador: falta confirmar la fecha con el proveedor del servicio.", "fecha_envio": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "solicitante_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "motivo_rechazo_id": null, "impacto_comentario": null, "observacion_actual": null, "prioridad_percibida": null, "impacto_operativo_id": "84f0c1c1-6d59-479a-9d85-3542bfc7f683", "coordinador_revisor_id": null, "fecha_primera_revision": null, "solicitud_principal_id": null}	\N	\N	\N	\N	\N	2026-09-20 15:34:16.522589-05
63	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	f1c60e96-9925-4aa2-a68b-00a72489fd2f	\N	{"id": "f1c60e96-9925-4aa2-a68b-00a72489fd2f", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000007", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.879017-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.879017-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "8b99e5c2-f44f-4d1e-84e5-f658747ba01c", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:15.879017-05:00", "tipo_trabajo_id": "3edd6fb2-8268-4204-a998-eb72ae53e077", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "alta", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "e54dbab5-2c51-433d-9c19-0400620d5f99", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-09-12 10:34:15.879017-05
67	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	\N	{"id": "bf832c74-c7c4-4cdd-a316-2a92dbbfc301", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000008", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.93803-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.93803-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": true, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:15.93803-05:00", "tipo_trabajo_id": "efc65d1b-8ad8-4eb2-8e49-783b09a0cff0", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "critica", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "998d96e3-cb46-45ff-abf5-2f8885f40930", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": "2026-09-20T15:34:15.93803-05:00", "motivo_derivacion_texto": null, "emergencia_declarada_por": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "emergencia_justificacion": "Riesgo eléctrico inmediato con la planta energizada; no hay tablero de respaldo.", "es_bloqueante_para_padre": true, "regularizacion_pendiente": true}	\N	\N	\N	\N	\N	2026-09-03 14:34:15.93803-05
73	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear_derivada	orden_trabajo	ee9a06f5-0220-47a0-8e4a-d992333af106	\N	{"id": "ee9a06f5-0220-47a0-8e4a-d992333af106", "nivel": 1, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000010", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.051891-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.051891-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:16.051891-05:00", "tipo_trabajo_id": "bf147cd2-23c8-4e07-819e-a6cde044e15e", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "alta", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": null, "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": "El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación.", "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación.	\N	\N	\N	2026-09-17 11:34:16.051891-05
83	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cancelar	orden_trabajo	cd790d32-39ab-4aba-b33d-2dc34a03831a	{"estado": "creada"}	{"estado": "cancelada"}	{"estado": {"antes": "creada", "despues": "cancelada"}}	El pasillo entra en el proyecto de recambio a LED de toda la planta; se atiende allí.	\N	\N	\N	2026-08-05 08:34:16.277853-05
103	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	login	usuario	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:16.98316-05
104	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	login	usuario	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:17.214449-05
105	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	login	usuario	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:17.867828-05
106	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	login	usuario	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:18.097614-05
107	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	login	usuario	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:26.222198-05
108	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	login	usuario	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:27.514285-05
82	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	cd790d32-39ab-4aba-b33d-2dc34a03831a	\N	{"id": "cd790d32-39ab-4aba-b33d-2dc34a03831a", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000012", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.261469-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.261469-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:16.261469-05:00", "tipo_trabajo_id": null, "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "baja", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "48ebc1d1-f4de-4401-9cca-06e3d91e3621", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "5e8cdfa9-2263-4d6c-99e7-e8a2af905922", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-08-05 08:34:16.261469-05
31	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	registrar	liberacion	be7b33db-85f9-4955-953c-f4e24d864dcc	{"monto": null, "estado": null}	{"monto": 4850, "estado": "total"}	{"monto": {"antes": null, "despues": 4850}, "estado": {"antes": null, "despues": "total"}}	\N	\N	\N	\N	2026-08-16 08:34:15.249641-05
22	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	\N	{"id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000001", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:14.977113-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:14.977113-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:14.977113-05:00", "tipo_trabajo_id": "743ce9a9-33cc-4c22-b6de-b0bd15bdfa61", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "alta", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "c5d4a2a9-9988-4d7a-ad76-555e3020bafe", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-08-16 08:34:14.977113-05
34	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	\N	{"id": "14cd082a-4bcd-4661-8837-c47c4f762342", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000002", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.302141-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.302141-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "8b99e5c2-f44f-4d1e-84e5-f658747ba01c", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:15.302141-05:00", "tipo_trabajo_id": "70d72bcc-44dd-4383-add9-d2e21e9c0477", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "alta", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "99d4f059-ece9-4360-9490-c612a98ede66", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-08-15 12:34:15.302141-05
43	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	569b23e3-2a8b-4dd7-9f5a-262524af1c93	\N	{"id": "569b23e3-2a8b-4dd7-9f5a-262524af1c93", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000003", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.470721-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.470721-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:15.470721-05:00", "tipo_trabajo_id": "bf147cd2-23c8-4e07-819e-a6cde044e15e", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "alta", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "5787000f-3be4-46c8-849b-51b922142d11", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-09-08 05:34:15.470721-05
59	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	2b0e0c54-42f5-45ce-9ff5-10b069071a30	\N	{"id": "2b0e0c54-42f5-45ce-9ff5-10b069071a30", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000006", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.821136-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.821136-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:15.821136-05:00", "tipo_trabajo_id": "a92169d4-06ea-4d10-b36b-d8092b14f709", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "media", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "6b1ecb72-330f-4e70-8e65-14b41fd94f77", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-09-13 06:34:15.821136-05
71	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	c7dd4771-3654-4aff-89a5-f7661193fb03	\N	{"id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000009", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.012792-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.012792-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:16.012792-05:00", "tipo_trabajo_id": "bf147cd2-23c8-4e07-819e-a6cde044e15e", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "alta", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "3c527e52-05d9-4490-b025-2785a2e0a7b2", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-09-18 07:34:16.012792-05
80	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cerrar	orden_trabajo	a9859198-0a21-4309-8a00-2ca9a2cdc917	{"estado": "trabajo_realizado"}	{"estado": "cerrada", "estado_administrativo": "sin_solped"}	{"estado": {"antes": "trabajo_realizado", "despues": "cerrada"}, "estado_administrativo": {"antes": null, "despues": "sin_solped"}}	Sin SOLPED: el gasto se imputó al contrato marco del taller externo.	\N	\N	\N	2026-08-06 15:34:16.210247-05
74	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear_derivada	orden_trabajo	a9859198-0a21-4309-8a00-2ca9a2cdc917	\N	{"id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "nivel": 1, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000011", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.085222-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.085222-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:16.085222-05:00", "tipo_trabajo_id": "bf147cd2-23c8-4e07-819e-a6cde044e15e", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "alta", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": null, "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": "El rectificado de la bomba va a un taller externo especializado.", "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	El rectificado de la bomba va a un taller externo especializado.	\N	\N	\N	2026-08-06 15:34:16.085222-05
91	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	cerrar	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	{"estado": "trabajo_realizado"}	{"estado": "cerrada", "estado_administrativo": "sin_solped"}	{"estado": {"antes": "trabajo_realizado", "despues": "cerrada"}, "estado_administrativo": {"antes": null, "despues": "sin_solped"}}	Gasto menor imputado a caja chica; sin SOLPED.	\N	\N	\N	2026-08-29 12:34:16.407424-05
88	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	iniciar	ejecucion	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	\N	\N	\N	\N	\N	\N	\N	2026-08-29 12:34:16.35434-05
85	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	\N	{"id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000013", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:16.304342-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:16.304342-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:16.304342-05:00", "tipo_trabajo_id": "bf147cd2-23c8-4e07-819e-a6cde044e15e", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "alta", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "9d56b79e-e16a-497a-a936-985e184807c1", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-08-29 12:34:16.304342-05
53	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	bd61bf6d-abeb-487f-91eb-3281f93643f0	\N	{"id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000005", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.727191-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.727191-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:15.727191-05:00", "tipo_trabajo_id": "191c571d-7b81-452c-8c99-92905ba5ca57", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "baja", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "15e5d80b-173b-451f-a58f-f49dd40813e9", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-09-06 13:34:15.727191-05
51	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	iniciar	ejecucion	1400addf-2f07-4784-a1f6-62c95da13ef1	\N	\N	\N	\N	\N	\N	\N	2026-09-07 09:34:15.663697-05
48	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	crear	orden_trabajo	1400addf-2f07-4784-a1f6-62c95da13ef1	\N	{"id": "1400addf-2f07-4784-a1f6-62c95da13ef1", "nivel": 0, "estado": "creada", "area_id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "cecos_id": null, "condicion": "activa", "numero_ot": "OT-000004", "tenant_id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "created_at": "2026-09-20T15:34:15.610587-05:00", "created_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "deleted_at": null, "updated_at": "2026-09-20T15:34:15.610587-05:00", "updated_by": "3e46b47b-7ca6-466b-8a2e-b01a8473df5b", "ejecutor_id": null, "ot_padre_id": null, "sucursal_id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "fecha_cierre": null, "es_emergencia": false, "coordinador_id": "8b99e5c2-f44f-4d1e-84e5-f658747ba01c", "empresa_ruc_id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "fecha_creacion": "2026-09-20T15:34:15.610587-05:00", "tipo_trabajo_id": "1eed878f-1909-4f26-81c5-e8a85a527e9f", "trazabilidad_at": null, "veces_reabierta": 0, "fecha_cancelacion": null, "fecha_inicio_real": null, "prioridad_tecnica": "media", "fecha_termino_real": null, "trazabilidad_dirty": true, "solicitud_origen_id": "0c01b409-e417-4a5b-baad-acba87bbf851", "motivo_derivacion_id": null, "trazabilidad_version": 0, "estado_administrativo": "sin_solped", "motivo_cancelacion_id": null, "tipo_mantenimiento_id": "e09565c0-2ff9-469c-9a84-c121c59bc9c7", "independizada_de_padre": false, "cancelacion_observacion": null, "emergencia_declarada_at": null, "motivo_derivacion_texto": null, "emergencia_declarada_por": null, "emergencia_justificacion": null, "es_bloqueante_para_padre": true, "regularizacion_pendiente": false}	\N	\N	\N	\N	\N	2026-09-07 09:34:15.610587-05
109	5c921062-21ab-4a01-8f9a-2e2500e95893	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	login	usuario	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:35:10.321144-05
110	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	login	usuario	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:36:29.124496-05
111	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	login	usuario	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	\N	\N	\N	\N	\N	\N	2026-09-20 15:36:30.309807-05
\.


--
-- Data for Name: adjunto; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.adjunto (id, tenant_id, ot_id, entidad_tipo, entidad_id, etapa, tipo, nombre, nombre_original, mime_type, tamano_bytes, storage_key, checksum, estado, visibilidad, autor_id, retirado_at, retirado_por, created_at, updated_at) FROM stdin;
671a9f4d-225c-43bd-ba23-ea935891e30a	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	cotizacion	8145f65b-f63d-4121-96eb-3a1e7775f9af	cotizacion	pdf	COT-2026-0421.pdf	COT-2026-0421.pdf	application/pdf	1213	5c921062-21ab-4a01-8f9a-2e2500e95893/569b23e3-2a8b-4dd7-9f5a-262524af1c93/20e1b223-82d9-4ba7-b829-3f31f40fd4d8-COT-2026-0421.pdf	ad3da7c27e96bf316bf16115b543f07b4ed4878eaaf4d60ec17ed022deffa82d	vigente	canal	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	2026-09-20 15:34:17.539707-05	2026-09-20 15:34:17.539707-05
9c8881a2-1832-4cbe-a3c2-6557f1c470f6	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	cotizacion	c04db5da-741c-4f8c-af00-8f461a5a55f3	cotizacion	pdf	COT-2026-0440.pdf	COT-2026-0440.pdf	application/pdf	1208	5c921062-21ab-4a01-8f9a-2e2500e95893/32eaf0e5-c562-4bfd-b4f7-eb3716f077b3/f1cfaef9-8fac-458c-bcfb-df2cfe1589a9-COT-2026-0440.pdf	88fc8686bd2a6fad0b4cd808b3f08e33936d2d112d2bd7beaac9ef5e1e9f8395	vigente	canal	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	2026-09-20 15:34:17.581748-05	2026-09-20 15:34:17.581748-05
14994e97-afac-479a-a613-bd8476af4c1b	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	cotizacion	8ae2a1b6-3d59-429f-abbf-8ea949d00930	cotizacion	pdf	COT-2026-0412.pdf	COT-2026-0412.pdf	application/pdf	1217	5c921062-21ab-4a01-8f9a-2e2500e95893/be7b33db-85f9-4955-953c-f4e24d864dcc/db7e1f5e-c92c-40d9-b917-4a07401778c4-COT-2026-0412.pdf	3408b1188fc4032ff44202fe3745e6f4a6fe8ff8dded8388cbf11aa9521c5bc4	vigente	canal	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	2026-09-20 15:34:17.622807-05	2026-09-20 15:34:17.622807-05
7f245e2f-dc09-4d57-b225-d8e8eb4d3bf8	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	cotizacion	941e9e9a-0613-4288-a4f9-17a68d17668f	cotizacion	pdf	COT-2026-0418.pdf	COT-2026-0418.pdf	application/pdf	1209	5c921062-21ab-4a01-8f9a-2e2500e95893/14cd082a-4bcd-4661-8837-c47c4f762342/bb32a148-0d10-4d47-9bf3-0e686c20d9dd-COT-2026-0418.pdf	eb6b976e34f77dac44f7dff7ab0dd23e6d66d1482c53bd81388bfc44f559fcb4	vigente	canal	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	2026-09-20 15:34:17.673677-05	2026-09-20 15:34:17.673677-05
3a80cc87-ddaf-4abc-ba2c-62acd0543a92	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	cotizacion	64dc018a-0a2e-45e7-913d-e1dcdf82baf9	cotizacion	pdf	COT-2026-0436.pdf	COT-2026-0436.pdf	application/pdf	1212	5c921062-21ab-4a01-8f9a-2e2500e95893/a9859198-0a21-4309-8a00-2ca9a2cdc917/88daf843-341a-42b3-b1ae-aa2e880a2c08-COT-2026-0436.pdf	8019c480887ebad9b812da44af84e3c1b764434282fa1206475798983a2b69c4	vigente	canal	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	2026-09-20 15:34:17.711979-05	2026-09-20 15:34:17.711979-05
80197891-bc09-4c2f-a953-eebf73502c96	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	cotizacion	f9af5c86-a168-40ec-a440-0c0fc849c120	cotizacion	pdf	COT-2026-0433.pdf	COT-2026-0433.pdf	application/pdf	1210	5c921062-21ab-4a01-8f9a-2e2500e95893/2b0e0c54-42f5-45ce-9ff5-10b069071a30/0ed393cc-2507-4d15-a9b3-26beee0193ce-COT-2026-0433.pdf	621f169e3b7bcf7d3374cb99e4440015754364370e14941063cd2a55af607f6f	vigente	canal	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	2026-09-20 15:34:17.750313-05	2026-09-20 15:34:17.750313-05
bab9369a-cc2b-4113-87fb-7a67ad895b01	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	cotizacion	20dd8496-ea84-44bb-8740-a36c597b1147	cotizacion	pdf	COT-2026-0425.pdf	COT-2026-0425.pdf	application/pdf	1210	5c921062-21ab-4a01-8f9a-2e2500e95893/1400addf-2f07-4784-a1f6-62c95da13ef1/aec33792-dae0-4a22-8434-fa43925056fc-COT-2026-0425.pdf	11ea7654686c55a8185acecf852ef55a188eebd936a7f2b7d383504463f581d4	vigente	canal	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	2026-09-20 15:34:17.788369-05	2026-09-20 15:34:17.788369-05
3ba51897-8849-4a94-8e53-edc5566773d7	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	cotizacion	fee02c0d-bc83-47cd-b082-7f25428e0fd3	cotizacion	pdf	COT-2026-0430.pdf	COT-2026-0430.pdf	application/pdf	1218	5c921062-21ab-4a01-8f9a-2e2500e95893/bd61bf6d-abeb-487f-91eb-3281f93643f0/0622e6ae-bbc0-40f7-b236-17e010cb85a0-COT-2026-0430.pdf	9adec737ec243b773f43706ed1a080b0e8d0992a971e0b3f993f7120b2d724ce	vigente	canal	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	2026-09-20 15:34:17.827492-05	2026-09-20 15:34:17.827492-05
\.


--
-- Data for Name: area; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.area (id, tenant_id, empresa_ruc_id, codigo, nombre, estado, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
36883387-4f15-411a-83f2-c8dfea7f88ca	5c921062-21ab-4a01-8f9a-2e2500e95893	1d2f2959-955c-41b0-96f0-cca1a3c631ba	MANTTO	Mantenimiento	activo	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N	\N	\N
151f5ad1-9d5e-4f59-a283-15f6ec05f515	5c921062-21ab-4a01-8f9a-2e2500e95893	1d2f2959-955c-41b0-96f0-cca1a3c631ba	PROD	Producción	activo	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N	\N	\N
a8d349a2-f03d-44c0-a268-42264076d560	5c921062-21ab-4a01-8f9a-2e2500e95893	1d2f2959-955c-41b0-96f0-cca1a3c631ba	ALMAC	Almacén	activo	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N	\N	\N
\.


--
-- Data for Name: catalogo_item; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.catalogo_item (id, tenant_id, tipo, codigo, nombre, descripcion, orden, requiere_comentario, estado, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
e09565c0-2ff9-469c-9a84-c121c59bc9c7	\N	tipo_mantenimiento	CORRECTIVO	Correctivo	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
5e8cdfa9-2263-4d6c-99e7-e8a2af905922	\N	tipo_mantenimiento	PREVENTIVO	Preventivo	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
02499eed-dc6d-4437-9adc-6fcced7aa2b9	\N	tipo_mantenimiento	PREDICTIVO	Predictivo	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
8e667ff6-9869-4223-ae9b-ef2a80af5630	\N	tipo_mantenimiento	MEJORA	Mejora o modificación	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
4498b21d-e1d9-4f01-962f-13f5df8559f7	\N	tipo_mantenimiento	INSPECCION	Inspección	\N	5	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	impacto_operativo	PARADA_TOTAL	Parada total de la operación	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
a430b03f-e3e2-4478-a549-2833c39680ff	\N	impacto_operativo	PARADA_PARCIAL	Parada parcial o producción reducida	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
048ab5d9-3451-430d-8710-e26d6c729ceb	\N	impacto_operativo	RIESGO_SEGURIDAD	Riesgo de seguridad para personas	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
5ce7b82d-ddce-4fcc-a6ad-7a3c88606084	\N	impacto_operativo	RIESGO_AMBIENTAL	Riesgo ambiental	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
ade0baaa-c310-463d-b151-db8598cf8ae3	\N	impacto_operativo	CALIDAD	Afecta la calidad del producto o servicio	\N	5	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
e6a33651-63dd-4623-90f4-5db6efbd18d0	\N	impacto_operativo	SIN_IMPACTO	Sin impacto inmediato	\N	6	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
5018305f-02d5-455c-ac13-d508bcf18bfd	\N	impacto_operativo	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
d5bfda53-f8fd-491c-a4d1-e9f8e290178a	\N	motivo_cancelacion	DUPLICADA	Trabajo duplicado	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
9ec7a317-234d-4845-b8b5-7b40f6cf9320	\N	motivo_cancelacion	NO_PROCEDE	No procede tras la evaluación técnica	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
491d44b4-7ccd-4e27-90d3-1582929f0b1c	\N	motivo_cancelacion	RESUELTO	Se resolvió por otra vía	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
e48e0bd0-b47a-4171-9026-cbfab4e00f53	\N	motivo_cancelacion	SIN_PRESUPUESTO	Sin presupuesto o postergado	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
5877e5f7-8008-45c2-9712-4ed615c3ab1d	\N	motivo_cancelacion	ACTIVO_BAJA	El equipo salió de servicio	\N	5	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
dc064e15-4967-4189-934b-1e16b48e5a4b	\N	motivo_cancelacion	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
43937f78-d70f-43be-b5a4-d49a4c510b31	\N	motivo_reapertura	FALLA_REINCIDENTE	Falla reincidente	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
9fc81ff3-469a-45d9-911c-a472438cdfd0	\N	motivo_reapertura	TRABAJO_INCOMPLETO	Trabajo incompleto	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
0245a795-d55f-46b6-ab48-1d94c9884bf0	\N	motivo_reapertura	INFO_INCORRECTA	Información incorrecta	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
c4897bd9-02f2-48e0-8a77-0200b85e2eaf	\N	motivo_reapertura	EVIDENCIA_FALTANTE	Evidencia faltante	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
a9e20129-0bca-406f-8942-59b16e18104f	\N	motivo_reapertura	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
dd972ffb-ebd5-4e98-be7f-9789bbb9e35f	\N	motivo_pausa	FALTA_ACCESO	Falta de acceso al equipo o zona	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
3cabb8f2-f902-4465-9fb3-b00140efcd34	\N	motivo_pausa	ESPERA_REPUESTO	Espera de repuesto o material	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
45496a5d-d872-4464-b2d5-bc10570b70cc	\N	motivo_pausa	ESPERA_PROVEEDOR	Espera del proveedor	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
8d2fda36-bd2d-418c-8d06-8ad75f4528c6	\N	motivo_pausa	CONDICIONES	Condiciones climáticas u operativas	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
b36b9910-805c-4015-a547-7206366153eb	\N	motivo_pausa	SEGURIDAD	Suspensión por seguridad	\N	5	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
6287de2d-4df3-4b36-891f-740bb79f4129	\N	motivo_pausa	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
4c6aefd1-824a-416f-8062-179ca48472c0	\N	tipo_incidencia	FALTA_ACCESO	Falta de acceso	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
83f27463-b985-4a00-a665-ffb91df7f1fe	\N	tipo_incidencia	RETRASO_PROVEEDOR	Retraso de proveedor	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
ec1c8992-ba03-411e-b065-169a213c4bc1	\N	tipo_incidencia	MATERIAL_INCORRECTO	Material incorrecto	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
a23fb8f7-bf96-4991-9b3d-1e2cac7c2aaf	\N	tipo_incidencia	RIESGO_SEGURIDAD	Riesgo de seguridad	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
924e3d80-d6d3-4b77-a075-bc44d909fe3a	\N	tipo_incidencia	INTERFERENCIA	Interferencia con otra operación	\N	5	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
ecaebc41-3194-4e53-9b2a-914e389f0bc0	\N	tipo_incidencia	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
3f3d3ec6-a01d-4fe7-af6f-925b664784c2	\N	motivo_rechazo	NO_MANTENIMIENTO	No corresponde a mantenimiento	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
246353a0-b821-4a33-9293-be6a18990a5d	\N	motivo_rechazo	DUPLICADA	Duplicada	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
b3132c89-43ad-46e9-97bf-d8bf35739cf1	\N	motivo_rechazo	INFO_INSUFICIENTE	Información insuficiente	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
00bbf349-7bf1-4808-a6ca-38a4edddf34c	\N	motivo_rechazo	FUERA_ALCANCE	Fuera del alcance del área	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
8ea20062-a7fb-43e0-83aa-8cbe2d1e877d	\N	motivo_rechazo	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
f2b82842-5341-4282-b142-3610885cf744	\N	motivo_reemplazo_cotizacion	CAMBIO_ALCANCE	Cambio de alcance	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
1786f150-201d-471c-aca5-a9bee5cc757a	\N	motivo_reemplazo_cotizacion	MEJOR_OFERTA	Se seleccionó otra oferta	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
0cfe0fb1-174e-423e-a77c-f034cbb7b6f1	\N	motivo_reemplazo_cotizacion	ERROR_DATOS	Corrección de datos	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
66d29604-0f7e-427b-af47-a355a9ca4167	\N	motivo_reemplazo_cotizacion	VENCIDA	Cotización vencida	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
fe848a46-6057-4d86-b76f-400845387e28	\N	motivo_reemplazo_cotizacion	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
3b208549-bf99-4a16-9a39-71c5793756cf	\N	motivo_derivacion	ESPECIALIDAD	Especialidad técnica distinta	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
9260a4af-1386-4dd3-b75a-f7b92531d589	\N	motivo_derivacion	PROVEEDOR	Proveedor distinto	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
268832ca-d4b6-4961-a48f-c1cc9bdb3323	\N	motivo_derivacion	ALCANCE	Alcance independiente	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
8b21425a-2534-493a-9ff8-207835bebc85	\N	motivo_derivacion	CONTRATACION	Forma de contratación distinta	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
bfbd46cd-b9e2-4349-8906-666e78a8b3ba	\N	motivo_derivacion	HALLAZGO	Hallazgo durante la ejecución	\N	5	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
195ced42-2111-4c8b-8868-149ffc9c521a	\N	motivo_derivacion	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
f633bbbf-2d68-4a92-a7d2-b676cbd16542	\N	resultado_trabajo	RESUELTO	Resuelto	\N	1	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
6acb4f6b-d152-40dc-bc91-0342b11c707c	\N	resultado_trabajo	RESUELTO_PARCIAL	Resuelto parcialmente	\N	2	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
e4313083-a073-425a-ba5a-6882e1cb35c3	\N	resultado_trabajo	SIN_HALLAZGO	Sin hallazgo	\N	3	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
99e6b6e8-6ae7-4daf-a89e-bbb4ecadcd62	\N	resultado_trabajo	REQUIERE_SEGUIMIENTO	Requiere seguimiento	\N	4	f	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
2bb25caa-f176-42be-ae64-3d85e6f2a71d	\N	resultado_trabajo	OTRO	Otro	\N	99	t	activo	2026-08-22 22:53:35.607715-05	2026-08-22 22:53:35.607715-05	\N	\N	\N
\.


--
-- Data for Name: cecos; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.cecos (id, tenant_id, empresa_ruc_id, area_id, codigo, descripcion, estado, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
163b229b-dcd3-4d0e-87ed-3bd1bd76c9a0	5c921062-21ab-4a01-8f9a-2e2500e95893	1d2f2959-955c-41b0-96f0-cca1a3c631ba	36883387-4f15-411a-83f2-c8dfea7f88ca	CC-MANTTO	Centro de costo Mantenimiento	activo	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N	\N	\N
\.


--
-- Data for Name: conversacion; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.conversacion (id, tenant_id, ot_id, solo_lectura, created_at, updated_at) FROM stdin;
51071aab-cb16-4156-b58f-e833dca174f7	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	f	2026-09-12 10:34:15.879017-05	2026-09-20 15:34:16.878667-05
057e0ad0-6c9a-4bf4-a8c8-dad440f760da	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	f	2026-09-03 14:34:15.93803-05	2026-09-20 15:34:16.878667-05
9c1c0af0-75e8-4b9d-9f24-a2d7d7f9f8f6	5c921062-21ab-4a01-8f9a-2e2500e95893	ee9a06f5-0220-47a0-8e4a-d992333af106	f	2026-09-17 11:34:16.051891-05	2026-09-20 15:34:16.878667-05
f149a501-ba59-48c3-9839-60a4a0a402ab	5c921062-21ab-4a01-8f9a-2e2500e95893	cd790d32-39ab-4aba-b33d-2dc34a03831a	f	2026-08-05 08:34:16.261469-05	2026-09-20 15:34:16.878667-05
937caaac-9d82-403d-aa79-e13de2111568	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	t	2026-08-16 08:34:14.977113-05	2026-09-20 15:34:16.878667-05
c4ff63e6-8d8d-489f-8e57-42ad44caca38	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	t	2026-08-15 12:34:15.302141-05	2026-09-20 15:34:16.878667-05
babef1d8-c6d5-401f-926b-862a8eac59c6	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	f	2026-09-08 05:34:15.470721-05	2026-09-20 15:34:16.878667-05
f1d162ef-388b-47bd-9d87-1a24e5a748c7	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	f	2026-09-13 06:34:15.821136-05	2026-09-20 15:34:16.878667-05
e8172851-b434-4f84-9394-b48b02c47e6b	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	f	2026-09-18 07:34:16.012792-05	2026-09-20 15:34:16.878667-05
c2e7ff7d-7071-44ee-b00a-7be54b7a4805	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	t	2026-08-06 15:34:16.085222-05	2026-09-20 15:34:16.878667-05
684c219c-8225-4c65-b585-66475e053898	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	f	2026-08-29 12:34:16.304342-05	2026-09-20 15:34:16.878667-05
c0e97014-5815-4e69-bf7c-b366ec776687	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	f	2026-09-06 13:34:15.727191-05	2026-09-20 15:34:16.878667-05
fb0a4bc6-acb2-4516-9c08-c6b44e3f5fd5	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	f	2026-09-07 09:34:15.610587-05	2026-09-20 15:34:16.878667-05
\.


--
-- Data for Name: conversacion_participante; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.conversacion_participante (id, tenant_id, conversacion_id, usuario_id, puede_escribir, ve_notas_internas, invitado_por, activo, created_at, updated_at) FROM stdin;
3c0eb38d-bb47-4ef7-82f6-7a0997a979d2	5c921062-21ab-4a01-8f9a-2e2500e95893	937caaac-9d82-403d-aa79-e13de2111568	f71701ef-202b-4563-9c16-10f1d41b8135	t	f	\N	t	2026-09-20 15:34:14.977113-05	2026-09-20 15:34:14.977113-05
8430bf9f-ad61-46a1-979c-d3fc1fc22dec	5c921062-21ab-4a01-8f9a-2e2500e95893	937caaac-9d82-403d-aa79-e13de2111568	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:14.977113-05	2026-09-20 15:34:14.977113-05
813890c4-3af9-4e9a-8d4c-33a6d426d500	5c921062-21ab-4a01-8f9a-2e2500e95893	937caaac-9d82-403d-aa79-e13de2111568	5a11b0c5-7640-494f-9c8b-64a9a4e30673	t	f	\N	t	2026-09-20 15:34:15.044115-05	2026-09-20 15:34:15.044115-05
c591ca7a-91b0-4cb3-82e5-afea28d8ab62	5c921062-21ab-4a01-8f9a-2e2500e95893	c4ff63e6-8d8d-489f-8e57-42ad44caca38	89f7a8be-5af2-4d60-b578-9d01db2edce0	t	f	\N	t	2026-09-20 15:34:15.302141-05	2026-09-20 15:34:15.302141-05
b7603772-6af2-45cc-bd72-3b404716e0c2	5c921062-21ab-4a01-8f9a-2e2500e95893	c4ff63e6-8d8d-489f-8e57-42ad44caca38	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	t	t	\N	t	2026-09-20 15:34:15.302141-05	2026-09-20 15:34:15.302141-05
87c45edb-0815-4a78-98f0-b5411bb77a72	5c921062-21ab-4a01-8f9a-2e2500e95893	c4ff63e6-8d8d-489f-8e57-42ad44caca38	a7ee34e2-43bd-496d-99b0-ad8013072cea	t	f	\N	t	2026-09-20 15:34:15.350916-05	2026-09-20 15:34:15.350916-05
fc52b80d-8325-4f74-921c-4d8b53b36953	5c921062-21ab-4a01-8f9a-2e2500e95893	babef1d8-c6d5-401f-926b-862a8eac59c6	f71701ef-202b-4563-9c16-10f1d41b8135	t	f	\N	t	2026-09-20 15:34:15.470721-05	2026-09-20 15:34:15.470721-05
2769a72e-6cd0-452f-a919-c92a537813d1	5c921062-21ab-4a01-8f9a-2e2500e95893	babef1d8-c6d5-401f-926b-862a8eac59c6	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:15.470721-05	2026-09-20 15:34:15.470721-05
92811efa-1532-4236-a6d4-7e93f4d7e16e	5c921062-21ab-4a01-8f9a-2e2500e95893	babef1d8-c6d5-401f-926b-862a8eac59c6	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	t	f	\N	t	2026-09-20 15:34:15.529557-05	2026-09-20 15:34:15.529557-05
e4130828-c2ec-4b49-8b0d-8f1bde7ec326	5c921062-21ab-4a01-8f9a-2e2500e95893	fb0a4bc6-acb2-4516-9c08-c6b44e3f5fd5	f71701ef-202b-4563-9c16-10f1d41b8135	t	f	\N	t	2026-09-20 15:34:15.610587-05	2026-09-20 15:34:15.610587-05
85c61987-c83f-4e9a-a4f5-095b01959d7e	5c921062-21ab-4a01-8f9a-2e2500e95893	fb0a4bc6-acb2-4516-9c08-c6b44e3f5fd5	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	t	t	\N	t	2026-09-20 15:34:15.610587-05	2026-09-20 15:34:15.610587-05
7cf26725-abba-4c7b-ab96-1335ad2cadf8	5c921062-21ab-4a01-8f9a-2e2500e95893	fb0a4bc6-acb2-4516-9c08-c6b44e3f5fd5	a7ee34e2-43bd-496d-99b0-ad8013072cea	t	f	\N	t	2026-09-20 15:34:15.663697-05	2026-09-20 15:34:15.663697-05
eaf4dd1f-71c8-4d42-847d-dabad08a1c81	5c921062-21ab-4a01-8f9a-2e2500e95893	c0e97014-5815-4e69-bf7c-b366ec776687	89f7a8be-5af2-4d60-b578-9d01db2edce0	t	f	\N	t	2026-09-20 15:34:15.727191-05	2026-09-20 15:34:15.727191-05
16ca04ef-aedf-4fa4-afb4-22c2279bac8d	5c921062-21ab-4a01-8f9a-2e2500e95893	c0e97014-5815-4e69-bf7c-b366ec776687	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:15.727191-05	2026-09-20 15:34:15.727191-05
e1c0a3d4-e213-48ff-846f-a55edbcf1757	5c921062-21ab-4a01-8f9a-2e2500e95893	c0e97014-5815-4e69-bf7c-b366ec776687	5a11b0c5-7640-494f-9c8b-64a9a4e30673	t	f	\N	t	2026-09-20 15:34:15.777671-05	2026-09-20 15:34:15.777671-05
e0fdfd2a-41c1-491c-afdb-c9623c05e8ea	5c921062-21ab-4a01-8f9a-2e2500e95893	f1d162ef-388b-47bd-9d87-1a24e5a748c7	f71701ef-202b-4563-9c16-10f1d41b8135	t	f	\N	t	2026-09-20 15:34:15.821136-05	2026-09-20 15:34:15.821136-05
259bb0a6-3974-4bb4-9544-8e03bc49c421	5c921062-21ab-4a01-8f9a-2e2500e95893	f1d162ef-388b-47bd-9d87-1a24e5a748c7	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:15.821136-05	2026-09-20 15:34:15.821136-05
1291e507-4bc2-4bfb-8e26-4b5c491f1082	5c921062-21ab-4a01-8f9a-2e2500e95893	51071aab-cb16-4156-b58f-e833dca174f7	f71701ef-202b-4563-9c16-10f1d41b8135	t	f	\N	t	2026-09-20 15:34:15.879017-05	2026-09-20 15:34:15.879017-05
4bae3db4-db59-492d-a4b8-bbbac16d9ce6	5c921062-21ab-4a01-8f9a-2e2500e95893	51071aab-cb16-4156-b58f-e833dca174f7	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	t	t	\N	t	2026-09-20 15:34:15.879017-05	2026-09-20 15:34:15.879017-05
a7a5ae8a-9af6-4ac4-b4e0-337d36a46792	5c921062-21ab-4a01-8f9a-2e2500e95893	057e0ad0-6c9a-4bf4-a8c8-dad440f760da	f71701ef-202b-4563-9c16-10f1d41b8135	t	f	\N	t	2026-09-20 15:34:15.93803-05	2026-09-20 15:34:15.93803-05
e77d134f-d2a3-4574-85fb-fedacaa710cb	5c921062-21ab-4a01-8f9a-2e2500e95893	057e0ad0-6c9a-4bf4-a8c8-dad440f760da	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:15.93803-05	2026-09-20 15:34:15.93803-05
bc5cb8d6-7b0e-434c-9a07-14d3f3bdf5bf	5c921062-21ab-4a01-8f9a-2e2500e95893	057e0ad0-6c9a-4bf4-a8c8-dad440f760da	a7ee34e2-43bd-496d-99b0-ad8013072cea	t	f	\N	t	2026-09-20 15:34:15.970837-05	2026-09-20 15:34:15.970837-05
7632e3c1-30e4-4efd-9e57-354bd2bf5b22	5c921062-21ab-4a01-8f9a-2e2500e95893	e8172851-b434-4f84-9394-b48b02c47e6b	89f7a8be-5af2-4d60-b578-9d01db2edce0	t	f	\N	t	2026-09-20 15:34:16.012792-05	2026-09-20 15:34:16.012792-05
a4b2b2c1-e3d3-4b00-b54f-64f50f6a291c	5c921062-21ab-4a01-8f9a-2e2500e95893	e8172851-b434-4f84-9394-b48b02c47e6b	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:16.012792-05	2026-09-20 15:34:16.012792-05
8e5d20eb-242a-458d-90b6-93506b3ad393	5c921062-21ab-4a01-8f9a-2e2500e95893	9c1c0af0-75e8-4b9d-9f24-a2d7d7f9f8f6	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:16.051891-05	2026-09-20 15:34:16.051891-05
e2831e2a-2606-4350-9993-ce4cd1bdeae1	5c921062-21ab-4a01-8f9a-2e2500e95893	c2e7ff7d-7071-44ee-b00a-7be54b7a4805	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:16.085222-05	2026-09-20 15:34:16.085222-05
11b3838d-8309-4651-bb65-11ade8c35b58	5c921062-21ab-4a01-8f9a-2e2500e95893	c2e7ff7d-7071-44ee-b00a-7be54b7a4805	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	t	f	\N	t	2026-09-20 15:34:16.158376-05	2026-09-20 15:34:16.158376-05
d9f72190-2dc9-4123-9cba-d54f24423558	5c921062-21ab-4a01-8f9a-2e2500e95893	f149a501-ba59-48c3-9839-60a4a0a402ab	f71701ef-202b-4563-9c16-10f1d41b8135	t	f	\N	t	2026-09-20 15:34:16.261469-05	2026-09-20 15:34:16.261469-05
30fd27b7-5b66-4f7d-be12-5bd2245eab9a	5c921062-21ab-4a01-8f9a-2e2500e95893	f149a501-ba59-48c3-9839-60a4a0a402ab	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:16.261469-05	2026-09-20 15:34:16.261469-05
9baedda9-912e-49ba-a832-44312cdb58b6	5c921062-21ab-4a01-8f9a-2e2500e95893	684c219c-8225-4c65-b585-66475e053898	f71701ef-202b-4563-9c16-10f1d41b8135	t	f	\N	t	2026-09-20 15:34:16.304342-05	2026-09-20 15:34:16.304342-05
a827fbb8-a708-4834-95d1-0c6aa6af3e63	5c921062-21ab-4a01-8f9a-2e2500e95893	684c219c-8225-4c65-b585-66475e053898	472ed7f9-7862-406e-8075-50e2fdc26dbb	t	t	\N	t	2026-09-20 15:34:16.304342-05	2026-09-20 15:34:16.304342-05
32ec0a02-9253-4046-8449-6b846c879e06	5c921062-21ab-4a01-8f9a-2e2500e95893	684c219c-8225-4c65-b585-66475e053898	5a11b0c5-7640-494f-9c8b-64a9a4e30673	t	f	\N	t	2026-09-20 15:34:16.35434-05	2026-09-20 15:34:16.35434-05
\.


--
-- Data for Name: correlativo; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.correlativo (id, tenant_id, tipo_documento, prefijo, ultimo_numero, updated_at) FROM stdin;
6d4fcb17-03ac-4e75-86d3-598ea91a4df1	5c921062-21ab-4a01-8f9a-2e2500e95893	OT	OT	13	2026-09-20 15:34:16.304342-05
1985da9d-fda3-4649-b297-0fa4af08080a	5c921062-21ab-4a01-8f9a-2e2500e95893	ST	ST	19	2026-09-20 15:34:16.522589-05
\.


--
-- Data for Name: costo_unitario; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.costo_unitario (id, tenant_id, ot_id, cotizacion_id, fuente, texto_original, descripcion_normalizada_id, tipo_trabajo_id, concepto, cantidad, unidad, monto_total, costo_unitario, moneda, fecha_referencia, proveedor_id, sucursal_id, empresa_ruc_id, area_id, fue_emergencia, ot_es_derivada, estado_validacion, confianza, es_outlier, outlier_justificacion, es_comparable, created_at, updated_at, created_by, updated_by) FROM stdin;
f5d74e1b-a79b-4814-98fd-00a5c1c246c7	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	8ae2a1b6-3d59-429f-abbf-8ea949d00930	cotizacion	KIT VALVULAS 2DA ETAPA COMPRESOR ATLAS GA75 + MANO DE OBRA	\N	743ce9a9-33cc-4c22-b6de-b0bd15bdfa61	repuesto	1.0000	kit	4850.00	4850.0000	PEN	2026-08-10	65d951bb-e837-4af9-9d40-218eb27f8abc	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	f	f	sin_validar	\N	f	\N	t	2026-08-16 08:34:16.568911-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
bb557a13-f183-4ac1-9125-fb9611f609d3	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	941e9e9a-0613-4288-a4f9-17a68d17668f	cotizacion	CONTACTOR LC1D80 + RELE TERMICO LRD35 INSTALADO	\N	70d72bcc-44dd-4383-add9-d2e21e9c0477	repuesto	2.0000	und	2140.00	1070.0000	PEN	2026-08-09	2dc1f1f5-4c5b-40d8-aeaf-1cad7d293eb7	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	f	f	sin_validar	\N	f	\N	t	2026-08-15 12:34:16.595734-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
b4822b6f-0886-49b1-b848-7010954b9f5c	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	8145f65b-f63d-4121-96eb-3a1e7775f9af	cotizacion	JUEGO DE RETENES CILINDRO 160MM + FILTRO RETORNO	\N	bf147cd2-23c8-4e07-819e-a6cde044e15e	repuesto	1.0000	juego	3290.00	3290.0000	PEN	2026-09-02	e33609de-3734-4b1b-badf-f08ce365c2a2	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	f	f	sin_validar	\N	f	\N	t	2026-09-08 05:34:16.620954-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
41d1dc1c-9f24-4d60-aff5-8e04ebbbd82b	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	f9af5c86-a168-40ec-a440-0c0fc849c120	cotizacion	RODAMIENTOS 6312 C3 (PAR) + BALANCEO DINAMICO ROTOR	\N	a92169d4-06ea-4d10-b36b-d8092b14f709	repuesto	2.0000	und	2850.00	1425.0000	PEN	2026-09-07	d78f64df-a44d-4ed8-a2b2-3ca5a7b26955	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	f	f	sin_validar	\N	f	\N	t	2026-09-13 06:34:16.643365-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
1d69c883-fb44-477b-9c3f-971c74923db7	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	64dc018a-0a2e-45e7-913d-e1dcdf82baf9	cotizacion	RECTIFICADO BOMBA ENGRANAJES + SELLOS	\N	bf147cd2-23c8-4e07-819e-a6cde044e15e	servicio	1.0000	servicio	1960.00	1960.0000	PEN	2026-07-31	e33609de-3734-4b1b-badf-f08ce365c2a2	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	f	t	sin_validar	\N	f	\N	t	2026-08-06 15:34:16.665161-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
14537c4c-089f-4ae2-8a1d-55d0275cede5	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	c04db5da-741c-4f8c-af00-8f461a5a55f3	cotizacion	VALVULA RETENCION 4" BRONCE + RESORTE	\N	bf147cd2-23c8-4e07-819e-a6cde044e15e	repuesto	1.0000	und	980.00	980.0000	PEN	2026-08-23	6347f0eb-53cf-41d2-8df5-32cf26fb5a74	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	f	f	sin_validar	\N	f	\N	t	2026-08-29 12:34:16.69545-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
fc517ca7-0336-4c07-bdaf-14a8235105df	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	fee02c0d-bc83-47cd-b082-7f25428e0fd3	cotizacion	SENSOR FIN DE CARRERA OMRON + ENDEREZADO DE GUIA	\N	191c571d-7b81-452c-8c99-92905ba5ca57	servicio	1.0000	servicio	1180.00	1180.0000	PEN	2026-08-31	b89663d0-2b51-40b1-8e21-488ff2328367	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	f	f	sin_validar	\N	f	\N	t	2026-09-06 13:34:16.717544-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
beea5c0c-b75b-4c50-b8d1-8c9b3f6ed775	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	20dd8496-ea84-44bb-8740-a36c597b1147	cotizacion	CELDA DE CARGA 5KN CON CERTIFICADO DE CALIBRACION	\N	1eed878f-1909-4f26-81c5-e8a85a527e9f	repuesto	1.0000	und	7800.00	7800.0000	PEN	2026-09-01	74322f64-4408-4da3-b4af-f6e53dbcf203	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	f	f	sin_validar	\N	f	\N	t	2026-09-07 09:34:16.739821-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Data for Name: cotizacion; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.cotizacion (id, tenant_id, ot_id, version, vigente, proveedor_id, proveedor_ruc, proveedor_nombre, numero_cotizacion, fecha_cotizacion, monto, moneda, plazo_ofrecido_dias, observaciones, motivo_reemplazo, reemplaza_a, invalidada, cargada_por, created_at, updated_at, created_by, updated_by, validez_dias) FROM stdin;
8ae2a1b6-3d59-429f-abbf-8ea949d00930	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	1	t	65d951bb-e837-4af9-9d40-218eb27f8abc	20512345671	SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C.	COT-2026-0412	2026-08-10	4850.00	PEN	7	Incluye kit original, mano de obra y puesta en marcha.	\N	\N	f	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.024621-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	30
941e9e9a-0613-4288-a4f9-17a68d17668f	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	1	t	2dc1f1f5-4c5b-40d8-aeaf-1cad7d293eb7	20487654320	ELECTROMONTAJES ANDINOS S.R.L.	COT-2026-0418	2026-08-09	2140.00	PEN	5	\N	\N	\N	f	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.333867-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	30
8145f65b-f63d-4121-96eb-3a1e7775f9af	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	1	t	e33609de-3734-4b1b-badf-f08ce365c2a2	20456789014	HIDRÁULICA INDUSTRIAL LIMA S.A.C.	COT-2026-0421	2026-09-02	3290.00	PEN	10	\N	\N	\N	f	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.508809-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	30
f9af5c86-a168-40ec-a440-0c0fc849c120	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	1	t	d78f64df-a44d-4ed8-a2b2-3ca5a7b26955	20555123451	RECTIFICACIONES DEL SUR S.A.C.	COT-2026-0433	2026-09-07	2850.00	PEN	12	\N	\N	\N	f	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:15.853975-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	30
64dc018a-0a2e-45e7-913d-e1dcdf82baf9	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	1	t	e33609de-3734-4b1b-badf-f08ce365c2a2	20456789014	HIDRÁULICA INDUSTRIAL LIMA S.A.C.	COT-2026-0436	2026-07-31	1960.00	PEN	8	\N	\N	\N	f	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.140996-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	30
c04db5da-741c-4f8c-af00-8f461a5a55f3	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	1	t	6347f0eb-53cf-41d2-8df5-32cf26fb5a74	20601234565	SISTEMAS CONTRA INCENDIO S.A.C.	COT-2026-0440	2026-08-23	980.00	PEN	3	\N	\N	\N	f	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.336221-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	30
fee02c0d-bc83-47cd-b082-7f25428e0fd3	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	1	t	b89663d0-2b51-40b1-8e21-488ff2328367	20567890121	PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L.	COT-2026-0430	2026-08-31	1180.00	PEN	4	\N	\N	\N	f	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.759791-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	30
20dd8496-ea84-44bb-8740-a36c597b1147	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	1	t	74322f64-4408-4da3-b4af-f6e53dbcf203	20398765436	INSTRUMENTACIÓN Y CONTROL S.A.	COT-2026-0425	2026-09-01	7800.00	PEN	21	Celda importada; incluye certificado de calibración.	\N	\N	f	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.645482-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	30
\.


--
-- Data for Name: descripcion_normalizada; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.descripcion_normalizada (id, tenant_id, etiqueta, version, vigente, tipo_trabajo_id, aprobada_por, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: diagnostico; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.diagnostico (id, tenant_id, ot_id, version, vigente, diagnostico, causa_probable, alcance, trabajo_a_realizar, observaciones, lecturas_instrumentos, autor_id, aprobado_por, aprobado_at, motivo_cambio, reemplaza_a, created_at, updated_at, created_by, updated_by) FROM stdin;
a7d1acee-a648-4a11-97e3-449d55bfd2a5	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	2	t	El corte lo provoca la válvula de gas, que cierra por caída de presión en la red, no el presostato.	Caída de presión de red en horario nocturno, cuando la planta vecina consume.	Se amplía al tren de válvulas y a la acometida de gas.	Instalar registrador de presión en la acometida y evaluar regulador de mayor capacidad.	\N	Presión de red 18 mbar a las 02:40 (mínimo de operación 20 mbar)	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	\N	\N	El registro nocturno descartó el presostato: la presión de red cae antes del corte.	6c790e33-e72e-41e8-8b39-f674aee35b27	2026-09-12 10:34:15.912279-05	2026-09-20 15:34:16.878667-05	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	0a2b7719-37d2-44fa-84d2-6004c3a7b9df
6c790e33-e72e-41e8-8b39-f674aee35b27	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	1	f	Presostato de seguridad corta por presión baja durante la noche.	Ajuste del presostato demasiado cerca del mínimo de operación.	Lazo de control de presión.	Reajustar el presostato y monitorear una semana.	\N	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	\N	\N	\N	\N	2026-09-12 10:34:15.894171-05	2026-09-20 15:34:16.878667-05	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	0a2b7719-37d2-44fa-84d2-6004c3a7b9df
b00067d2-e86e-4a23-adcf-13f448a9c1c0	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	1	t	Borne de la barra principal flojo con marcas de arco eléctrico.	Ajuste perdido por ciclos térmicos.	Barra principal y bornes de salida.	Reajustar con torquímetro, reemplazar el borne dañado y termografiar.	\N	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	\N	\N	\N	\N	2026-09-03 14:34:15.953977-05	2026-09-20 15:34:16.878667-05	a7ee34e2-43bd-496d-99b0-ad8013072cea	a7ee34e2-43bd-496d-99b0-ad8013072cea
6aaf55e9-be62-46ac-a9bb-9689b116d49f	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	1	t	Válvula de admisión de la segunda etapa con fuga y anillos desgastados.	Horas de servicio por encima del plan de mantenimiento.	Segunda etapa del compresor; el motor eléctrico queda fuera.	Reemplazar kit de válvulas y anillos, cambiar aceite y probar cuatro horas.	\N	Presión 5,8 bar · temperatura de descarga 96 °C	5a11b0c5-7640-494f-9c8b-64a9a4e30673	\N	\N	\N	\N	2026-08-16 08:34:15.003489-05	2026-09-20 15:34:16.878667-05	5a11b0c5-7640-494f-9c8b-64a9a4e30673	5a11b0c5-7640-494f-9c8b-64a9a4e30673
0d9044ca-0479-4db1-b404-af45ca79d91d	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	1	t	Contactor del carro principal con carbonización en los contactos.	Arranques repetidos con carga máxima.	Tablero del carro principal.	Reemplazar contactor y revisar el ajuste del relé térmico.	\N	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	\N	\N	\N	\N	2026-08-15 12:34:15.317312-05	2026-09-20 15:34:16.878667-05	a7ee34e2-43bd-496d-99b0-ad8013072cea	a7ee34e2-43bd-496d-99b0-ad8013072cea
dd9a49f5-646a-4dbb-ac19-9b87263fc462	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	1	t	Retén del cilindro principal vencido; pérdida continua por el vástago.	Desgaste por horas de servicio y partículas en el aceite.	Cilindro principal y filtro de retorno.	Reemplazar retenes, cambiar filtro y reponer aceite.	\N	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	\N	\N	\N	\N	2026-09-08 05:34:15.490058-05	2026-09-20 15:34:16.878667-05	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	0a2b7719-37d2-44fa-84d2-6004c3a7b9df
791fa998-20f5-400d-878e-5ee9b4313624	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	1	t	Bomba de engranajes con holgura fuera de tolerancia.	Desgaste normal por horas de servicio.	Bomba de elevación.	Rectificar la bomba y reemplazar sellos.	\N	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	\N	\N	\N	\N	2026-08-06 15:34:16.122692-05	2026-09-20 15:34:16.878667-05	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	0a2b7719-37d2-44fa-84d2-6004c3a7b9df
58f91adb-9c05-4eb7-8d60-ceedb7194255	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	1	t	Rodamiento del lado libre con juego axial de 0,6 mm.	Desalineación acumulada por asentamiento de la base.	Conjunto motriz del ventilador.	Reemplazar rodamientos, alinear con láser y balancear el rotor.	\N	Vibración 7,2 mm/s · temperatura 78 °C	5a11b0c5-7640-494f-9c8b-64a9a4e30673	\N	\N	\N	\N	2026-09-13 06:34:15.836675-05	2026-09-20 15:34:16.878667-05	5a11b0c5-7640-494f-9c8b-64a9a4e30673	5a11b0c5-7640-494f-9c8b-64a9a4e30673
18354423-f450-4025-9dd2-d33d2f45b580	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	1	t	Dos problemas independientes: caída de presión en el circuito de elevación y falla en el módulo de control.	Bomba desgastada por un lado; módulo con avería de fábrica por otro.	Sistema hidráulico de elevación; el eléctrico se separa.	Reparar el circuito hidráulico y derivar la parte eléctrica a un especialista.	\N	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	\N	\N	\N	\N	2026-09-18 07:34:16.033936-05	2026-09-20 15:34:16.878667-05	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	0a2b7719-37d2-44fa-84d2-6004c3a7b9df
d0368a13-9b72-498c-8baa-8b92ca667a0e	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	1	t	Válvula de retención con asiento marcado; permite retorno.	Sedimento acumulado en el asiento.	Válvula de retención de la bomba principal.	Desmontar, limpiar el asiento y reemplazar el resorte.	\N	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	\N	\N	\N	\N	2026-08-29 12:34:16.320121-05	2026-09-20 15:34:16.878667-05	5a11b0c5-7640-494f-9c8b-64a9a4e30673	5a11b0c5-7640-494f-9c8b-64a9a4e30673
f02374ce-1ee7-40b8-99c8-e794d5c77646	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	1	t	Guía inferior deformada y final de carrera descalibrado.	Golpe de montacargas contra la guía.	Guía inferior y sensores de final de carrera.	Enderezar la guía, reemplazar el sensor y recalibrar recorrido.	\N	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	\N	\N	\N	\N	2026-09-06 13:34:15.742902-05	2026-09-20 15:34:16.878667-05	5a11b0c5-7640-494f-9c8b-64a9a4e30673	5a11b0c5-7640-494f-9c8b-64a9a4e30673
ea9f0825-89c1-4aae-a404-c87094cfea37	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	1	t	Celda de carga sin señal; el amplificador entrega 0 mV con carga aplicada.	Celda dañada por sobrecarga en la última prueba.	Celda de carga y su cableado.	Reemplazar la celda, recalibrar el banco y emitir certificado.	\N	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	\N	\N	\N	\N	2026-09-07 09:34:15.627826-05	2026-09-20 15:34:16.878667-05	a7ee34e2-43bd-496d-99b0-ad8013072cea	a7ee34e2-43bd-496d-99b0-ad8013072cea
\.


--
-- Data for Name: ejecucion; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.ejecucion (id, tenant_id, ot_id, responsable_id, inicio_real, termino_real, confirmado_por, inicio_sin_cotizacion, observaciones, created_at, updated_at, created_by, updated_by) FROM stdin;
a2ba15f3-b040-4d7f-9525-6bfacfbfa417	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-03 14:34:15.970837-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	t	\N	2026-09-03 14:34:15.970837-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
c46d22d1-66df-4d67-9e74-a85f9068e62a	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.044115-05	2026-08-16 08:34:15.13043-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	f	\N	2026-08-16 08:34:15.044115-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	5a11b0c5-7640-494f-9c8b-64a9a4e30673
6d40ab5d-ac10-484e-af84-dddf9658241c	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.350916-05	2026-08-15 12:34:15.386203-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	f	\N	2026-08-15 12:34:15.350916-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	a7ee34e2-43bd-496d-99b0-ad8013072cea
55261a69-3d5b-432f-b469-dc4a7301fa69	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.529557-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	f	\N	2026-09-08 05:34:15.529557-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
31bb6e82-2525-4db0-92e8-16c69e33b145	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-08-06 15:34:16.158376-05	2026-08-06 15:34:16.17693-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	f	\N	2026-08-06 15:34:16.158376-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0a2b7719-37d2-44fa-84d2-6004c3a7b9df
0955b1e4-ac5c-4a01-9cba-c0c1617f03ce	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-29 12:34:16.35434-05	2026-08-29 12:34:16.372475-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	f	\N	2026-08-29 12:34:16.35434-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	5a11b0c5-7640-494f-9c8b-64a9a4e30673
51ea948f-b221-4fee-9d44-015c3c64bc1d	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-06 13:34:15.777671-05	2026-09-06 13:34:15.795487-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	f	\N	2026-09-06 13:34:15.777671-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	5a11b0c5-7640-494f-9c8b-64a9a4e30673
85752034-9693-429f-b32d-44b18fa17bb6	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-07 09:34:15.663697-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	f	\N	2026-09-07 09:34:15.663697-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Data for Name: empresa_ruc; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.empresa_ruc (id, tenant_id, ruc, razon_social, nombre_corto, estado, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
1d2f2959-955c-41b0-96f0-cca1a3c631ba	5c921062-21ab-4a01-8f9a-2e2500e95893	20100000001	DEMO INDUSTRIAL S.A.C.	Demo Industrial	activo	2026-08-22 22:53:35.61569-05	2026-09-20 15:34:10.724412-05	\N	\N	\N
\.


--
-- Data for Name: liberacion_historial; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.liberacion_historial (id, secuencia, tenant_id, ot_id, orden_compra_id, estado_anterior, estado_nuevo, monto_anterior, monto_nuevo, moneda, observacion, actor_id, created_at) FROM stdin;
324d4ae5-914e-4861-b5df-ed126865bd64	1	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	a4885b26-f263-44c9-a0c0-27a9b056d34e	\N	total	\N	4850.00	PEN	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.249641-05
\.


--
-- Data for Name: mensaje; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.mensaje (id, tenant_id, conversacion_id, tipo, visibilidad, estado, cuerpo, cuerpo_anterior, responde_a, autor_id, menciones, editado_at, retirado_at, retirado_por, created_at, updated_at) FROM stdin;
6e33754e-687c-4e19-a788-a181cab417a9	5c921062-21ab-4a01-8f9a-2e2500e95893	937caaac-9d82-403d-aa79-e13de2111568	humano	canal	publicado	Sí, la programamos el sábado a primera hora.	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	{}	\N	\N	\N	2026-08-16 08:34:15.11424-05	2026-09-20 15:34:16.878667-05
c9d4eaf7-134a-41fa-81fe-37ad56419f5e	5c921062-21ab-4a01-8f9a-2e2500e95893	937caaac-9d82-403d-aa79-e13de2111568	humano	canal	publicado	¿La prueba se puede correr el sábado para no parar la línea?	\N	\N	f71701ef-202b-4563-9c16-10f1d41b8135	{}	\N	\N	\N	2026-08-16 08:34:15.096402-05	2026-09-20 15:34:16.878667-05
e98a860d-4e3b-48a3-8d3b-82874f009ab0	5c921062-21ab-4a01-8f9a-2e2500e95893	babef1d8-c6d5-401f-926b-862a8eac59c6	humano	interna	publicado	Interno: el proveedor avisó que el vástago llega con un día de retraso.	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	{}	\N	\N	\N	2026-09-08 05:34:15.58271-05	2026-09-20 15:34:16.878667-05
\.


--
-- Data for Name: notificacion; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.notificacion (id, tenant_id, destinatario_id, evento, titulo, cuerpo, entidad_tipo, entidad_id, ot_id, canal, estado, leida_at, error_envio, created_at, updated_at) FROM stdin;
29c65b2f-26c2-4721-a8c3-303ecfe9b9ac	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000001	Compresor de planta pierde presión	solicitud_trabajo	c5d4a2a9-9988-4d7a-ad76-555e3020bafe	\N	interno	pendiente	\N	\N	2026-09-20 15:34:14.965094-05	2026-09-20 15:34:14.965094-05
0d3aaa53-ee14-470a-b272-a7f30b088342	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000001	Compresor de planta pierde presión	solicitud_trabajo	c5d4a2a9-9988-4d7a-ad76-555e3020bafe	\N	interno	pendiente	\N	\N	2026-09-20 15:34:14.965094-05	2026-09-20 15:34:14.965094-05
4ac398c7-5e15-43a7-a532-6a6a893f797a	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000002	Puente grúa se detiene en el tramo central	solicitud_trabajo	99d4f059-ece9-4360-9490-c612a98ede66	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.292016-05	2026-09-20 15:34:15.292016-05
03ec7da2-4409-4920-a4ac-e0e0e8f02fa1	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000002	Puente grúa se detiene en el tramo central	solicitud_trabajo	99d4f059-ece9-4360-9490-c612a98ede66	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.292016-05	2026-09-20 15:34:15.292016-05
aec439e2-22d3-4013-aff6-fdd31d475ad7	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000003	Fuga de aceite en la prensa hidráulica 3	solicitud_trabajo	5787000f-3be4-46c8-849b-51b922142d11	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.460481-05	2026-09-20 15:34:15.460481-05
c08ab747-d515-473e-96ff-a454225aec10	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000003	Fuga de aceite en la prensa hidráulica 3	solicitud_trabajo	5787000f-3be4-46c8-849b-51b922142d11	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.460481-05	2026-09-20 15:34:15.460481-05
8d6066be-35fa-4d79-a71f-c456e5bff33c	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000004	Banco de pruebas sin lectura de par	solicitud_trabajo	0c01b409-e417-4a5b-baad-acba87bbf851	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.599742-05	2026-09-20 15:34:15.599742-05
f4af90d6-7608-44f9-980a-f7faa89e0ae7	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000004	Banco de pruebas sin lectura de par	solicitud_trabajo	0c01b409-e417-4a5b-baad-acba87bbf851	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.599742-05	2026-09-20 15:34:15.599742-05
ac40c55d-1e51-4e5a-bb06-f46172726f73	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000005	Portón del almacén no cierra completo	solicitud_trabajo	15e5d80b-173b-451f-a58f-f49dd40813e9	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.716094-05	2026-09-20 15:34:15.716094-05
eb8c44b5-c23d-4832-bd9b-6e2329bc4631	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000005	Portón del almacén no cierra completo	solicitud_trabajo	15e5d80b-173b-451f-a58f-f49dd40813e9	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.716094-05	2026-09-20 15:34:15.716094-05
b5ca1372-b7bc-49d9-b03c-097d920ec84e	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000006	Ruido metálico en el ventilador de extracción	solicitud_trabajo	6b1ecb72-330f-4e70-8e65-14b41fd94f77	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.813004-05	2026-09-20 15:34:15.813004-05
ed032724-c0fa-4d72-8a4a-b229097024bb	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000006	Ruido metálico en el ventilador de extracción	solicitud_trabajo	6b1ecb72-330f-4e70-8e65-14b41fd94f77	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.813004-05	2026-09-20 15:34:15.813004-05
ba2a1038-3697-4b10-9b46-20abc411a1fd	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000007	Caldera se apaga sola por las noches	solicitud_trabajo	e54dbab5-2c51-433d-9c19-0400620d5f99	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.870973-05	2026-09-20 15:34:15.870973-05
16ed7d2c-b48d-498c-b8a8-20f96f536e9d	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000007	Caldera se apaga sola por las noches	solicitud_trabajo	e54dbab5-2c51-433d-9c19-0400620d5f99	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.870973-05	2026-09-20 15:34:15.870973-05
297c4bd4-6b4d-4ce9-b9dd-2733e8c1d718	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000008	Tablero principal con olor a quemado	solicitud_trabajo	998d96e3-cb46-45ff-abf5-2f8885f40930	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.92883-05	2026-09-20 15:34:15.92883-05
b70271d9-bc1a-42fd-a0ea-4201d97d9f8e	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000008	Tablero principal con olor a quemado	solicitud_trabajo	998d96e3-cb46-45ff-abf5-2f8885f40930	\N	interno	pendiente	\N	\N	2026-09-20 15:34:15.92883-05	2026-09-20 15:34:15.92883-05
5e8a3e80-0c4f-483c-9c15-6d48562105f2	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000009	Montacargas 4 sin fuerza y con falla eléctrica	solicitud_trabajo	3c527e52-05d9-4490-b025-2785a2e0a7b2	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.003112-05	2026-09-20 15:34:16.003112-05
492dadf6-a271-4fa0-b97f-90eb88dad28e	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000009	Montacargas 4 sin fuerza y con falla eléctrica	solicitud_trabajo	3c527e52-05d9-4490-b025-2785a2e0a7b2	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.003112-05	2026-09-20 15:34:16.003112-05
af822708-0b6a-4ec0-b4c7-ab7129e08425	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000010	Cambiar luminarias del pasillo 3	solicitud_trabajo	48ebc1d1-f4de-4401-9cca-06e3d91e3621	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.251273-05	2026-09-20 15:34:16.251273-05
746a62b2-8962-4c4f-96ea-f686de04bd75	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000010	Cambiar luminarias del pasillo 3	solicitud_trabajo	48ebc1d1-f4de-4401-9cca-06e3d91e3621	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.251273-05	2026-09-20 15:34:16.251273-05
f67165e4-25e0-4834-950f-694f9f909725	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000011	Bomba de agua del sistema contra incendios pierde presión	solicitud_trabajo	9d56b79e-e16a-497a-a936-985e184807c1	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.293498-05	2026-09-20 15:34:16.293498-05
b5e6d833-2d12-4cf9-a696-429187ebd8aa	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000011	Bomba de agua del sistema contra incendios pierde presión	solicitud_trabajo	9d56b79e-e16a-497a-a936-985e184807c1	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.293498-05	2026-09-20 15:34:16.293498-05
8d88ea71-7aa1-4ed5-9d0b-a1e423a0b575	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000012	Vibración en el extractor de la zona de soldadura	solicitud_trabajo	30e96f19-2a6f-4224-a207-1e96e32a5bbb	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.453022-05	2026-09-20 15:34:16.453022-05
c9a80819-02e8-40bd-9bb7-a8dcd971e47d	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000012	Vibración en el extractor de la zona de soldadura	solicitud_trabajo	30e96f19-2a6f-4224-a207-1e96e32a5bbb	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.453022-05	2026-09-20 15:34:16.453022-05
1983c565-5705-4020-909c-46ba82edc30b	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000013	Gotera sobre el estante de repuestos	solicitud_trabajo	5c591e07-051b-4dfa-9890-a6f964c9bcc4	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.458687-05	2026-09-20 15:34:16.458687-05
518c0c10-bc17-4b83-b7c0-024fd6a749d4	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000013	Gotera sobre el estante de repuestos	solicitud_trabajo	5c591e07-051b-4dfa-9890-a6f964c9bcc4	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.458687-05	2026-09-20 15:34:16.458687-05
4e6d0ac1-8f8e-489d-882b-efbd96143558	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000014	Balanza de recepción descuadra 3 kg	solicitud_trabajo	ded455bf-93a0-4484-b8b2-c9f4785f173c	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.466756-05	2026-09-20 15:34:16.466756-05
8e8f9bd5-33ec-4cf8-aa09-5a816218f05e	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000014	Balanza de recepción descuadra 3 kg	solicitud_trabajo	ded455bf-93a0-4484-b8b2-c9f4785f173c	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.466756-05	2026-09-20 15:34:16.466756-05
663d8e73-243f-4e6e-808f-135b37fcab6a	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000015	Aire acondicionado de la sala de control no enfría	solicitud_trabajo	5accb670-c0d4-4e81-a5da-d4d9634614eb	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.475637-05	2026-09-20 15:34:16.475637-05
3876f92a-eb8d-4212-81a0-7f3cc13460c8	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000015	Aire acondicionado de la sala de control no enfría	solicitud_trabajo	5accb670-c0d4-4e81-a5da-d4d9634614eb	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.475637-05	2026-09-20 15:34:16.475637-05
5ef91857-2df2-4400-95a4-6ce143b450ee	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000016	Faja transportadora se desalinea sola	solicitud_trabajo	35a97525-51a5-4a29-bdec-97d0e29e563c	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.482433-05	2026-09-20 15:34:16.482433-05
d03c4286-bf5a-420e-a224-83dcb6188da0	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000016	Faja transportadora se desalinea sola	solicitud_trabajo	35a97525-51a5-4a29-bdec-97d0e29e563c	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.482433-05	2026-09-20 15:34:16.482433-05
7a02ad32-47e1-4a04-96db-91221fc81238	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000017	Algo suena raro en el taller	solicitud_trabajo	c4432d97-1ac8-49c5-9bb8-c072cd287501	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.490087-05	2026-09-20 15:34:16.490087-05
e6016a63-2397-4995-a9fc-db9c752eee23	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000017	Algo suena raro en el taller	solicitud_trabajo	c4432d97-1ac8-49c5-9bb8-c072cd287501	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.490087-05	2026-09-20 15:34:16.490087-05
52259d17-e29c-485b-84cf-9743bdd54b64	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_observar	Su solicitud ST-000017 fue observada	Indique en qué máquina se oye y en qué momento del turno, para poder asignar al técnico correcto.	solicitud_trabajo	c4432d97-1ac8-49c5-9bb8-c072cd287501	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.502291-05	2026-09-20 15:34:16.502291-05
93ea0df3-2439-49ae-8f3f-fc7f83d592ed	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	solicitud_nueva	Nueva solicitud ST-000018	Compra de una cafetera para la oficina	solicitud_trabajo	8cdd7cb1-4234-473c-b22d-43133e531194	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.507979-05	2026-09-20 15:34:16.507979-05
3032c50c-d0a1-426e-b2aa-54e7e3faf08a	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	solicitud_nueva	Nueva solicitud ST-000018	Compra de una cafetera para la oficina	solicitud_trabajo	8cdd7cb1-4234-473c-b22d-43133e531194	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.507979-05	2026-09-20 15:34:16.507979-05
dd62e272-8f0d-4109-8e0f-c75a5866da1b	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	solicitud_rechazar	Su solicitud ST-000018 fue rechazada	No corresponde a mantenimiento industrial; canalícelo con Administración como compra de bien de oficina.	solicitud_trabajo	8cdd7cb1-4234-473c-b22d-43133e531194	\N	interno	pendiente	\N	\N	2026-09-20 15:34:16.51712-05	2026-09-20 15:34:16.51712-05
2db18d5c-d84c-485b-ade6-9e161ddd891a	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	ot_asignada	Se le asignó la OT OT-000007	Caldera se apaga sola por las noches	orden_trabajo	f1c60e96-9925-4aa2-a68b-00a72489fd2f	f1c60e96-9925-4aa2-a68b-00a72489fd2f	interno	pendiente	\N	\N	2026-09-12 10:34:15.879017-05	2026-09-20 15:34:16.878667-05
e6ff682c-a0a3-4e7f-82d9-f0f94b20b8e3	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_aceptada	Su solicitud ST-000007 fue aceptada	Se generó la orden de trabajo OT-000007.	orden_trabajo	f1c60e96-9925-4aa2-a68b-00a72489fd2f	f1c60e96-9925-4aa2-a68b-00a72489fd2f	interno	pendiente	\N	\N	2026-09-12 10:34:15.879017-05	2026-09-20 15:34:16.878667-05
f1fa38e3-1d8f-4896-8956-ed141420ea60	5c921062-21ab-4a01-8f9a-2e2500e95893	a7ee34e2-43bd-496d-99b0-ad8013072cea	ot_asignada	Inició la ejecución de la OT OT-000008	\N	orden_trabajo	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	interno	pendiente	\N	\N	2026-09-03 14:34:15.970837-05	2026-09-20 15:34:16.878667-05
a3195e0b-c5f4-4280-9ecb-a88963d2995f	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	ot_asignada	Se le asignó la OT OT-000008	Tablero principal con olor a quemado	orden_trabajo	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	interno	pendiente	\N	\N	2026-09-03 14:34:15.93803-05	2026-09-20 15:34:16.878667-05
b547cdce-cc11-4142-8282-464346932b27	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_aceptada	Su solicitud ST-000008 fue aceptada	Se generó la orden de trabajo OT-000008.	orden_trabajo	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	interno	pendiente	\N	\N	2026-09-03 14:34:15.93803-05	2026-09-20 15:34:16.878667-05
c8af35c8-c705-49b9-92dc-d5fec431d608	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	ot_asignada	Se le asignó la OT OT-000012	Cambiar luminarias del pasillo 3	orden_trabajo	cd790d32-39ab-4aba-b33d-2dc34a03831a	cd790d32-39ab-4aba-b33d-2dc34a03831a	interno	pendiente	\N	\N	2026-08-05 08:34:16.261469-05	2026-09-20 15:34:16.878667-05
0d87ed9f-0f84-48a1-ae64-a9c5aea3752a	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_aceptada	Su solicitud ST-000010 fue aceptada	Se generó la orden de trabajo OT-000012.	orden_trabajo	cd790d32-39ab-4aba-b33d-2dc34a03831a	cd790d32-39ab-4aba-b33d-2dc34a03831a	interno	pendiente	\N	\N	2026-08-05 08:34:16.261469-05	2026-09-20 15:34:16.878667-05
3ec0a9df-3021-40af-a2da-2f36afbff3dd	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	ot_cerrada	La OT OT-000001 fue cerrada	\N	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.270008-05	2026-09-20 15:34:16.878667-05
f483b392-aa77-4aa4-b763-af78b51b857b	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	trabajo_realizado	La OT OT-000001 está declarada como trabajo realizado	Requiere su revisión para poder cerrarse.	trabajo_realizado	b02261e6-c664-4abb-bf31-fa2cf4420cce	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.13043-05	2026-09-20 15:34:16.878667-05
c9944fc5-aa6b-4003-818d-c863758ae8cb	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	mensaje_nuevo	Nuevo mensaje en la OT OT-000001	Sí, la programamos el sábado a primera hora.	mensaje	6e33754e-687c-4e19-a788-a181cab417a9	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.11424-05	2026-09-20 15:34:16.878667-05
5996fe6b-4f05-46b2-adeb-a3e5fd4649d8	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	mensaje_nuevo	Nuevo mensaje en la OT OT-000001	Sí, la programamos el sábado a primera hora.	mensaje	6e33754e-687c-4e19-a788-a181cab417a9	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.11424-05	2026-09-20 15:34:16.878667-05
a5c349ee-ee42-427c-bc5a-c83a758703c8	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	mensaje_nuevo	Nuevo mensaje en la OT OT-000001	Sí, la programamos el sábado a primera hora.	mensaje	6e33754e-687c-4e19-a788-a181cab417a9	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.11424-05	2026-09-20 15:34:16.878667-05
8c3746db-1d6d-4a23-a1b6-58567a01909e	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	mensaje_nuevo	Nuevo mensaje en la OT OT-000001	¿La prueba se puede correr el sábado para no parar la línea?	mensaje	c9d4eaf7-134a-41fa-81fe-37ad56419f5e	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.096402-05	2026-09-20 15:34:16.878667-05
a05fc227-6d23-4008-ac87-a80b7d1066eb	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	mensaje_nuevo	Nuevo mensaje en la OT OT-000001	¿La prueba se puede correr el sábado para no parar la línea?	mensaje	c9d4eaf7-134a-41fa-81fe-37ad56419f5e	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.096402-05	2026-09-20 15:34:16.878667-05
91dc3c66-20a7-4dee-aabc-967e2436faa1	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	ot_asignada	Inició la ejecución de la OT OT-000001	\N	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.044115-05	2026-09-20 15:34:16.878667-05
10bf9fd9-566f-4fda-a082-76c1fbe9e23b	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	cotizacion_cargada	Cotización cargada en la OT OT-000001	SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C. · 4850	cotizacion	8ae2a1b6-3d59-429f-abbf-8ea949d00930	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:15.024621-05	2026-09-20 15:34:16.878667-05
517d3043-b8e8-4b16-94ef-ff6f4437abb8	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	ot_asignada	Se le asignó la OT OT-000001	Compresor de planta pierde presión	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:14.977113-05	2026-09-20 15:34:16.878667-05
c9492dfc-5c7a-48f9-afcc-02718c76060d	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_aceptada	Su solicitud ST-000001 fue aceptada	Se generó la orden de trabajo OT-000001.	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	be7b33db-85f9-4955-953c-f4e24d864dcc	interno	pendiente	\N	\N	2026-08-16 08:34:14.977113-05	2026-09-20 15:34:16.878667-05
f4d93e2e-b832-434f-a2a9-a8b2b245d27e	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	ot_cerrada	La OT OT-000002 fue cerrada	\N	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	14cd082a-4bcd-4661-8837-c47c4f762342	interno	pendiente	\N	\N	2026-08-15 12:34:15.441202-05	2026-09-20 15:34:16.878667-05
aa997c43-d54a-4a1b-bacb-f6ea7da9f1c3	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	trabajo_realizado	La OT OT-000002 está declarada como trabajo realizado	Requiere su revisión para poder cerrarse.	trabajo_realizado	f5c474b7-fd66-41e9-8ef4-d907862cdd95	14cd082a-4bcd-4661-8837-c47c4f762342	interno	pendiente	\N	\N	2026-08-15 12:34:15.386203-05	2026-09-20 15:34:16.878667-05
95d2f6ef-9569-46f5-a7e6-f9707ff41343	5c921062-21ab-4a01-8f9a-2e2500e95893	a7ee34e2-43bd-496d-99b0-ad8013072cea	ot_asignada	Inició la ejecución de la OT OT-000002	\N	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	14cd082a-4bcd-4661-8837-c47c4f762342	interno	pendiente	\N	\N	2026-08-15 12:34:15.350916-05	2026-09-20 15:34:16.878667-05
87bb2612-9bb9-4346-9228-6fc2a58d1a50	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	cotizacion_cargada	Cotización cargada en la OT OT-000002	ELECTROMONTAJES ANDINOS S.R.L. · 2140	cotizacion	941e9e9a-0613-4288-a4f9-17a68d17668f	14cd082a-4bcd-4661-8837-c47c4f762342	interno	pendiente	\N	\N	2026-08-15 12:34:15.333867-05	2026-09-20 15:34:16.878667-05
fdf6a953-ac11-45b5-a198-122531780711	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	ot_asignada	Se le asignó la OT OT-000002	Puente grúa se detiene en el tramo central	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	14cd082a-4bcd-4661-8837-c47c4f762342	interno	pendiente	\N	\N	2026-08-15 12:34:15.302141-05	2026-09-20 15:34:16.878667-05
1d12ec71-04d3-459a-a15b-045aec639b20	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	solicitud_aceptada	Su solicitud ST-000002 fue aceptada	Se generó la orden de trabajo OT-000002.	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	14cd082a-4bcd-4661-8837-c47c4f762342	interno	pendiente	\N	\N	2026-08-15 12:34:15.302141-05	2026-09-20 15:34:16.878667-05
5b5ea637-5da3-4e9c-9a04-7c0b7306226c	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	mensaje_nuevo	Nuevo mensaje en la OT OT-000003	Interno: el proveedor avisó que el vástago llega con un día de retraso.	mensaje	e98a860d-4e3b-48a3-8d3b-82874f009ab0	569b23e3-2a8b-4dd7-9f5a-262524af1c93	interno	pendiente	\N	\N	2026-09-08 05:34:15.58271-05	2026-09-20 15:34:16.878667-05
e4a29758-ab7b-4004-bb12-78662d20db29	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	ot_asignada	Inició la ejecución de la OT OT-000003	\N	orden_trabajo	569b23e3-2a8b-4dd7-9f5a-262524af1c93	569b23e3-2a8b-4dd7-9f5a-262524af1c93	interno	pendiente	\N	\N	2026-09-08 05:34:15.529557-05	2026-09-20 15:34:16.878667-05
0126a041-7320-41fb-bd0f-29e8ffed74bc	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	cotizacion_cargada	Cotización cargada en la OT OT-000003	HIDRÁULICA INDUSTRIAL LIMA S.A.C. · 3290	cotizacion	8145f65b-f63d-4121-96eb-3a1e7775f9af	569b23e3-2a8b-4dd7-9f5a-262524af1c93	interno	pendiente	\N	\N	2026-09-08 05:34:15.508809-05	2026-09-20 15:34:16.878667-05
6348d760-f936-4e29-bea4-a581a8cca4b4	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	ot_asignada	Se le asignó la OT OT-000003	Fuga de aceite en la prensa hidráulica 3	orden_trabajo	569b23e3-2a8b-4dd7-9f5a-262524af1c93	569b23e3-2a8b-4dd7-9f5a-262524af1c93	interno	pendiente	\N	\N	2026-09-08 05:34:15.470721-05	2026-09-20 15:34:16.878667-05
72db2415-4998-49ec-b4d0-4fb6b236b452	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_aceptada	Su solicitud ST-000003 fue aceptada	Se generó la orden de trabajo OT-000003.	orden_trabajo	569b23e3-2a8b-4dd7-9f5a-262524af1c93	569b23e3-2a8b-4dd7-9f5a-262524af1c93	interno	pendiente	\N	\N	2026-09-08 05:34:15.470721-05	2026-09-20 15:34:16.878667-05
d12ec146-33b4-4bc1-b001-01f2cc1c5dc4	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	cotizacion_cargada	Cotización cargada en la OT OT-000006	RECTIFICACIONES DEL SUR S.A.C. · 2850	cotizacion	f9af5c86-a168-40ec-a440-0c0fc849c120	2b0e0c54-42f5-45ce-9ff5-10b069071a30	interno	pendiente	\N	\N	2026-09-13 06:34:15.853975-05	2026-09-20 15:34:16.878667-05
755319f7-5d28-4e6e-8993-7733ca74d1e3	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	ot_asignada	Se le asignó la OT OT-000006	Ruido metálico en el ventilador de extracción	orden_trabajo	2b0e0c54-42f5-45ce-9ff5-10b069071a30	2b0e0c54-42f5-45ce-9ff5-10b069071a30	interno	pendiente	\N	\N	2026-09-13 06:34:15.821136-05	2026-09-20 15:34:16.878667-05
cee5902c-2f82-4263-bedb-c5d1c7f534eb	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_aceptada	Su solicitud ST-000006 fue aceptada	Se generó la orden de trabajo OT-000006.	orden_trabajo	2b0e0c54-42f5-45ce-9ff5-10b069071a30	2b0e0c54-42f5-45ce-9ff5-10b069071a30	interno	pendiente	\N	\N	2026-09-13 06:34:15.821136-05	2026-09-20 15:34:16.878667-05
9a3fee41-3595-4b71-8d9b-caff9421fc12	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	ot_asignada	Se le asignó la OT OT-000009	Montacargas 4 sin fuerza y con falla eléctrica	orden_trabajo	c7dd4771-3654-4aff-89a5-f7661193fb03	c7dd4771-3654-4aff-89a5-f7661193fb03	interno	pendiente	\N	\N	2026-09-18 07:34:16.012792-05	2026-09-20 15:34:16.878667-05
78fad26d-8ed6-4b0d-8b66-1d39391e7b59	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	solicitud_aceptada	Su solicitud ST-000009 fue aceptada	Se generó la orden de trabajo OT-000009.	orden_trabajo	c7dd4771-3654-4aff-89a5-f7661193fb03	c7dd4771-3654-4aff-89a5-f7661193fb03	interno	pendiente	\N	\N	2026-09-18 07:34:16.012792-05	2026-09-20 15:34:16.878667-05
8c477c5b-80e5-4952-9136-a07b1ab35770	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	trabajo_realizado	La OT OT-000011 está declarada como trabajo realizado	Requiere su revisión para poder cerrarse.	trabajo_realizado	204401ea-b3e8-4e6e-a8b1-6d503b51fe4e	a9859198-0a21-4309-8a00-2ca9a2cdc917	interno	pendiente	\N	\N	2026-08-06 15:34:16.17693-05	2026-09-20 15:34:16.878667-05
1495dfba-f79d-4578-b76c-f0983f7edffc	5c921062-21ab-4a01-8f9a-2e2500e95893	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	ot_asignada	Inició la ejecución de la OT OT-000011	\N	orden_trabajo	a9859198-0a21-4309-8a00-2ca9a2cdc917	a9859198-0a21-4309-8a00-2ca9a2cdc917	interno	pendiente	\N	\N	2026-08-06 15:34:16.158376-05	2026-09-20 15:34:16.878667-05
48ac6e40-edea-4f33-93c4-0ead03fd7299	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	cotizacion_cargada	Cotización cargada en la OT OT-000011	HIDRÁULICA INDUSTRIAL LIMA S.A.C. · 1960	cotizacion	64dc018a-0a2e-45e7-913d-e1dcdf82baf9	a9859198-0a21-4309-8a00-2ca9a2cdc917	interno	pendiente	\N	\N	2026-08-06 15:34:16.140996-05	2026-09-20 15:34:16.878667-05
f970c7aa-21a2-4cc6-b590-a9a9a1fa256f	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	ot_cerrada	La OT OT-000013 fue cerrada	\N	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	interno	pendiente	\N	\N	2026-08-29 12:34:16.407424-05	2026-09-20 15:34:16.878667-05
d972a8ce-43a6-43d4-8d65-6fa36c53a134	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	trabajo_realizado	La OT OT-000013 está declarada como trabajo realizado	Requiere su revisión para poder cerrarse.	trabajo_realizado	b847fac3-a71a-4834-87b7-ffc96912e573	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	interno	pendiente	\N	\N	2026-08-29 12:34:16.372475-05	2026-09-20 15:34:16.878667-05
508bfe17-da54-469f-b2fa-14ccded98f49	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	ot_asignada	Inició la ejecución de la OT OT-000013	\N	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	interno	pendiente	\N	\N	2026-08-29 12:34:16.35434-05	2026-09-20 15:34:16.878667-05
2381f91e-8b3c-4461-b9db-f4aea6d24334	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	cotizacion_cargada	Cotización cargada en la OT OT-000013	SISTEMAS CONTRA INCENDIO S.A.C. · 980	cotizacion	c04db5da-741c-4f8c-af00-8f461a5a55f3	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	interno	pendiente	\N	\N	2026-08-29 12:34:16.336221-05	2026-09-20 15:34:16.878667-05
5fc6b3b6-527b-4c30-9b2e-9bb9093a05e1	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	ot_asignada	Se le asignó la OT OT-000013	Bomba de agua del sistema contra incendios pierde presión	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	interno	pendiente	\N	\N	2026-08-29 12:34:16.304342-05	2026-09-20 15:34:16.878667-05
c6b31533-6b38-4c5b-aef9-020c9c32a3bc	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_aceptada	Su solicitud ST-000011 fue aceptada	Se generó la orden de trabajo OT-000013.	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	interno	pendiente	\N	\N	2026-08-29 12:34:16.304342-05	2026-09-20 15:34:16.878667-05
cf7516b9-789b-437c-ba36-c55baea2b83a	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	trabajo_realizado	La OT OT-000005 está declarada como trabajo realizado	Requiere su revisión para poder cerrarse.	trabajo_realizado	7f6624ce-bf77-4289-ba48-4ca5a7a3a478	bd61bf6d-abeb-487f-91eb-3281f93643f0	interno	pendiente	\N	\N	2026-09-06 13:34:15.795487-05	2026-09-20 15:34:16.878667-05
8700fa88-129a-40c8-ad3c-5db97cffd204	5c921062-21ab-4a01-8f9a-2e2500e95893	5a11b0c5-7640-494f-9c8b-64a9a4e30673	ot_asignada	Inició la ejecución de la OT OT-000005	\N	orden_trabajo	bd61bf6d-abeb-487f-91eb-3281f93643f0	bd61bf6d-abeb-487f-91eb-3281f93643f0	interno	pendiente	\N	\N	2026-09-06 13:34:15.777671-05	2026-09-20 15:34:16.878667-05
e287f173-7ee0-48ad-ab83-dc20ef02ab39	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	cotizacion_cargada	Cotización cargada en la OT OT-000005	PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L. · 1180	cotizacion	fee02c0d-bc83-47cd-b082-7f25428e0fd3	bd61bf6d-abeb-487f-91eb-3281f93643f0	interno	pendiente	\N	\N	2026-09-06 13:34:15.759791-05	2026-09-20 15:34:16.878667-05
4a2f6b89-5e14-4e62-84cd-37a5442e38d3	5c921062-21ab-4a01-8f9a-2e2500e95893	472ed7f9-7862-406e-8075-50e2fdc26dbb	ot_asignada	Se le asignó la OT OT-000005	Portón del almacén no cierra completo	orden_trabajo	bd61bf6d-abeb-487f-91eb-3281f93643f0	bd61bf6d-abeb-487f-91eb-3281f93643f0	interno	pendiente	\N	\N	2026-09-06 13:34:15.727191-05	2026-09-20 15:34:16.878667-05
2d691f81-bbcd-47d6-97f5-e58f1556398b	5c921062-21ab-4a01-8f9a-2e2500e95893	89f7a8be-5af2-4d60-b578-9d01db2edce0	solicitud_aceptada	Su solicitud ST-000005 fue aceptada	Se generó la orden de trabajo OT-000005.	orden_trabajo	bd61bf6d-abeb-487f-91eb-3281f93643f0	bd61bf6d-abeb-487f-91eb-3281f93643f0	interno	pendiente	\N	\N	2026-09-06 13:34:15.727191-05	2026-09-20 15:34:16.878667-05
d3c0228b-7f91-4652-87cd-6091e29d6e64	5c921062-21ab-4a01-8f9a-2e2500e95893	a7ee34e2-43bd-496d-99b0-ad8013072cea	ot_asignada	Inició la ejecución de la OT OT-000004	\N	orden_trabajo	1400addf-2f07-4784-a1f6-62c95da13ef1	1400addf-2f07-4784-a1f6-62c95da13ef1	interno	pendiente	\N	\N	2026-09-07 09:34:15.663697-05	2026-09-20 15:34:16.878667-05
9c2bd6bf-ccfa-4b45-8321-dac0496e8b58	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	cotizacion_cargada	Cotización cargada en la OT OT-000004	INSTRUMENTACIÓN Y CONTROL S.A. · 7800	cotizacion	20dd8496-ea84-44bb-8740-a36c597b1147	1400addf-2f07-4784-a1f6-62c95da13ef1	interno	pendiente	\N	\N	2026-09-07 09:34:15.645482-05	2026-09-20 15:34:16.878667-05
b7943153-a175-4431-a51c-464f0fce6aba	5c921062-21ab-4a01-8f9a-2e2500e95893	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	ot_asignada	Se le asignó la OT OT-000004	Banco de pruebas sin lectura de par	orden_trabajo	1400addf-2f07-4784-a1f6-62c95da13ef1	1400addf-2f07-4784-a1f6-62c95da13ef1	interno	pendiente	\N	\N	2026-09-07 09:34:15.610587-05	2026-09-20 15:34:16.878667-05
e2243ed6-f03c-4182-a988-b01f67425388	5c921062-21ab-4a01-8f9a-2e2500e95893	f71701ef-202b-4563-9c16-10f1d41b8135	solicitud_aceptada	Su solicitud ST-000004 fue aceptada	Se generó la orden de trabajo OT-000004.	orden_trabajo	1400addf-2f07-4784-a1f6-62c95da13ef1	1400addf-2f07-4784-a1f6-62c95da13ef1	interno	pendiente	\N	\N	2026-09-07 09:34:15.610587-05	2026-09-20 15:34:16.878667-05
\.


--
-- Data for Name: orden_compra; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.orden_compra (id, tenant_id, ot_id, solped_id, numero_oc, fecha_oc, monto, moneda, observacion, anulada, motivo_anulacion, registrada_por, created_at, updated_at, created_by, updated_by) FROM stdin;
a4885b26-f263-44c9-a0c0-27a9b056d34e	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	7c3a47d5-5bb4-4a19-928e-836c0b5386f0	4500231188	\N	4850.00	PEN	\N	f	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.229154-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Data for Name: orden_trabajo; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.orden_trabajo (id, tenant_id, numero_ot, solicitud_origen_id, ot_padre_id, nivel, motivo_derivacion_id, motivo_derivacion_texto, es_bloqueante_para_padre, independizada_de_padre, sucursal_id, empresa_ruc_id, area_id, cecos_id, tipo_mantenimiento_id, tipo_trabajo_id, prioridad_tecnica, es_emergencia, emergencia_justificacion, emergencia_declarada_por, emergencia_declarada_at, regularizacion_pendiente, estado, condicion, estado_administrativo, coordinador_id, ejecutor_id, fecha_creacion, fecha_inicio_real, fecha_termino_real, fecha_cierre, motivo_cancelacion_id, cancelacion_observacion, fecha_cancelacion, veces_reabierta, created_at, updated_at, deleted_at, created_by, updated_by, trazabilidad_version, trazabilidad_dirty, trazabilidad_at, trazabilidad) FROM stdin;
bf832c74-c7c4-4cdd-a316-2a92dbbfc301	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000008	998d96e3-cb46-45ff-abf5-2f8885f40930	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	efc65d1b-8ad8-4eb2-8e49-783b09a0cff0	critica	t	Riesgo eléctrico inmediato con la planta energizada; no hay tablero de respaldo.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-03 14:34:15.93803-05	t	en_trabajo	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-03 14:34:15.93803-05	2026-09-03 14:34:15.970837-05	\N	\N	\N	\N	\N	0	2026-09-03 14:34:15.93803-05	2026-09-20 15:34:17.426698-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	5	f	2026-09-20 15:34:17.426698-05	{"ot": {"id": "bf832c74-c7c4-4cdd-a316-2a92dbbfc301", "nivel": 0, "estado": "en_trabajo", "fechas": {"cierre": null, "creacion": "2026-09-03T14:34:15.93803-05:00", "cancelacion": null, "inicio_real": "2026-09-03T14:34:15.970837-05:00", "termino_real": null}, "numero": "OT-000008", "ejecutor": "Elena Chávez Soto", "condicion": "activa", "emergencia": {"declarada_at": "2026-09-03T14:34:15.93803-05:00", "declarada_por": "Administrador MIP", "justificacion": "Riesgo eléctrico inmediato con la planta energizada; no hay tablero de respaldo.", "regularizacion_pendiente": true}, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": false, "tipo_trabajo": "Electricidad general", "es_emergencia": true, "veces_reabierta": 0, "prioridad_tecnica": "critica", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.426698-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": null, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": []}, "origen": {"ot_padre": null, "solicitud": {"id": "998d96e3-cb46-45ff-abf5-2f8885f40930", "lugar": "Subestación", "estado": "convertida_en_ot", "numero": "ST-000008", "titulo": "Tablero principal con olor a quemado", "impacto": "Parada total de la operación", "fecha_envio": "2026-09-03T14:34:15.92883-05:00", "solicitante": {"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "nombre": "Pedro Aliaga Vera"}, "impacto_comentario": null, "prioridad_percibida": "critica", "descripcion_original": "Huele a quemado en el tablero general y saltó el diferencial dos veces.", "fecha_primera_revision": "2026-09-03T14:34:15.933878-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-09-03T14:34:15.933878-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-09-03T14:34:15.93803-05:00", "motivo": null, "comentario": "Convertida en OT-000008", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 60, "actor": "Administrador MIP", "fecha": "2026-09-03T14:34:15.93803-05:00", "nuevo": {"numero": "OT-000008", "emergencia": true, "desde_solicitud": "ST-000008"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "bf832c74-c7c4-4cdd-a316-2a92dbbfc301", "entidad_tipo": "orden_trabajo"}, {"id": 61, "actor": "Elena Chávez Soto", "fecha": "2026-09-03T14:34:15.953977-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "bf832c74-c7c4-4cdd-a316-2a92dbbfc301", "entidad_tipo": "orden_trabajo"}, {"id": 62, "actor": "Elena Chávez Soto", "fecha": "2026-09-03T14:34:15.953977-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "b00067d2-e86e-4a23-adcf-13f448a9c1c0", "entidad_tipo": "diagnostico"}, {"id": 63, "actor": "Administrador MIP", "fecha": "2026-09-03T14:34:15.970837-05:00", "nuevo": {"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.970837-05:00", "sin_cotizacion": true}, "evento": "ejecucion_iniciada", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "bf832c74-c7c4-4cdd-a316-2a92dbbfc301", "entidad_tipo": "ejecucion"}, {"id": 64, "actor": "Elena Chávez Soto", "fecha": "2026-09-03T14:34:15.987933-05:00", "nuevo": {"porcentaje": null}, "evento": "avance_registrado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "853509f5-c7c6-4c6a-83a6-bf6c6bac2629", "entidad_tipo": "ot_avance"}], "adjuntos": [], "derivadas": [], "ejecucion": {"pausas": [], "avances": [{"id": "853509f5-c7c6-4c6a-83a6-bf6c6bac2629", "autor": "Elena Chávez Soto", "fecha": "2026-09-03T14:34:15.987933-05:00", "adjuntos": [], "porcentaje": null, "descripcion": "Planta desenergizada, borne reemplazado y barra reajustada a torque de catálogo."}], "incidencias": [], "inicio_real": "2026-09-03T14:34:15.970837-05:00", "responsable": "Elena Chávez Soto", "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": true}, "conversacion": {"id": "057e0ad0-6c9a-4bf4-a8c8-dad440f760da", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Pedro Aliaga Vera", "usuario_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "puede_escribir": true, "ve_notas_internas": false}, {"activo": true, "nombre": "Elena Chávez Soto", "usuario_id": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [], "diagnosticos": [{"id": "b00067d2-e86e-4a23-adcf-13f448a9c1c0", "autor": "Elena Chávez Soto", "fecha": "2026-09-03T14:34:15.953977-05:00", "alcance": "Barra principal y bornes de salida.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Borne de la barra principal flojo con marcas de arco eléctrico.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Ajuste perdido por ciclos térmicos.", "trabajo_a_realizar": "Reajustar con torquímetro, reemplazar el borne dañado y termografiar.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
f1c60e96-9925-4aa2-a68b-00a72489fd2f	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000007	e54dbab5-2c51-433d-9c19-0400620d5f99	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	3edd6fb2-8268-4204-a998-eb72ae53e077	alta	f	\N	\N	\N	f	en_diagnostico	activa	sin_solped	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	\N	2026-09-12 10:34:15.879017-05	\N	\N	\N	\N	\N	\N	0	2026-09-12 10:34:15.879017-05	2026-09-20 15:34:17.489791-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	4	f	2026-09-20 15:34:17.489791-05	{"ot": {"id": "f1c60e96-9925-4aa2-a68b-00a72489fd2f", "nivel": 0, "estado": "en_diagnostico", "fechas": {"cierre": null, "creacion": "2026-09-12T10:34:15.879017-05:00", "cancelacion": null, "inicio_real": null, "termino_real": null}, "numero": "OT-000007", "ejecutor": null, "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Julio Paredes Ramos", "es_derivada": false, "tipo_trabajo": "Sanitarias y gasfitería", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.489791-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": null, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": []}, "origen": {"ot_padre": null, "solicitud": {"id": "e54dbab5-2c51-433d-9c19-0400620d5f99", "lugar": "Casa de fuerza", "estado": "convertida_en_ot", "numero": "ST-000007", "titulo": "Caldera se apaga sola por las noches", "impacto": "Parada total de la operación", "fecha_envio": "2026-09-12T10:34:15.870973-05:00", "solicitante": {"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "nombre": "Pedro Aliaga Vera"}, "impacto_comentario": null, "prioridad_percibida": "alta", "descripcion_original": "Amanece apagada dos o tres veces por semana y hay que reencenderla manualmente.", "fecha_primera_revision": "2026-09-12T10:34:15.875058-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-09-12T10:34:15.875058-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-09-12T10:34:15.879017-05:00", "motivo": null, "comentario": "Convertida en OT-000007", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 56, "actor": "Administrador MIP", "fecha": "2026-09-12T10:34:15.879017-05:00", "nuevo": {"numero": "OT-000007", "emergencia": false, "desde_solicitud": "ST-000007"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "f1c60e96-9925-4aa2-a68b-00a72489fd2f", "entidad_tipo": "orden_trabajo"}, {"id": 57, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-12T10:34:15.894171-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "f1c60e96-9925-4aa2-a68b-00a72489fd2f", "entidad_tipo": "orden_trabajo"}, {"id": 58, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-12T10:34:15.894171-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "6c790e33-e72e-41e8-8b39-f674aee35b27", "entidad_tipo": "diagnostico"}, {"id": 59, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-12T10:34:15.912279-05:00", "nuevo": {"version": 2}, "evento": "diagnostico_reemplazado", "motivo": "El registro nocturno descartó el presostato: la presión de red cae antes del corte.", "dominio": "diagnostico", "anterior": {"version": 1}, "entidad_id": "a7d1acee-a648-4a11-97e3-449d55bfd2a5", "entidad_tipo": "diagnostico"}], "adjuntos": [], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": null, "responsable": null, "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": null, "inicio_sin_cotizacion": false}, "conversacion": {"id": "51071aab-cb16-4156-b58f-e833dca174f7", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Julio Paredes Ramos", "usuario_id": "8b99e5c2-f44f-4d1e-84e5-f658747ba01c", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Pedro Aliaga Vera", "usuario_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [], "diagnosticos": [{"id": "6c790e33-e72e-41e8-8b39-f674aee35b27", "autor": "Víctor Ramos Núñez", "fecha": "2026-09-12T10:34:15.894171-05:00", "alcance": "Lazo de control de presión.", "version": 1, "vigente": false, "adjuntos": [], "aprobado_at": null, "diagnostico": "Presostato de seguridad corta por presión baja durante la noche.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Ajuste del presostato demasiado cerca del mínimo de operación.", "trabajo_a_realizar": "Reajustar el presostato y monitorear una semana.", "lecturas_instrumentos": null}, {"id": "a7d1acee-a648-4a11-97e3-449d55bfd2a5", "autor": "Víctor Ramos Núñez", "fecha": "2026-09-12T10:34:15.912279-05:00", "alcance": "Se amplía al tren de válvulas y a la acometida de gas.", "version": 2, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "El corte lo provoca la válvula de gas, que cierra por caída de presión en la red, no el presostato.", "reemplaza_a": "6c790e33-e72e-41e8-8b39-f674aee35b27", "aprobado_por": null, "motivo_cambio": "El registro nocturno descartó el presostato: la presión de red cae antes del corte.", "observaciones": null, "causa_probable": "Caída de presión de red en horario nocturno, cuando la planta vecina consume.", "trabajo_a_realizar": "Instalar registrador de presión en la acometida y evaluar regulador de mayor capacidad.", "lecturas_instrumentos": "Presión de red 18 mbar a las 02:40 (mínimo de operación 20 mbar)"}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
2b0e0c54-42f5-45ce-9ff5-10b069071a30	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000006	6b1ecb72-330f-4e70-8e65-14b41fd94f77	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	a92169d4-06ea-4d10-b36b-d8092b14f709	media	f	\N	\N	\N	f	en_cotizacion	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	2026-09-13 06:34:15.821136-05	\N	\N	\N	\N	\N	\N	0	2026-09-13 06:34:15.821136-05	2026-09-20 15:34:17.750313-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	6	f	2026-09-20 15:34:17.750313-05	{"ot": {"id": "2b0e0c54-42f5-45ce-9ff5-10b069071a30", "nivel": 0, "estado": "en_cotizacion", "fechas": {"cierre": null, "creacion": "2026-09-13T06:34:15.821136-05:00", "cancelacion": null, "inicio_real": null, "termino_real": null}, "numero": "OT-000006", "ejecutor": null, "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": false, "tipo_trabajo": "Rodamientos y transmisión", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "media", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.750313-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": {"monto": 2850.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "41d1dc1c-9f24-4d60-aff5-8e04ebbbd82b", "fuente": "cotizacion", "moneda": "PEN", "unidad": "und", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 2.0000, "concepto": "repuesto", "proveedor": "RECTIFICACIONES DEL SUR S.A.C.", "monto_total": 2850.00, "tipo_trabajo": "Rodamientos y transmisión", "costo_unitario": 1425.0000, "texto_original": "RODAMIENTOS 6312 C3 (PAR) + BALANCEO DINAMICO ROTOR", "fecha_referencia": "2026-09-07", "descripcion_normalizada": null}]}, "origen": {"ot_padre": null, "solicitud": {"id": "6b1ecb72-330f-4e70-8e65-14b41fd94f77", "lugar": "Cabina de pintura", "estado": "convertida_en_ot", "numero": "ST-000006", "titulo": "Ruido metálico en el ventilador de extracción", "impacto": "Parada total de la operación", "fecha_envio": "2026-09-13T06:34:15.813004-05:00", "solicitante": {"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "nombre": "Pedro Aliaga Vera"}, "impacto_comentario": null, "prioridad_percibida": "media", "descripcion_original": "Se oye un golpeteo al arrancar y vibra más de lo normal.", "fecha_primera_revision": "2026-09-13T06:34:15.81737-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-09-13T06:34:15.81737-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-09-13T06:34:15.821136-05:00", "motivo": null, "comentario": "Convertida en OT-000006", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 51, "actor": "Administrador MIP", "fecha": "2026-09-13T06:34:15.821136-05:00", "nuevo": {"numero": "OT-000006", "emergencia": false, "desde_solicitud": "ST-000006"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "2b0e0c54-42f5-45ce-9ff5-10b069071a30", "entidad_tipo": "orden_trabajo"}, {"id": 52, "actor": "Marco Tuesta Ríos", "fecha": "2026-09-13T06:34:15.836675-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "2b0e0c54-42f5-45ce-9ff5-10b069071a30", "entidad_tipo": "orden_trabajo"}, {"id": 53, "actor": "Marco Tuesta Ríos", "fecha": "2026-09-13T06:34:15.836675-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "58f91adb-9c05-4eb7-8d60-ceedb7194255", "entidad_tipo": "diagnostico"}, {"id": 54, "actor": "Administrador MIP", "fecha": "2026-09-13T06:34:15.853975-05:00", "nuevo": {"estado": "en_cotizacion"}, "evento": "estado_cambiado", "motivo": "Cotización seleccionada cargada", "dominio": "ot", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "2b0e0c54-42f5-45ce-9ff5-10b069071a30", "entidad_tipo": "orden_trabajo"}, {"id": 55, "actor": "Administrador MIP", "fecha": "2026-09-13T06:34:15.853975-05:00", "nuevo": {"monto": 2850, "moneda": "PEN", "version": 1}, "evento": "cotizacion_cargada", "motivo": null, "dominio": "cotizacion", "anterior": null, "entidad_id": "f9af5c86-a168-40ec-a440-0c0fc849c120", "entidad_tipo": "cotizacion"}, {"id": 95, "actor": "Administrador MIP", "fecha": "2026-09-13T06:34:16.643365-05:00", "nuevo": {"monto": 2850, "fuente": "cotizacion", "moneda": "PEN"}, "evento": "costo_registrado", "motivo": null, "dominio": "costos", "anterior": null, "entidad_id": "41d1dc1c-9f24-4d60-aff5-8e04ebbbd82b", "entidad_tipo": "costo_unitario"}, {"id": 105, "actor": "Administrador MIP", "fecha": "2026-09-20T15:34:17.750313-05:00", "nuevo": {"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0433.pdf"}, "evento": "adjunto_cargado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "f9af5c86-a168-40ec-a440-0c0fc849c120", "entidad_tipo": "cotizacion"}], "adjuntos": [{"id": "80197891-bc09-4c2f-a953-eebf73502c96", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.750313-05:00", "estado": "vigente", "nombre": "COT-2026-0433.pdf", "tamano": 1210, "entidad_id": "f9af5c86-a168-40ec-a440-0c0fc849c120", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": null, "responsable": null, "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": null, "inicio_sin_cotizacion": false}, "conversacion": {"id": "f1d162ef-388b-47bd-9d87-1a24e5a748c7", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Pedro Aliaga Vera", "usuario_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [{"id": "f9af5c86-a168-40ec-a440-0c0fc849c120", "fecha": "2026-09-07", "monto": 2850.00, "moneda": "PEN", "numero": "COT-2026-0433", "version": 1, "vigente": true, "adjuntos": [{"id": "80197891-bc09-4c2f-a953-eebf73502c96", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.750313-05:00", "estado": "vigente", "nombre": "COT-2026-0433.pdf", "tamano": 1210}], "proveedor": "RECTIFICACIONES DEL SUR S.A.C.", "cargada_at": "2026-09-13T06:34:15.853975-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20555123451", "motivo_reemplazo": null, "plazo_ofrecido_dias": 12}], "diagnosticos": [{"id": "58f91adb-9c05-4eb7-8d60-ceedb7194255", "autor": "Marco Tuesta Ríos", "fecha": "2026-09-13T06:34:15.836675-05:00", "alcance": "Conjunto motriz del ventilador.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Rodamiento del lado libre con juego axial de 0,6 mm.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Desalineación acumulada por asentamiento de la base.", "trabajo_a_realizar": "Reemplazar rodamientos, alinear con láser y balancear el rotor.", "lecturas_instrumentos": "Vibración 7,2 mm/s · temperatura 78 °C"}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000013	9d56b79e-e16a-497a-a936-985e184807c1	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	bf147cd2-23c8-4e07-819e-a6cde044e15e	alta	f	\N	\N	\N	f	en_trabajo	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-29 12:34:16.304342-05	2026-08-29 12:34:16.35434-05	2026-08-29 12:34:16.372475-05	\N	\N	\N	\N	1	2026-08-29 12:34:16.304342-05	2026-09-20 15:34:17.581748-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	11	f	2026-09-20 15:34:17.581748-05	{"ot": {"id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "nivel": 0, "estado": "en_trabajo", "fechas": {"cierre": null, "creacion": "2026-08-29T12:34:16.304342-05:00", "cancelacion": null, "inicio_real": "2026-08-29T12:34:16.35434-05:00", "termino_real": "2026-08-29T12:34:16.372475-05:00"}, "numero": "OT-000013", "ejecutor": "Marco Tuesta Ríos", "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": false, "tipo_trabajo": "Bombas y sistemas hidráulicos", "es_emergencia": false, "veces_reabierta": 1, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.581748-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [{"id": "008864e3-0723-4b63-924b-a66243c6b139", "fecha": "2026-08-29T12:34:16.407424-05:00", "vigente": false, "secuencia": 1, "cerrado_por": "Administrador MIP", "admin_revisado": true, "observacion_pendiente": "Gasto menor imputado a caja chica; sin SOLPED.", "estado_admin_al_cierre": "sin_solped", "derivadas_bloqueantes_resueltas": true}], "reaperturas": [{"id": "3b98dccc-1961-4ef9-adb9-25d7b7097771", "fecha": "2026-08-29T12:34:16.42939-05:00", "motivo": "La presión volvió a caer a los cuatro días; la fuga no era sólo la retención.", "motivo_texto": "La presión volvió a caer a los cuatro días; la fuga no era sólo la retención.", "reabierta_por": "Administrador MIP", "estado_retorno": "en_trabajo", "cierre_revertido": "008864e3-0723-4b63-924b-a66243c6b139"}], "trabajo_realizado": [{"id": "b847fac3-a71a-4834-87b7-ffc96912e573", "version": 1, "vigente": true, "adjuntos": [], "revision": {"fecha": "2026-08-29T12:34:16.391197-05:00", "revisor": "Administrador MIP", "resultado": "aprobado", "observacion": ""}, "resultado": null, "descripcion": "Válvula limpia y resorte nuevo. Presión estable en la prueba de dos horas.", "declarado_por": "Marco Tuesta Ríos", "fecha_termino": "2026-08-29T12:34:16.372475-05:00", "observaciones": null, "conformidad_solicitante": {"fecha": null, "estado": "sin_pronunciarse", "comentario": null}}]}, "costos": {"contable": null, "cotizado": {"monto": 980.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "14537c4c-089f-4ae2-8a1d-55d0275cede5", "fuente": "cotizacion", "moneda": "PEN", "unidad": "und", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 1.0000, "concepto": "repuesto", "proveedor": "SISTEMAS CONTRA INCENDIO S.A.C.", "monto_total": 980.00, "tipo_trabajo": "Bombas y sistemas hidráulicos", "costo_unitario": 980.0000, "texto_original": "VALVULA RETENCION 4\\" BRONCE + RESORTE", "fecha_referencia": "2026-08-23", "descripcion_normalizada": null}]}, "origen": {"ot_padre": null, "solicitud": {"id": "9d56b79e-e16a-497a-a936-985e184807c1", "lugar": "Cuarto de bombas", "estado": "convertida_en_ot", "numero": "ST-000011", "titulo": "Bomba de agua del sistema contra incendios pierde presión", "impacto": "Parada total de la operación", "fecha_envio": "2026-08-29T12:34:16.293498-05:00", "solicitante": {"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "nombre": "Pedro Aliaga Vera"}, "impacto_comentario": null, "prioridad_percibida": "alta", "descripcion_original": "El manómetro del sistema baja durante la noche.", "fecha_primera_revision": "2026-08-29T12:34:16.299692-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.299692-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.304342-05:00", "motivo": null, "comentario": "Convertida en OT-000013", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 82, "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.304342-05:00", "nuevo": {"numero": "OT-000013", "emergencia": false, "desde_solicitud": "ST-000011"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "entidad_tipo": "orden_trabajo"}, {"id": 83, "actor": "Marco Tuesta Ríos", "fecha": "2026-08-29T12:34:16.320121-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "entidad_tipo": "orden_trabajo"}, {"id": 84, "actor": "Marco Tuesta Ríos", "fecha": "2026-08-29T12:34:16.320121-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "d0368a13-9b72-498c-8baa-8b92ca667a0e", "entidad_tipo": "diagnostico"}, {"id": 85, "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.336221-05:00", "nuevo": {"estado": "en_cotizacion"}, "evento": "estado_cambiado", "motivo": "Cotización seleccionada cargada", "dominio": "ot", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "entidad_tipo": "orden_trabajo"}, {"id": 86, "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.336221-05:00", "nuevo": {"monto": 980, "moneda": "PEN", "version": 1}, "evento": "cotizacion_cargada", "motivo": null, "dominio": "cotizacion", "anterior": null, "entidad_id": "c04db5da-741c-4f8c-af00-8f461a5a55f3", "entidad_tipo": "cotizacion"}, {"id": 87, "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.35434-05:00", "nuevo": {"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:16.35434-05:00", "sin_cotizacion": false}, "evento": "ejecucion_iniciada", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_cotizacion"}, "entidad_id": "32eaf0e5-c562-4bfd-b4f7-eb3716f077b3", "entidad_tipo": "ejecucion"}, {"id": 88, "actor": "Marco Tuesta Ríos", "fecha": "2026-08-29T12:34:16.372475-05:00", "nuevo": {"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:16.372475-05:00", "version": 1}, "evento": "trabajo_declarado", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_trabajo"}, "entidad_id": "b847fac3-a71a-4834-87b7-ffc96912e573", "entidad_tipo": "trabajo_realizado"}, {"id": 89, "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.391197-05:00", "nuevo": {"resultado": "aprobado"}, "evento": "trabajo_revisado", "motivo": "", "dominio": "ejecucion", "anterior": null, "entidad_id": "b847fac3-a71a-4834-87b7-ffc96912e573", "entidad_tipo": "trabajo_realizado"}, {"id": 90, "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.407424-05:00", "nuevo": {"estado": "cerrada", "con_pendiente": true, "estado_administrativo": "sin_solped"}, "evento": "ot_cerrada", "motivo": "Gasto menor imputado a caja chica; sin SOLPED.", "dominio": "ot", "anterior": {"estado": "trabajo_realizado"}, "entidad_id": "008864e3-0723-4b63-924b-a66243c6b139", "entidad_tipo": "ot_cierre"}, {"id": 91, "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.42939-05:00", "nuevo": {"estado": "en_trabajo"}, "evento": "ot_reabierta", "motivo": "La presión volvió a caer a los cuatro días; la fuga no era sólo la retención.", "dominio": "ot", "anterior": {"estado": "cerrada", "cierre_secuencia": 1}, "entidad_id": "3b98dccc-1961-4ef9-adb9-25d7b7097771", "entidad_tipo": "ot_reapertura"}, {"id": 97, "actor": "Administrador MIP", "fecha": "2026-08-29T12:34:16.69545-05:00", "nuevo": {"monto": 980, "fuente": "cotizacion", "moneda": "PEN"}, "evento": "costo_registrado", "motivo": null, "dominio": "costos", "anterior": null, "entidad_id": "14537c4c-089f-4ae2-8a1d-55d0275cede5", "entidad_tipo": "costo_unitario"}, {"id": 101, "actor": "Administrador MIP", "fecha": "2026-09-20T15:34:17.581748-05:00", "nuevo": {"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0440.pdf"}, "evento": "adjunto_cargado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "c04db5da-741c-4f8c-af00-8f461a5a55f3", "entidad_tipo": "cotizacion"}], "adjuntos": [{"id": "9c8881a2-1832-4cbe-a3c2-6557f1c470f6", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.581748-05:00", "estado": "vigente", "nombre": "COT-2026-0440.pdf", "tamano": 1208, "entidad_id": "c04db5da-741c-4f8c-af00-8f461a5a55f3", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": "2026-08-29T12:34:16.35434-05:00", "responsable": "Marco Tuesta Ríos", "termino_real": "2026-08-29T12:34:16.372475-05:00", "duracion_dias": 0.00, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": false}, "conversacion": {"id": "684c219c-8225-4c65-b585-66475e053898", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Pedro Aliaga Vera", "usuario_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "puede_escribir": true, "ve_notas_internas": false}, {"activo": true, "nombre": "Marco Tuesta Ríos", "usuario_id": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [{"id": "c04db5da-741c-4f8c-af00-8f461a5a55f3", "fecha": "2026-08-23", "monto": 980.00, "moneda": "PEN", "numero": "COT-2026-0440", "version": 1, "vigente": true, "adjuntos": [{"id": "9c8881a2-1832-4cbe-a3c2-6557f1c470f6", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.581748-05:00", "estado": "vigente", "nombre": "COT-2026-0440.pdf", "tamano": 1208}], "proveedor": "SISTEMAS CONTRA INCENDIO S.A.C.", "cargada_at": "2026-08-29T12:34:16.336221-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20601234565", "motivo_reemplazo": null, "plazo_ofrecido_dias": 3}], "diagnosticos": [{"id": "d0368a13-9b72-498c-8baa-8b92ca667a0e", "autor": "Marco Tuesta Ríos", "fecha": "2026-08-29T12:34:16.320121-05:00", "alcance": "Válvula de retención de la bomba principal.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Válvula de retención con asiento marcado; permite retorno.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Sedimento acumulado en el asiento.", "trabajo_a_realizar": "Desmontar, limpiar el asiento y reemplazar el resorte.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": "Gasto menor imputado a caja chica; sin SOLPED.", "revisado_at": "2026-09-20T15:34:16.407424-05:00", "liberaciones": [], "revisado_por": "Administrador MIP", "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
a9859198-0a21-4309-8a00-2ca9a2cdc917	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000011	\N	c7dd4771-3654-4aff-89a5-f7661193fb03	1	\N	El rectificado de la bomba va a un taller externo especializado.	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	bf147cd2-23c8-4e07-819e-a6cde044e15e	alta	f	\N	\N	\N	f	cerrada	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-08-06 15:34:16.085222-05	2026-08-06 15:34:16.158376-05	2026-08-06 15:34:16.17693-05	2026-08-06 15:34:16.210247-05	\N	\N	\N	0	2026-08-06 15:34:16.085222-05	2026-09-20 15:34:17.711979-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	10	f	2026-09-20 15:34:17.711979-05	{"ot": {"id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "nivel": 1, "estado": "cerrada", "fechas": {"cierre": "2026-08-06T15:34:16.210247-05:00", "creacion": "2026-08-06T15:34:16.085222-05:00", "cancelacion": null, "inicio_real": "2026-08-06T15:34:16.158376-05:00", "termino_real": "2026-08-06T15:34:16.17693-05:00"}, "numero": "OT-000011", "ejecutor": "Víctor Ramos Núñez", "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": true, "tipo_trabajo": "Bombas y sistemas hidráulicos", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.711979-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [{"id": "fa696e6a-92fe-4d81-8afe-121994ed030e", "fecha": "2026-08-06T15:34:16.210247-05:00", "vigente": true, "secuencia": 1, "cerrado_por": "Administrador MIP", "admin_revisado": true, "observacion_pendiente": "Sin SOLPED: el gasto se imputó al contrato marco del taller externo.", "estado_admin_al_cierre": "sin_solped", "derivadas_bloqueantes_resueltas": true}], "reaperturas": [], "trabajo_realizado": [{"id": "204401ea-b3e8-4e6e-a8b1-6d503b51fe4e", "version": 1, "vigente": true, "adjuntos": [], "revision": {"fecha": "2026-08-06T15:34:16.194661-05:00", "revisor": "Administrador MIP", "resultado": "aprobado", "observacion": ""}, "resultado": null, "descripcion": "Bomba rectificada y sellos nuevos. Presión de elevación restituida a 180 bar.", "declarado_por": "Víctor Ramos Núñez", "fecha_termino": "2026-08-06T15:34:16.17693-05:00", "observaciones": null, "conformidad_solicitante": {"fecha": null, "estado": "sin_pronunciarse", "comentario": null}}]}, "costos": {"contable": null, "cotizado": {"monto": 1960.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "1d69c883-fb44-477b-9c3f-971c74923db7", "fuente": "cotizacion", "moneda": "PEN", "unidad": "servicio", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 1.0000, "concepto": "servicio", "proveedor": "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", "monto_total": 1960.00, "tipo_trabajo": "Bombas y sistemas hidráulicos", "costo_unitario": 1960.0000, "texto_original": "RECTIFICADO BOMBA ENGRANAJES + SELLOS", "fecha_referencia": "2026-07-31", "descripcion_normalizada": null}]}, "origen": {"ot_padre": {"id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "estado": "en_diagnostico", "numero": "OT-000009", "es_bloqueante": true, "independizada": false, "motivo_derivacion": "El rectificado de la bomba va a un taller externo especializado."}, "solicitud": null, "decisiones": []}, "eventos": [{"id": 70, "actor": "Administrador MIP", "fecha": "2026-08-06T15:34:16.085222-05:00", "nuevo": {"padre": "OT-000009", "numero": "OT-000011", "bloqueante": true}, "evento": "derivada_creada", "motivo": "El rectificado de la bomba va a un taller externo especializado.", "dominio": "ot", "anterior": null, "entidad_id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "entidad_tipo": "orden_trabajo"}, {"id": 72, "actor": "Víctor Ramos Núñez", "fecha": "2026-08-06T15:34:16.122692-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "entidad_tipo": "orden_trabajo"}, {"id": 73, "actor": "Víctor Ramos Núñez", "fecha": "2026-08-06T15:34:16.122692-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "791fa998-20f5-400d-878e-5ee9b4313624", "entidad_tipo": "diagnostico"}, {"id": 74, "actor": "Administrador MIP", "fecha": "2026-08-06T15:34:16.140996-05:00", "nuevo": {"estado": "en_cotizacion"}, "evento": "estado_cambiado", "motivo": "Cotización seleccionada cargada", "dominio": "ot", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "entidad_tipo": "orden_trabajo"}, {"id": 75, "actor": "Administrador MIP", "fecha": "2026-08-06T15:34:16.140996-05:00", "nuevo": {"monto": 1960, "moneda": "PEN", "version": 1}, "evento": "cotizacion_cargada", "motivo": null, "dominio": "cotizacion", "anterior": null, "entidad_id": "64dc018a-0a2e-45e7-913d-e1dcdf82baf9", "entidad_tipo": "cotizacion"}, {"id": 76, "actor": "Administrador MIP", "fecha": "2026-08-06T15:34:16.158376-05:00", "nuevo": {"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:16.158376-05:00", "sin_cotizacion": false}, "evento": "ejecucion_iniciada", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_cotizacion"}, "entidad_id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "entidad_tipo": "ejecucion"}, {"id": 77, "actor": "Víctor Ramos Núñez", "fecha": "2026-08-06T15:34:16.17693-05:00", "nuevo": {"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:16.17693-05:00", "version": 1}, "evento": "trabajo_declarado", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_trabajo"}, "entidad_id": "204401ea-b3e8-4e6e-a8b1-6d503b51fe4e", "entidad_tipo": "trabajo_realizado"}, {"id": 78, "actor": "Administrador MIP", "fecha": "2026-08-06T15:34:16.194661-05:00", "nuevo": {"resultado": "aprobado"}, "evento": "trabajo_revisado", "motivo": "", "dominio": "ejecucion", "anterior": null, "entidad_id": "204401ea-b3e8-4e6e-a8b1-6d503b51fe4e", "entidad_tipo": "trabajo_realizado"}, {"id": 79, "actor": "Administrador MIP", "fecha": "2026-08-06T15:34:16.210247-05:00", "nuevo": {"estado": "cerrada", "con_pendiente": true, "estado_administrativo": "sin_solped"}, "evento": "ot_cerrada", "motivo": "Sin SOLPED: el gasto se imputó al contrato marco del taller externo.", "dominio": "ot", "anterior": {"estado": "trabajo_realizado"}, "entidad_id": "fa696e6a-92fe-4d81-8afe-121994ed030e", "entidad_tipo": "ot_cierre"}, {"id": 96, "actor": "Administrador MIP", "fecha": "2026-08-06T15:34:16.665161-05:00", "nuevo": {"monto": 1960, "fuente": "cotizacion", "moneda": "PEN"}, "evento": "costo_registrado", "motivo": null, "dominio": "costos", "anterior": null, "entidad_id": "1d69c883-fb44-477b-9c3f-971c74923db7", "entidad_tipo": "costo_unitario"}, {"id": 104, "actor": "Administrador MIP", "fecha": "2026-09-20T15:34:17.711979-05:00", "nuevo": {"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0436.pdf"}, "evento": "adjunto_cargado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "64dc018a-0a2e-45e7-913d-e1dcdf82baf9", "entidad_tipo": "cotizacion"}], "adjuntos": [{"id": "3a80cc87-ddaf-4abc-ba2c-62acd0543a92", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.711979-05:00", "estado": "vigente", "nombre": "COT-2026-0436.pdf", "tamano": 1212, "entidad_id": "64dc018a-0a2e-45e7-913d-e1dcdf82baf9", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": "2026-08-06T15:34:16.158376-05:00", "responsable": "Víctor Ramos Núñez", "termino_real": "2026-08-06T15:34:16.17693-05:00", "duracion_dias": 0.00, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": false}, "conversacion": {"id": "c2e7ff7d-7071-44ee-b00a-7be54b7a4805", "mensajes": [], "solo_lectura": true, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Víctor Ramos Núñez", "usuario_id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [{"id": "64dc018a-0a2e-45e7-913d-e1dcdf82baf9", "fecha": "2026-07-31", "monto": 1960.00, "moneda": "PEN", "numero": "COT-2026-0436", "version": 1, "vigente": true, "adjuntos": [{"id": "3a80cc87-ddaf-4abc-ba2c-62acd0543a92", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.711979-05:00", "estado": "vigente", "nombre": "COT-2026-0436.pdf", "tamano": 1212}], "proveedor": "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", "cargada_at": "2026-08-06T15:34:16.140996-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20456789014", "motivo_reemplazo": null, "plazo_ofrecido_dias": 8}], "diagnosticos": [{"id": "791fa998-20f5-400d-878e-5ee9b4313624", "autor": "Víctor Ramos Núñez", "fecha": "2026-08-06T15:34:16.122692-05:00", "alcance": "Bomba de elevación.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Bomba de engranajes con holgura fuera de tolerancia.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Desgaste normal por horas de servicio.", "trabajo_a_realizar": "Rectificar la bomba y reemplazar sellos.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": "Sin SOLPED: el gasto se imputó al contrato marco del taller externo.", "revisado_at": "2026-09-20T15:34:16.210247-05:00", "liberaciones": [], "revisado_por": "Administrador MIP", "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
ee9a06f5-0220-47a0-8e4a-d992333af106	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000010	\N	c7dd4771-3654-4aff-89a5-f7661193fb03	1	\N	El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación.	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	bf147cd2-23c8-4e07-819e-a6cde044e15e	alta	f	\N	\N	\N	f	creada	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	2026-09-17 11:34:16.051891-05	\N	\N	\N	\N	\N	\N	0	2026-09-17 11:34:16.051891-05	2026-09-20 15:34:17.474895-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2	f	2026-09-20 15:34:17.474895-05	{"ot": {"id": "ee9a06f5-0220-47a0-8e4a-d992333af106", "nivel": 1, "estado": "creada", "fechas": {"cierre": null, "creacion": "2026-09-17T11:34:16.051891-05:00", "cancelacion": null, "inicio_real": null, "termino_real": null}, "numero": "OT-000010", "ejecutor": null, "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": true, "tipo_trabajo": "Bombas y sistemas hidráulicos", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.474895-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": null, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": []}, "origen": {"ot_padre": {"id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "estado": "en_diagnostico", "numero": "OT-000009", "es_bloqueante": true, "independizada": false, "motivo_derivacion": "El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación."}, "solicitud": null, "decisiones": []}, "eventos": [{"id": 68, "actor": "Administrador MIP", "fecha": "2026-09-17T11:34:16.051891-05:00", "nuevo": {"padre": "OT-000009", "numero": "OT-000010", "bloqueante": true}, "evento": "derivada_creada", "motivo": "El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación.", "dominio": "ot", "anterior": null, "entidad_id": "ee9a06f5-0220-47a0-8e4a-d992333af106", "entidad_tipo": "orden_trabajo"}], "adjuntos": [], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": null, "responsable": null, "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": null, "inicio_sin_cotizacion": false}, "conversacion": {"id": "9c1c0af0-75e8-4b9d-9f24-a2d7d7f9f8f6", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}]}, "cotizaciones": [], "diagnosticos": [], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
569b23e3-2a8b-4dd7-9f5a-262524af1c93	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000003	5787000f-3be4-46c8-849b-51b922142d11	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	bf147cd2-23c8-4e07-819e-a6cde044e15e	alta	f	\N	\N	\N	f	en_trabajo	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.470721-05	2026-09-08 05:34:15.529557-05	\N	\N	\N	\N	\N	0	2026-09-08 05:34:15.470721-05	2026-09-20 15:34:17.539707-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	10	f	2026-09-20 15:34:17.539707-05	{"ot": {"id": "569b23e3-2a8b-4dd7-9f5a-262524af1c93", "nivel": 0, "estado": "en_trabajo", "fechas": {"cierre": null, "creacion": "2026-09-08T05:34:15.470721-05:00", "cancelacion": null, "inicio_real": "2026-09-08T05:34:15.529557-05:00", "termino_real": null}, "numero": "OT-000003", "ejecutor": "Víctor Ramos Núñez", "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": false, "tipo_trabajo": "Bombas y sistemas hidráulicos", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.539707-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": {"monto": 3290.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "b4822b6f-0886-49b1-b848-7010954b9f5c", "fuente": "cotizacion", "moneda": "PEN", "unidad": "juego", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 1.0000, "concepto": "repuesto", "proveedor": "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", "monto_total": 3290.00, "tipo_trabajo": "Bombas y sistemas hidráulicos", "costo_unitario": 3290.0000, "texto_original": "JUEGO DE RETENES CILINDRO 160MM + FILTRO RETORNO", "fecha_referencia": "2026-09-02", "descripcion_normalizada": null}]}, "origen": {"ot_padre": null, "solicitud": {"id": "5787000f-3be4-46c8-849b-51b922142d11", "lugar": "Nave de prensas", "estado": "convertida_en_ot", "numero": "ST-000003", "titulo": "Fuga de aceite en la prensa hidráulica 3", "impacto": "Parada total de la operación", "fecha_envio": "2026-09-08T05:34:15.460481-05:00", "solicitante": {"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "nombre": "Pedro Aliaga Vera"}, "impacto_comentario": null, "prioridad_percibida": "alta", "descripcion_original": "Hay un charco bajo la prensa al final de cada turno y el nivel del tanque baja.", "fecha_primera_revision": "2026-09-08T05:34:15.466151-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-09-08T05:34:15.466151-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-09-08T05:34:15.470721-05:00", "motivo": null, "comentario": "Convertida en OT-000003", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 28, "actor": "Administrador MIP", "fecha": "2026-09-08T05:34:15.470721-05:00", "nuevo": {"numero": "OT-000003", "emergencia": false, "desde_solicitud": "ST-000003"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "569b23e3-2a8b-4dd7-9f5a-262524af1c93", "entidad_tipo": "orden_trabajo"}, {"id": 29, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-08T05:34:15.490058-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "569b23e3-2a8b-4dd7-9f5a-262524af1c93", "entidad_tipo": "orden_trabajo"}, {"id": 30, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-08T05:34:15.490058-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "dd9a49f5-646a-4dbb-ac19-9b87263fc462", "entidad_tipo": "diagnostico"}, {"id": 31, "actor": "Administrador MIP", "fecha": "2026-09-08T05:34:15.508809-05:00", "nuevo": {"estado": "en_cotizacion"}, "evento": "estado_cambiado", "motivo": "Cotización seleccionada cargada", "dominio": "ot", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "569b23e3-2a8b-4dd7-9f5a-262524af1c93", "entidad_tipo": "orden_trabajo"}, {"id": 32, "actor": "Administrador MIP", "fecha": "2026-09-08T05:34:15.508809-05:00", "nuevo": {"monto": 3290, "moneda": "PEN", "version": 1}, "evento": "cotizacion_cargada", "motivo": null, "dominio": "cotizacion", "anterior": null, "entidad_id": "8145f65b-f63d-4121-96eb-3a1e7775f9af", "entidad_tipo": "cotizacion"}, {"id": 33, "actor": "Administrador MIP", "fecha": "2026-09-08T05:34:15.529557-05:00", "nuevo": {"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.529557-05:00", "sin_cotizacion": false}, "evento": "ejecucion_iniciada", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_cotizacion"}, "entidad_id": "569b23e3-2a8b-4dd7-9f5a-262524af1c93", "entidad_tipo": "ejecucion"}, {"id": 34, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-08T05:34:15.549013-05:00", "nuevo": {"porcentaje": null}, "evento": "avance_registrado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "59da0c27-04c6-4db4-b488-d899345240b6", "entidad_tipo": "ot_avance"}, {"id": 35, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-08T05:34:15.566039-05:00", "nuevo": {"porcentaje": null}, "evento": "avance_registrado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "710b89ee-4203-4297-a2cb-692b460048fd", "entidad_tipo": "ot_avance"}, {"id": 94, "actor": "Administrador MIP", "fecha": "2026-09-08T05:34:16.620954-05:00", "nuevo": {"monto": 3290, "fuente": "cotizacion", "moneda": "PEN"}, "evento": "costo_registrado", "motivo": null, "dominio": "costos", "anterior": null, "entidad_id": "b4822b6f-0886-49b1-b848-7010954b9f5c", "entidad_tipo": "costo_unitario"}, {"id": 100, "actor": "Administrador MIP", "fecha": "2026-09-20T15:34:17.539707-05:00", "nuevo": {"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0421.pdf"}, "evento": "adjunto_cargado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "8145f65b-f63d-4121-96eb-3a1e7775f9af", "entidad_tipo": "cotizacion"}], "adjuntos": [{"id": "671a9f4d-225c-43bd-ba23-ea935891e30a", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.539707-05:00", "estado": "vigente", "nombre": "COT-2026-0421.pdf", "tamano": 1213, "entidad_id": "8145f65b-f63d-4121-96eb-3a1e7775f9af", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [], "avances": [{"id": "59da0c27-04c6-4db4-b488-d899345240b6", "autor": "Víctor Ramos Núñez", "fecha": "2026-09-08T05:34:15.549013-05:00", "adjuntos": [], "porcentaje": null, "descripcion": "Cilindro desmontado y enviado al taller de rectificado."}, {"id": "710b89ee-4203-4297-a2cb-692b460048fd", "autor": "Víctor Ramos Núñez", "fecha": "2026-09-08T05:34:15.566039-05:00", "adjuntos": [], "porcentaje": null, "descripcion": "Retenes nuevos recibidos; se monta mañana a primera hora."}], "incidencias": [], "inicio_real": "2026-09-08T05:34:15.529557-05:00", "responsable": "Víctor Ramos Núñez", "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": false}, "conversacion": {"id": "babef1d8-c6d5-401f-926b-862a8eac59c6", "mensajes": [{"id": "e98a860d-4e3b-48a3-8d3b-82874f009ab0", "tipo": "humano", "autor": "Administrador MIP", "fecha": "2026-09-08T05:34:15.58271-05:00", "cuerpo": "Interno: el proveedor avisó que el vástago llega con un día de retraso.", "estado": "publicado", "editado": false, "adjuntos": [], "retirado": false, "responde_a": null, "visibilidad": "interna"}], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Pedro Aliaga Vera", "usuario_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "puede_escribir": true, "ve_notas_internas": false}, {"activo": true, "nombre": "Víctor Ramos Núñez", "usuario_id": "0a2b7719-37d2-44fa-84d2-6004c3a7b9df", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [{"id": "8145f65b-f63d-4121-96eb-3a1e7775f9af", "fecha": "2026-09-02", "monto": 3290.00, "moneda": "PEN", "numero": "COT-2026-0421", "version": 1, "vigente": true, "adjuntos": [{"id": "671a9f4d-225c-43bd-ba23-ea935891e30a", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.539707-05:00", "estado": "vigente", "nombre": "COT-2026-0421.pdf", "tamano": 1213}], "proveedor": "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", "cargada_at": "2026-09-08T05:34:15.508809-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20456789014", "motivo_reemplazo": null, "plazo_ofrecido_dias": 10}], "diagnosticos": [{"id": "dd9a49f5-646a-4dbb-ac19-9b87263fc462", "autor": "Víctor Ramos Núñez", "fecha": "2026-09-08T05:34:15.490058-05:00", "alcance": "Cilindro principal y filtro de retorno.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Retén del cilindro principal vencido; pérdida continua por el vástago.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Desgaste por horas de servicio y partículas en el aceite.", "trabajo_a_realizar": "Reemplazar retenes, cambiar filtro y reponer aceite.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
be7b33db-85f9-4955-953c-f4e24d864dcc	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000001	c5d4a2a9-9988-4d7a-ad76-555e3020bafe	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	743ce9a9-33cc-4c22-b6de-b0bd15bdfa61	alta	f	\N	\N	\N	f	cerrada	activa	administracion_completa	472ed7f9-7862-406e-8075-50e2fdc26dbb	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:14.977113-05	2026-08-16 08:34:15.044115-05	2026-08-16 08:34:15.13043-05	2026-08-16 08:34:15.270008-05	\N	\N	\N	0	2026-08-16 08:34:14.977113-05	2026-09-20 15:34:17.622807-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	19	f	2026-09-20 15:34:17.622807-05	{"ot": {"id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "nivel": 0, "estado": "cerrada", "fechas": {"cierre": "2026-08-16T08:34:15.270008-05:00", "creacion": "2026-08-16T08:34:14.977113-05:00", "cancelacion": null, "inicio_real": "2026-08-16T08:34:15.044115-05:00", "termino_real": "2026-08-16T08:34:15.13043-05:00"}, "numero": "OT-000001", "ejecutor": "Marco Tuesta Ríos", "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": false, "tipo_trabajo": "Neumática", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "administracion_completa", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.622807-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [{"id": "3d37a873-d668-49eb-8227-2899d96f0d5b", "fecha": "2026-08-16T08:34:15.270008-05:00", "vigente": true, "secuencia": 1, "cerrado_por": "Administrador MIP", "admin_revisado": false, "observacion_pendiente": null, "estado_admin_al_cierre": "administracion_completa", "derivadas_bloqueantes_resueltas": true}], "reaperturas": [], "trabajo_realizado": [{"id": "b02261e6-c664-4abb-bf31-fa2cf4420cce", "version": 1, "vigente": true, "adjuntos": [], "revision": {"fecha": "2026-08-16T08:34:15.151084-05:00", "revisor": "Administrador MIP", "resultado": "aprobado", "observacion": ""}, "resultado": null, "descripcion": "Kit de válvulas y anillos reemplazados. Cuatro horas de prueba sostenidas a 8,1 bar y 71 °C.", "declarado_por": "Marco Tuesta Ríos", "fecha_termino": "2026-08-16T08:34:15.13043-05:00", "observaciones": null, "conformidad_solicitante": {"fecha": null, "estado": "sin_pronunciarse", "comentario": null}}]}, "costos": {"contable": null, "cotizado": {"monto": 4850.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 4850.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "f5d74e1b-a79b-4814-98fd-00a5c1c246c7", "fuente": "cotizacion", "moneda": "PEN", "unidad": "kit", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 1.0000, "concepto": "repuesto", "proveedor": "SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C.", "monto_total": 4850.00, "tipo_trabajo": "Neumática", "costo_unitario": 4850.0000, "texto_original": "KIT VALVULAS 2DA ETAPA COMPRESOR ATLAS GA75 + MANO DE OBRA", "fecha_referencia": "2026-08-10", "descripcion_normalizada": null}]}, "origen": {"ot_padre": null, "solicitud": {"id": "c5d4a2a9-9988-4d7a-ad76-555e3020bafe", "lugar": "Sala de compresores, nivel 1", "estado": "convertida_en_ot", "numero": "ST-000001", "titulo": "Compresor de planta pierde presión", "impacto": "Parada total de la operación", "fecha_envio": "2026-08-16T08:34:14.965094-05:00", "solicitante": {"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "nombre": "Pedro Aliaga Vera"}, "impacto_comentario": null, "prioridad_percibida": "alta", "descripcion_original": "Desde el martes el compresor no mantiene los 8 bar y la línea de pintura se queda sin aire a media jornada.", "fecha_primera_revision": "2026-08-16T08:34:14.972338-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:14.972338-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:14.977113-05:00", "motivo": null, "comentario": "Convertida en OT-000001", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 1, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:14.977113-05:00", "nuevo": {"numero": "OT-000001", "emergencia": false, "desde_solicitud": "ST-000001"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "entidad_tipo": "orden_trabajo"}, {"id": 2, "actor": "Marco Tuesta Ríos", "fecha": "2026-08-16T08:34:15.003489-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "entidad_tipo": "orden_trabajo"}, {"id": 3, "actor": "Marco Tuesta Ríos", "fecha": "2026-08-16T08:34:15.003489-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "6aaf55e9-be62-46ac-a9bb-9689b116d49f", "entidad_tipo": "diagnostico"}, {"id": 4, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.024621-05:00", "nuevo": {"estado": "en_cotizacion"}, "evento": "estado_cambiado", "motivo": "Cotización seleccionada cargada", "dominio": "ot", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "entidad_tipo": "orden_trabajo"}, {"id": 5, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.024621-05:00", "nuevo": {"monto": 4850, "moneda": "PEN", "version": 1}, "evento": "cotizacion_cargada", "motivo": null, "dominio": "cotizacion", "anterior": null, "entidad_id": "8ae2a1b6-3d59-429f-abbf-8ea949d00930", "entidad_tipo": "cotizacion"}, {"id": 6, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.044115-05:00", "nuevo": {"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.044115-05:00", "sin_cotizacion": false}, "evento": "ejecucion_iniciada", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_cotizacion"}, "entidad_id": "be7b33db-85f9-4955-953c-f4e24d864dcc", "entidad_tipo": "ejecucion"}, {"id": 7, "actor": "Marco Tuesta Ríos", "fecha": "2026-08-16T08:34:15.063196-05:00", "nuevo": {"porcentaje": null}, "evento": "avance_registrado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "97179a5b-66d0-4ded-bd2c-03374705e928", "entidad_tipo": "ot_avance"}, {"id": 8, "actor": "Marco Tuesta Ríos", "fecha": "2026-08-16T08:34:15.079298-05:00", "nuevo": {"porcentaje": null}, "evento": "avance_registrado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "6b424a1f-b2f0-4db2-9a11-fa76a416afae", "entidad_tipo": "ot_avance"}, {"id": 9, "actor": "Marco Tuesta Ríos", "fecha": "2026-08-16T08:34:15.13043-05:00", "nuevo": {"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:15.13043-05:00", "version": 1}, "evento": "trabajo_declarado", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_trabajo"}, "entidad_id": "b02261e6-c664-4abb-bf31-fa2cf4420cce", "entidad_tipo": "trabajo_realizado"}, {"id": 10, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.151084-05:00", "nuevo": {"resultado": "aprobado"}, "evento": "trabajo_revisado", "motivo": "", "dominio": "ejecucion", "anterior": null, "entidad_id": "b02261e6-c664-4abb-bf31-fa2cf4420cce", "entidad_tipo": "trabajo_realizado"}, {"id": 11, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.168676-05:00", "nuevo": {"version": 1, "numero_interno": "OT-000001-SP1"}, "evento": "solped_preparada", "motivo": null, "dominio": "administracion", "anterior": null, "entidad_id": "7c3a47d5-5bb4-4a19-928e-836c0b5386f0", "entidad_tipo": "solped"}, {"id": 12, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.193085-05:00", "nuevo": {"estado": "lista_para_enviar"}, "evento": "solped_lista", "motivo": null, "dominio": "administracion", "anterior": {"estado": "borrador"}, "entidad_id": "7c3a47d5-5bb4-4a19-928e-836c0b5386f0", "entidad_tipo": "solped"}, {"id": 13, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.209901-05:00", "nuevo": {"estado": "creada_en_sap", "numero_sap": "0010045612"}, "evento": "solped_numero_sap", "motivo": null, "dominio": "administracion", "anterior": {"estado": "lista_para_enviar", "numero_sap": null}, "entidad_id": "7c3a47d5-5bb4-4a19-928e-836c0b5386f0", "entidad_tipo": "solped"}, {"id": 14, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.229154-05:00", "nuevo": {"monto": 4850, "numero_oc": "4500231188"}, "evento": "oc_registrada", "motivo": null, "dominio": "administracion", "anterior": null, "entidad_id": "a4885b26-f263-44c9-a0c0-27a9b056d34e", "entidad_tipo": "orden_compra"}, {"id": 15, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.249641-05:00", "nuevo": {"monto": 4850, "estado": "total"}, "evento": "liberacion_actualizada", "motivo": null, "dominio": "administracion", "anterior": {"monto": null, "estado": null}, "entidad_id": "324d4ae5-914e-4861-b5df-ed126865bd64", "entidad_tipo": "liberacion_historial"}, {"id": 16, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.270008-05:00", "nuevo": {"estado": "cerrada", "con_pendiente": false, "estado_administrativo": "administracion_completa"}, "evento": "ot_cerrada", "motivo": null, "dominio": "ot", "anterior": {"estado": "trabajo_realizado"}, "entidad_id": "3d37a873-d668-49eb-8227-2899d96f0d5b", "entidad_tipo": "ot_cierre"}, {"id": 92, "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:16.568911-05:00", "nuevo": {"monto": 4850, "fuente": "cotizacion", "moneda": "PEN"}, "evento": "costo_registrado", "motivo": null, "dominio": "costos", "anterior": null, "entidad_id": "f5d74e1b-a79b-4814-98fd-00a5c1c246c7", "entidad_tipo": "costo_unitario"}, {"id": 102, "actor": "Administrador MIP", "fecha": "2026-09-20T15:34:17.622807-05:00", "nuevo": {"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0412.pdf"}, "evento": "adjunto_cargado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "8ae2a1b6-3d59-429f-abbf-8ea949d00930", "entidad_tipo": "cotizacion"}], "adjuntos": [{"id": "14994e97-afac-479a-a613-bd8476af4c1b", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.622807-05:00", "estado": "vigente", "nombre": "COT-2026-0412.pdf", "tamano": 1217, "entidad_id": "8ae2a1b6-3d59-429f-abbf-8ea949d00930", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [], "avances": [{"id": "97179a5b-66d0-4ded-bd2c-03374705e928", "autor": "Marco Tuesta Ríos", "fecha": "2026-08-16T08:34:15.063196-05:00", "adjuntos": [], "porcentaje": null, "descripcion": "Compresor desmontado y kit de válvulas recibido del proveedor."}, {"id": "6b424a1f-b2f0-4db2-9a11-fa76a416afae", "autor": "Marco Tuesta Ríos", "fecha": "2026-08-16T08:34:15.079298-05:00", "adjuntos": [], "porcentaje": null, "descripcion": "Anillos reemplazados y aceite cambiado. Pendiente la prueba de cuatro horas."}], "incidencias": [], "inicio_real": "2026-08-16T08:34:15.044115-05:00", "responsable": "Marco Tuesta Ríos", "termino_real": "2026-08-16T08:34:15.13043-05:00", "duracion_dias": 0.00, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": false}, "conversacion": {"id": "937caaac-9d82-403d-aa79-e13de2111568", "mensajes": [{"id": "c9d4eaf7-134a-41fa-81fe-37ad56419f5e", "tipo": "humano", "autor": "Pedro Aliaga Vera", "fecha": "2026-08-16T08:34:15.096402-05:00", "cuerpo": "¿La prueba se puede correr el sábado para no parar la línea?", "estado": "publicado", "editado": false, "adjuntos": [], "retirado": false, "responde_a": null, "visibilidad": "canal"}, {"id": "6e33754e-687c-4e19-a788-a181cab417a9", "tipo": "humano", "autor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.11424-05:00", "cuerpo": "Sí, la programamos el sábado a primera hora.", "estado": "publicado", "editado": false, "adjuntos": [], "retirado": false, "responde_a": null, "visibilidad": "canal"}], "solo_lectura": true, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Pedro Aliaga Vera", "usuario_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "puede_escribir": true, "ve_notas_internas": false}, {"activo": true, "nombre": "Marco Tuesta Ríos", "usuario_id": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [{"id": "8ae2a1b6-3d59-429f-abbf-8ea949d00930", "fecha": "2026-08-10", "monto": 4850.00, "moneda": "PEN", "numero": "COT-2026-0412", "version": 1, "vigente": true, "adjuntos": [{"id": "14994e97-afac-479a-a613-bd8476af4c1b", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.622807-05:00", "estado": "vigente", "nombre": "COT-2026-0412.pdf", "tamano": 1217}], "proveedor": "SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C.", "cargada_at": "2026-08-16T08:34:15.024621-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": "Incluye kit original, mano de obra y puesta en marcha.", "proveedor_ruc": "20512345671", "motivo_reemplazo": null, "plazo_ofrecido_dias": 7}], "diagnosticos": [{"id": "6aaf55e9-be62-46ac-a9bb-9689b116d49f", "autor": "Marco Tuesta Ríos", "fecha": "2026-08-16T08:34:15.003489-05:00", "alcance": "Segunda etapa del compresor; el motor eléctrico queda fuera.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Válvula de admisión de la segunda etapa con fuga y anillos desgastados.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Horas de servicio por encima del plan de mantenimiento.", "trabajo_a_realizar": "Reemplazar kit de válvulas y anillos, cambiar aceite y probar cuatro horas.", "lecturas_instrumentos": "Presión 5,8 bar · temperatura de descarga 96 °C"}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [{"id": "a4885b26-f263-44c9-a0c0-27a9b056d34e", "fecha": null, "monto": 4850.00, "moneda": "PEN", "numero": "4500231188", "anulada": false, "solped_id": "7c3a47d5-5bb4-4a19-928e-836c0b5386f0", "observacion": null, "registrada_at": "2026-08-16T08:34:15.229154-05:00", "registrada_por": "Administrador MIP"}], "moneda": "PEN", "solped": [{"id": "7c3a47d5-5bb4-4a19-928e-836c0b5386f0", "fecha": "2026-08-15", "monto": 4850.00, "moneda": "PEN", "anulada": false, "version": 1, "vigente": true, "intentos": 0, "creada_at": "2026-08-16T08:34:15.168676-05:00", "formulario": {}, "numero_sap": "0010045612", "mensaje_sap": null, "reemplaza_a": null, "cotizacion_id": "8ae2a1b6-3d59-429f-abbf-8ea949d00930", "numero_interno": "OT-000001-SP1", "motivo_anulacion": null, "estado_integracion": "creada_en_sap", "referencia_externa": "OT-000001-1-c648b37a"}], "observacion": null, "revisado_at": null, "liberaciones": [{"id": "324d4ae5-914e-4861-b5df-ed126865bd64", "actor": "Administrador MIP", "fecha": "2026-08-16T08:34:15.249641-05:00", "moneda": "PEN", "secuencia": 1, "monto_nuevo": 4850.00, "observacion": null, "estado_nuevo": "total", "monto_anterior": null, "estado_anterior": null}], "revisado_por": null, "estado_consolidado": "administracion_completa", "monto_liberado_total": 4850.00}}
14cd082a-4bcd-4661-8837-c47c4f762342	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000002	99d4f059-ece9-4360-9490-c612a98ede66	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	70d72bcc-44dd-4383-add9-d2e21e9c0477	alta	f	\N	\N	\N	f	cerrada	activa	solped_pendiente	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.302141-05	2026-08-15 12:34:15.350916-05	2026-08-15 12:34:15.386203-05	2026-08-15 12:34:15.441202-05	\N	\N	\N	0	2026-08-15 12:34:15.302141-05	2026-09-20 15:34:17.673677-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	12	f	2026-09-20 15:34:17.673677-05	{"ot": {"id": "14cd082a-4bcd-4661-8837-c47c4f762342", "nivel": 0, "estado": "cerrada", "fechas": {"cierre": "2026-08-15T12:34:15.441202-05:00", "creacion": "2026-08-15T12:34:15.302141-05:00", "cancelacion": null, "inicio_real": "2026-08-15T12:34:15.350916-05:00", "termino_real": "2026-08-15T12:34:15.386203-05:00"}, "numero": "OT-000002", "ejecutor": "Elena Chávez Soto", "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Julio Paredes Ramos", "es_derivada": false, "tipo_trabajo": "Tableros y control", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "solped_pendiente", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.673677-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [{"id": "8dbee6e1-1ded-47bc-a602-bc993c5f6482", "fecha": "2026-08-15T12:34:15.441202-05:00", "vigente": true, "secuencia": 1, "cerrado_por": "Administrador MIP", "admin_revisado": true, "observacion_pendiente": "Compras emite la OC la próxima semana; el equipo ya está operativo.", "estado_admin_al_cierre": "solped_pendiente", "derivadas_bloqueantes_resueltas": true}], "reaperturas": [], "trabajo_realizado": [{"id": "f5c474b7-fd66-41e9-8ef4-d907862cdd95", "version": 1, "vigente": true, "adjuntos": [], "revision": {"fecha": "2026-08-15T12:34:15.405957-05:00", "revisor": "Administrador MIP", "resultado": "aprobado", "observacion": ""}, "resultado": null, "descripcion": "Contactor nuevo instalado. Diez ciclos de prueba con carga nominal sin cortes.", "declarado_por": "Elena Chávez Soto", "fecha_termino": "2026-08-15T12:34:15.386203-05:00", "observaciones": null, "conformidad_solicitante": {"fecha": null, "estado": "sin_pronunciarse", "comentario": null}}]}, "costos": {"contable": null, "cotizado": {"monto": 2140.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "bb557a13-f183-4ac1-9125-fb9611f609d3", "fuente": "cotizacion", "moneda": "PEN", "unidad": "und", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 2.0000, "concepto": "repuesto", "proveedor": "ELECTROMONTAJES ANDINOS S.R.L.", "monto_total": 2140.00, "tipo_trabajo": "Tableros y control", "costo_unitario": 1070.0000, "texto_original": "CONTACTOR LC1D80 + RELE TERMICO LRD35 INSTALADO", "fecha_referencia": "2026-08-09", "descripcion_normalizada": null}]}, "origen": {"ot_padre": null, "solicitud": {"id": "99d4f059-ece9-4360-9490-c612a98ede66", "lugar": "Taller 2", "estado": "convertida_en_ot", "numero": "ST-000002", "titulo": "Puente grúa se detiene en el tramo central", "impacto": "Parada total de la operación", "fecha_envio": "2026-08-15T12:34:15.292016-05:00", "solicitante": {"id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "nombre": "Nancy Ortiz Huamán"}, "impacto_comentario": null, "prioridad_percibida": "alta", "descripcion_original": "El puente grúa del taller 2 se corta a media carrera y hay que reiniciarlo desde el tablero.", "fecha_primera_revision": "2026-08-15T12:34:15.297393-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.297393-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.302141-05:00", "motivo": null, "comentario": "Convertida en OT-000002", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 17, "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.302141-05:00", "nuevo": {"numero": "OT-000002", "emergencia": false, "desde_solicitud": "ST-000002"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "14cd082a-4bcd-4661-8837-c47c4f762342", "entidad_tipo": "orden_trabajo"}, {"id": 18, "actor": "Elena Chávez Soto", "fecha": "2026-08-15T12:34:15.317312-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "14cd082a-4bcd-4661-8837-c47c4f762342", "entidad_tipo": "orden_trabajo"}, {"id": 19, "actor": "Elena Chávez Soto", "fecha": "2026-08-15T12:34:15.317312-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "0d9044ca-0479-4db1-b404-af45ca79d91d", "entidad_tipo": "diagnostico"}, {"id": 20, "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.333867-05:00", "nuevo": {"estado": "en_cotizacion"}, "evento": "estado_cambiado", "motivo": "Cotización seleccionada cargada", "dominio": "ot", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "14cd082a-4bcd-4661-8837-c47c4f762342", "entidad_tipo": "orden_trabajo"}, {"id": 21, "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.333867-05:00", "nuevo": {"monto": 2140, "moneda": "PEN", "version": 1}, "evento": "cotizacion_cargada", "motivo": null, "dominio": "cotizacion", "anterior": null, "entidad_id": "941e9e9a-0613-4288-a4f9-17a68d17668f", "entidad_tipo": "cotizacion"}, {"id": 22, "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.350916-05:00", "nuevo": {"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.350916-05:00", "sin_cotizacion": false}, "evento": "ejecucion_iniciada", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_cotizacion"}, "entidad_id": "14cd082a-4bcd-4661-8837-c47c4f762342", "entidad_tipo": "ejecucion"}, {"id": 23, "actor": "Elena Chávez Soto", "fecha": "2026-08-15T12:34:15.370424-05:00", "nuevo": {"porcentaje": null}, "evento": "avance_registrado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "9032c5b9-7fa3-4221-847d-26ec63f47b93", "entidad_tipo": "ot_avance"}, {"id": 24, "actor": "Elena Chávez Soto", "fecha": "2026-08-15T12:34:15.386203-05:00", "nuevo": {"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:15.386203-05:00", "version": 1}, "evento": "trabajo_declarado", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_trabajo"}, "entidad_id": "f5c474b7-fd66-41e9-8ef4-d907862cdd95", "entidad_tipo": "trabajo_realizado"}, {"id": 25, "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.405957-05:00", "nuevo": {"resultado": "aprobado"}, "evento": "trabajo_revisado", "motivo": "", "dominio": "ejecucion", "anterior": null, "entidad_id": "f5c474b7-fd66-41e9-8ef4-d907862cdd95", "entidad_tipo": "trabajo_realizado"}, {"id": 26, "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.422972-05:00", "nuevo": {"version": 1, "numero_interno": "OT-000002-SP1"}, "evento": "solped_preparada", "motivo": null, "dominio": "administracion", "anterior": null, "entidad_id": "ca6be66a-aa2f-4744-b6b3-77e1d9a58429", "entidad_tipo": "solped"}, {"id": 27, "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:15.441202-05:00", "nuevo": {"estado": "cerrada", "con_pendiente": true, "estado_administrativo": "solped_pendiente"}, "evento": "ot_cerrada", "motivo": "Compras emite la OC la próxima semana; el equipo ya está operativo.", "dominio": "ot", "anterior": {"estado": "trabajo_realizado"}, "entidad_id": "8dbee6e1-1ded-47bc-a602-bc993c5f6482", "entidad_tipo": "ot_cierre"}, {"id": 93, "actor": "Administrador MIP", "fecha": "2026-08-15T12:34:16.595734-05:00", "nuevo": {"monto": 2140, "fuente": "cotizacion", "moneda": "PEN"}, "evento": "costo_registrado", "motivo": null, "dominio": "costos", "anterior": null, "entidad_id": "bb557a13-f183-4ac1-9125-fb9611f609d3", "entidad_tipo": "costo_unitario"}, {"id": 103, "actor": "Administrador MIP", "fecha": "2026-09-20T15:34:17.673677-05:00", "nuevo": {"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0418.pdf"}, "evento": "adjunto_cargado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "941e9e9a-0613-4288-a4f9-17a68d17668f", "entidad_tipo": "cotizacion"}], "adjuntos": [{"id": "7f245e2f-dc09-4d57-b225-d8e8eb4d3bf8", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.673677-05:00", "estado": "vigente", "nombre": "COT-2026-0418.pdf", "tamano": 1209, "entidad_id": "941e9e9a-0613-4288-a4f9-17a68d17668f", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [], "avances": [{"id": "9032c5b9-7fa3-4221-847d-26ec63f47b93", "autor": "Elena Chávez Soto", "fecha": "2026-08-15T12:34:15.370424-05:00", "adjuntos": [], "porcentaje": null, "descripcion": "Contactor reemplazado y térmico recalibrado a 24 A."}], "incidencias": [], "inicio_real": "2026-08-15T12:34:15.350916-05:00", "responsable": "Elena Chávez Soto", "termino_real": "2026-08-15T12:34:15.386203-05:00", "duracion_dias": 0.00, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": false}, "conversacion": {"id": "c4ff63e6-8d8d-489f-8e57-42ad44caca38", "mensajes": [], "solo_lectura": true, "participantes": [{"activo": true, "nombre": "Nancy Ortiz Huamán", "usuario_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "puede_escribir": true, "ve_notas_internas": false}, {"activo": true, "nombre": "Julio Paredes Ramos", "usuario_id": "8b99e5c2-f44f-4d1e-84e5-f658747ba01c", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Elena Chávez Soto", "usuario_id": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [{"id": "941e9e9a-0613-4288-a4f9-17a68d17668f", "fecha": "2026-08-09", "monto": 2140.00, "moneda": "PEN", "numero": "COT-2026-0418", "version": 1, "vigente": true, "adjuntos": [{"id": "7f245e2f-dc09-4d57-b225-d8e8eb4d3bf8", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.673677-05:00", "estado": "vigente", "nombre": "COT-2026-0418.pdf", "tamano": 1209}], "proveedor": "ELECTROMONTAJES ANDINOS S.R.L.", "cargada_at": "2026-08-15T12:34:15.333867-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20487654320", "motivo_reemplazo": null, "plazo_ofrecido_dias": 5}], "diagnosticos": [{"id": "0d9044ca-0479-4db1-b404-af45ca79d91d", "autor": "Elena Chávez Soto", "fecha": "2026-08-15T12:34:15.317312-05:00", "alcance": "Tablero del carro principal.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Contactor del carro principal con carbonización en los contactos.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Arranques repetidos con carga máxima.", "trabajo_a_realizar": "Reemplazar contactor y revisar el ajuste del relé térmico.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [{"id": "ca6be66a-aa2f-4744-b6b3-77e1d9a58429", "fecha": "2026-08-14", "monto": 2140.00, "moneda": "PEN", "anulada": false, "version": 1, "vigente": true, "intentos": 0, "creada_at": "2026-08-15T12:34:15.422972-05:00", "formulario": {}, "numero_sap": null, "mensaje_sap": null, "reemplaza_a": null, "cotizacion_id": "941e9e9a-0613-4288-a4f9-17a68d17668f", "numero_interno": "OT-000002-SP1", "motivo_anulacion": null, "estado_integracion": "borrador", "referencia_externa": "OT-000002-1-3dd0e535"}], "observacion": "Compras emite la OC la próxima semana; el equipo ya está operativo.", "revisado_at": "2026-09-20T15:34:15.441202-05:00", "liberaciones": [], "revisado_por": "Administrador MIP", "estado_consolidado": "solped_pendiente", "monto_liberado_total": 0.00}}
1400addf-2f07-4784-a1f6-62c95da13ef1	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000004	0c01b409-e417-4a5b-baad-acba87bbf851	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	1eed878f-1909-4f26-81c5-e8a85a527e9f	media	f	\N	\N	\N	f	en_trabajo	pausada	sin_solped	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-07 09:34:15.610587-05	2026-09-07 09:34:15.663697-05	\N	\N	\N	\N	\N	0	2026-09-07 09:34:15.610587-05	2026-09-20 15:34:17.788369-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	9	f	2026-09-20 15:34:17.788369-05	{"ot": {"id": "1400addf-2f07-4784-a1f6-62c95da13ef1", "nivel": 0, "estado": "en_trabajo", "fechas": {"cierre": null, "creacion": "2026-09-07T09:34:15.610587-05:00", "cancelacion": null, "inicio_real": "2026-09-07T09:34:15.663697-05:00", "termino_real": null}, "numero": "OT-000004", "ejecutor": "Elena Chávez Soto", "condicion": "pausada", "emergencia": null, "cancelacion": null, "coordinador": "Julio Paredes Ramos", "es_derivada": false, "tipo_trabajo": "Instrumentación", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "media", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.788369-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": {"monto": 7800.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "beea5c0c-b75b-4c50-b8d1-8c9b3f6ed775", "fuente": "cotizacion", "moneda": "PEN", "unidad": "und", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 1.0000, "concepto": "repuesto", "proveedor": "INSTRUMENTACIÓN Y CONTROL S.A.", "monto_total": 7800.00, "tipo_trabajo": "Instrumentación", "costo_unitario": 7800.0000, "texto_original": "CELDA DE CARGA 5KN CON CERTIFICADO DE CALIBRACION", "fecha_referencia": "2026-09-01", "descripcion_normalizada": null}]}, "origen": {"ot_padre": null, "solicitud": {"id": "0c01b409-e417-4a5b-baad-acba87bbf851", "lugar": "Laboratorio de pruebas", "estado": "convertida_en_ot", "numero": "ST-000004", "titulo": "Banco de pruebas sin lectura de par", "impacto": "Parada total de la operación", "fecha_envio": "2026-09-07T09:34:15.599742-05:00", "solicitante": {"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "nombre": "Pedro Aliaga Vera"}, "impacto_comentario": null, "prioridad_percibida": "media", "descripcion_original": "El banco no muestra el par en pantalla; marca cero con el motor girando.", "fecha_primera_revision": "2026-09-07T09:34:15.605531-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-09-07T09:34:15.605531-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-09-07T09:34:15.610587-05:00", "motivo": null, "comentario": "Convertida en OT-000004", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 36, "actor": "Administrador MIP", "fecha": "2026-09-07T09:34:15.610587-05:00", "nuevo": {"numero": "OT-000004", "emergencia": false, "desde_solicitud": "ST-000004"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "1400addf-2f07-4784-a1f6-62c95da13ef1", "entidad_tipo": "orden_trabajo"}, {"id": 37, "actor": "Elena Chávez Soto", "fecha": "2026-09-07T09:34:15.627826-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "1400addf-2f07-4784-a1f6-62c95da13ef1", "entidad_tipo": "orden_trabajo"}, {"id": 38, "actor": "Elena Chávez Soto", "fecha": "2026-09-07T09:34:15.627826-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "ea9f0825-89c1-4aae-a404-c87094cfea37", "entidad_tipo": "diagnostico"}, {"id": 39, "actor": "Administrador MIP", "fecha": "2026-09-07T09:34:15.645482-05:00", "nuevo": {"estado": "en_cotizacion"}, "evento": "estado_cambiado", "motivo": "Cotización seleccionada cargada", "dominio": "ot", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "1400addf-2f07-4784-a1f6-62c95da13ef1", "entidad_tipo": "orden_trabajo"}, {"id": 40, "actor": "Administrador MIP", "fecha": "2026-09-07T09:34:15.645482-05:00", "nuevo": {"monto": 7800, "moneda": "PEN", "version": 1}, "evento": "cotizacion_cargada", "motivo": null, "dominio": "cotizacion", "anterior": null, "entidad_id": "20dd8496-ea84-44bb-8740-a36c597b1147", "entidad_tipo": "cotizacion"}, {"id": 41, "actor": "Administrador MIP", "fecha": "2026-09-07T09:34:15.663697-05:00", "nuevo": {"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.663697-05:00", "sin_cotizacion": false}, "evento": "ejecucion_iniciada", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_cotizacion"}, "entidad_id": "1400addf-2f07-4784-a1f6-62c95da13ef1", "entidad_tipo": "ejecucion"}, {"id": 42, "actor": "Elena Chávez Soto", "fecha": "2026-09-07T09:34:15.682034-05:00", "nuevo": {"porcentaje": null}, "evento": "avance_registrado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "7832fa1d-ab85-42d8-aa41-9cf35ce2ca5e", "entidad_tipo": "ot_avance"}, {"id": 43, "actor": "Administrador MIP", "fecha": "2026-09-07T09:34:15.698235-05:00", "nuevo": {"fecha_pausa": "2026-09-20T15:34:15.698235-05:00"}, "evento": "pausa_registrada", "motivo": "Esperando la celda importada; el proveedor confirma tres semanas.", "dominio": "ejecucion", "anterior": null, "entidad_id": "fe3821cc-f565-4013-b805-aedc97cf74c3", "entidad_tipo": "ot_pausa"}, {"id": 99, "actor": "Administrador MIP", "fecha": "2026-09-07T09:34:16.739821-05:00", "nuevo": {"monto": 7800, "fuente": "cotizacion", "moneda": "PEN"}, "evento": "costo_registrado", "motivo": null, "dominio": "costos", "anterior": null, "entidad_id": "beea5c0c-b75b-4c50-b8d1-8c9b3f6ed775", "entidad_tipo": "costo_unitario"}, {"id": 106, "actor": "Administrador MIP", "fecha": "2026-09-20T15:34:17.788369-05:00", "nuevo": {"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0425.pdf"}, "evento": "adjunto_cargado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "20dd8496-ea84-44bb-8740-a36c597b1147", "entidad_tipo": "cotizacion"}], "adjuntos": [{"id": "bab9369a-cc2b-4113-87fb-7a67ad895b01", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.788369-05:00", "estado": "vigente", "nombre": "COT-2026-0425.pdf", "tamano": 1210, "entidad_id": "20dd8496-ea84-44bb-8740-a36c597b1147", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [{"id": "fe3821cc-f565-4013-b805-aedc97cf74c3", "horas": null, "motivo": "Esperando la celda importada; el proveedor confirma tres semanas.", "abierta": true, "fecha_pausa": "2026-09-07T09:34:15.698235-05:00", "pausada_por": "Administrador MIP", "motivo_texto": "Esperando la celda importada; el proveedor confirma tres semanas.", "reanudada_por": null, "fecha_reanudacion": null, "observacion_reanudacion": null}], "avances": [{"id": "7832fa1d-ab85-42d8-aa41-9cf35ce2ca5e", "autor": "Elena Chávez Soto", "fecha": "2026-09-07T09:34:15.682034-05:00", "adjuntos": [], "porcentaje": null, "descripcion": "Celda antigua retirada; se confirma el daño en el puente de galgas."}], "incidencias": [], "inicio_real": "2026-09-07T09:34:15.663697-05:00", "responsable": "Elena Chávez Soto", "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": false}, "conversacion": {"id": "fb0a4bc6-acb2-4516-9c08-c6b44e3f5fd5", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Julio Paredes Ramos", "usuario_id": "8b99e5c2-f44f-4d1e-84e5-f658747ba01c", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Pedro Aliaga Vera", "usuario_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "puede_escribir": true, "ve_notas_internas": false}, {"activo": true, "nombre": "Elena Chávez Soto", "usuario_id": "a7ee34e2-43bd-496d-99b0-ad8013072cea", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [{"id": "20dd8496-ea84-44bb-8740-a36c597b1147", "fecha": "2026-09-01", "monto": 7800.00, "moneda": "PEN", "numero": "COT-2026-0425", "version": 1, "vigente": true, "adjuntos": [{"id": "bab9369a-cc2b-4113-87fb-7a67ad895b01", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.788369-05:00", "estado": "vigente", "nombre": "COT-2026-0425.pdf", "tamano": 1210}], "proveedor": "INSTRUMENTACIÓN Y CONTROL S.A.", "cargada_at": "2026-09-07T09:34:15.645482-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": "Celda importada; incluye certificado de calibración.", "proveedor_ruc": "20398765436", "motivo_reemplazo": null, "plazo_ofrecido_dias": 21}], "diagnosticos": [{"id": "ea9f0825-89c1-4aae-a404-c87094cfea37", "autor": "Elena Chávez Soto", "fecha": "2026-09-07T09:34:15.627826-05:00", "alcance": "Celda de carga y su cableado.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Celda de carga sin señal; el amplificador entrega 0 mV con carga aplicada.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Celda dañada por sobrecarga en la última prueba.", "trabajo_a_realizar": "Reemplazar la celda, recalibrar el banco y emitir certificado.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
bd61bf6d-abeb-487f-91eb-3281f93643f0	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000005	15e5d80b-173b-451f-a58f-f49dd40813e9	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	191c571d-7b81-452c-8c99-92905ba5ca57	baja	f	\N	\N	\N	f	trabajo_realizado	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-06 13:34:15.727191-05	2026-09-06 13:34:15.777671-05	2026-09-06 13:34:15.795487-05	\N	\N	\N	\N	0	2026-09-06 13:34:15.727191-05	2026-09-20 15:34:17.827492-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	5a11b0c5-7640-494f-9c8b-64a9a4e30673	8	f	2026-09-20 15:34:17.827492-05	{"ot": {"id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "nivel": 0, "estado": "trabajo_realizado", "fechas": {"cierre": null, "creacion": "2026-09-06T13:34:15.727191-05:00", "cancelacion": null, "inicio_real": "2026-09-06T13:34:15.777671-05:00", "termino_real": "2026-09-06T13:34:15.795487-05:00"}, "numero": "OT-000005", "ejecutor": "Marco Tuesta Ríos", "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": false, "tipo_trabajo": "Soldadura y estructuras", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "baja", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.827492-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": [{"id": "7f6624ce-bf77-4289-ba48-4ca5a7a3a478", "version": 1, "vigente": true, "adjuntos": [], "revision": {"fecha": null, "revisor": null, "resultado": null, "observacion": null}, "resultado": null, "descripcion": "Guía enderezada, sensor nuevo y recorrido recalibrado. El portón cierra a ras de piso.", "declarado_por": "Marco Tuesta Ríos", "fecha_termino": "2026-09-06T13:34:15.795487-05:00", "observaciones": null, "conformidad_solicitante": {"fecha": null, "estado": "sin_pronunciarse", "comentario": null}}]}, "costos": {"contable": null, "cotizado": {"monto": 1180.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "fc517ca7-0336-4c07-bdaf-14a8235105df", "fuente": "cotizacion", "moneda": "PEN", "unidad": "servicio", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 1.0000, "concepto": "servicio", "proveedor": "PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L.", "monto_total": 1180.00, "tipo_trabajo": "Soldadura y estructuras", "costo_unitario": 1180.0000, "texto_original": "SENSOR FIN DE CARRERA OMRON + ENDEREZADO DE GUIA", "fecha_referencia": "2026-08-31", "descripcion_normalizada": null}]}, "origen": {"ot_padre": null, "solicitud": {"id": "15e5d80b-173b-451f-a58f-f49dd40813e9", "lugar": "Almacén central", "estado": "convertida_en_ot", "numero": "ST-000005", "titulo": "Portón del almacén no cierra completo", "impacto": "Parada total de la operación", "fecha_envio": "2026-09-06T13:34:15.716094-05:00", "solicitante": {"id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "nombre": "Nancy Ortiz Huamán"}, "impacto_comentario": null, "prioridad_percibida": "baja", "descripcion_original": "Queda una luz de veinte centímetros y entra polvo al almacén.", "fecha_primera_revision": "2026-09-06T13:34:15.722364-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-09-06T13:34:15.722364-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-09-06T13:34:15.727191-05:00", "motivo": null, "comentario": "Convertida en OT-000005", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 44, "actor": "Administrador MIP", "fecha": "2026-09-06T13:34:15.727191-05:00", "nuevo": {"numero": "OT-000005", "emergencia": false, "desde_solicitud": "ST-000005"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "entidad_tipo": "orden_trabajo"}, {"id": 45, "actor": "Marco Tuesta Ríos", "fecha": "2026-09-06T13:34:15.742902-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "entidad_tipo": "orden_trabajo"}, {"id": 46, "actor": "Marco Tuesta Ríos", "fecha": "2026-09-06T13:34:15.742902-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "f02374ce-1ee7-40b8-99c8-e794d5c77646", "entidad_tipo": "diagnostico"}, {"id": 47, "actor": "Administrador MIP", "fecha": "2026-09-06T13:34:15.759791-05:00", "nuevo": {"estado": "en_cotizacion"}, "evento": "estado_cambiado", "motivo": "Cotización seleccionada cargada", "dominio": "ot", "anterior": {"estado": "en_diagnostico"}, "entidad_id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "entidad_tipo": "orden_trabajo"}, {"id": 48, "actor": "Administrador MIP", "fecha": "2026-09-06T13:34:15.759791-05:00", "nuevo": {"monto": 1180, "moneda": "PEN", "version": 1}, "evento": "cotizacion_cargada", "motivo": null, "dominio": "cotizacion", "anterior": null, "entidad_id": "fee02c0d-bc83-47cd-b082-7f25428e0fd3", "entidad_tipo": "cotizacion"}, {"id": 49, "actor": "Administrador MIP", "fecha": "2026-09-06T13:34:15.777671-05:00", "nuevo": {"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.777671-05:00", "sin_cotizacion": false}, "evento": "ejecucion_iniciada", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_cotizacion"}, "entidad_id": "bd61bf6d-abeb-487f-91eb-3281f93643f0", "entidad_tipo": "ejecucion"}, {"id": 50, "actor": "Marco Tuesta Ríos", "fecha": "2026-09-06T13:34:15.795487-05:00", "nuevo": {"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:15.795487-05:00", "version": 1}, "evento": "trabajo_declarado", "motivo": null, "dominio": "ejecucion", "anterior": {"estado": "en_trabajo"}, "entidad_id": "7f6624ce-bf77-4289-ba48-4ca5a7a3a478", "entidad_tipo": "trabajo_realizado"}, {"id": 98, "actor": "Administrador MIP", "fecha": "2026-09-06T13:34:16.717544-05:00", "nuevo": {"monto": 1180, "fuente": "cotizacion", "moneda": "PEN"}, "evento": "costo_registrado", "motivo": null, "dominio": "costos", "anterior": null, "entidad_id": "fc517ca7-0336-4c07-bdaf-14a8235105df", "entidad_tipo": "costo_unitario"}, {"id": 107, "actor": "Administrador MIP", "fecha": "2026-09-20T15:34:17.827492-05:00", "nuevo": {"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0430.pdf"}, "evento": "adjunto_cargado", "motivo": null, "dominio": "ejecucion", "anterior": null, "entidad_id": "fee02c0d-bc83-47cd-b082-7f25428e0fd3", "entidad_tipo": "cotizacion"}], "adjuntos": [{"id": "3ba51897-8849-4a94-8e53-edc5566773d7", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.827492-05:00", "estado": "vigente", "nombre": "COT-2026-0430.pdf", "tamano": 1218, "entidad_id": "fee02c0d-bc83-47cd-b082-7f25428e0fd3", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": "2026-09-06T13:34:15.777671-05:00", "responsable": "Marco Tuesta Ríos", "termino_real": "2026-09-06T13:34:15.795487-05:00", "duracion_dias": 0.00, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": false}, "conversacion": {"id": "c0e97014-5815-4e69-bf7c-b366ec776687", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Nancy Ortiz Huamán", "usuario_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "puede_escribir": true, "ve_notas_internas": false}, {"activo": true, "nombre": "Marco Tuesta Ríos", "usuario_id": "5a11b0c5-7640-494f-9c8b-64a9a4e30673", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [{"id": "fee02c0d-bc83-47cd-b082-7f25428e0fd3", "fecha": "2026-08-31", "monto": 1180.00, "moneda": "PEN", "numero": "COT-2026-0430", "version": 1, "vigente": true, "adjuntos": [{"id": "3ba51897-8849-4a94-8e53-edc5566773d7", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.827492-05:00", "estado": "vigente", "nombre": "COT-2026-0430.pdf", "tamano": 1218}], "proveedor": "PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L.", "cargada_at": "2026-09-06T13:34:15.759791-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20567890121", "motivo_reemplazo": null, "plazo_ofrecido_dias": 4}], "diagnosticos": [{"id": "f02374ce-1ee7-40b8-99c8-e794d5c77646", "autor": "Marco Tuesta Ríos", "fecha": "2026-09-06T13:34:15.742902-05:00", "alcance": "Guía inferior y sensores de final de carrera.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Guía inferior deformada y final de carrera descalibrado.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Golpe de montacargas contra la guía.", "trabajo_a_realizar": "Enderezar la guía, reemplazar el sensor y recalibrar recorrido.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
cd790d32-39ab-4aba-b33d-2dc34a03831a	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000012	48ebc1d1-f4de-4401-9cca-06e3d91e3621	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	5e8cdfa9-2263-4d6c-99e7-e8a2af905922	\N	baja	f	\N	\N	\N	f	cancelada	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	2026-08-05 08:34:16.261469-05	\N	\N	\N	\N	El pasillo entra en el proyecto de recambio a LED de toda la planta; se atiende allí.	2026-08-05 08:34:16.277853-05	0	2026-08-05 08:34:16.261469-05	2026-09-20 15:34:17.843717-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3	f	2026-09-20 15:34:17.843717-05	{"ot": {"id": "cd790d32-39ab-4aba-b33d-2dc34a03831a", "nivel": 0, "estado": "cancelada", "fechas": {"cierre": null, "creacion": "2026-08-05T08:34:16.261469-05:00", "cancelacion": "2026-08-05T08:34:16.277853-05:00", "inicio_real": null, "termino_real": null}, "numero": "OT-000012", "ejecutor": null, "condicion": "activa", "emergencia": null, "cancelacion": {"fecha": "2026-08-05T08:34:16.277853-05:00", "motivo": null, "observacion": "El pasillo entra en el proyecto de recambio a LED de toda la planta; se atiende allí."}, "coordinador": "Rosa Quispe Vargas", "es_derivada": false, "tipo_trabajo": null, "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "baja", "tipo_mantenimiento": "Preventivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:17.843717-05:00", "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": null, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": []}, "origen": {"ot_padre": null, "solicitud": {"id": "48ebc1d1-f4de-4401-9cca-06e3d91e3621", "lugar": "Pasillo 3", "estado": "convertida_en_ot", "numero": "ST-000010", "titulo": "Cambiar luminarias del pasillo 3", "impacto": "Parada total de la operación", "fecha_envio": "2026-08-05T08:34:16.251273-05:00", "solicitante": {"id": "f71701ef-202b-4563-9c16-10f1d41b8135", "nombre": "Pedro Aliaga Vera"}, "impacto_comentario": null, "prioridad_percibida": "baja", "descripcion_original": "Las luminarias parpadean y algunas ya no encienden.", "fecha_primera_revision": "2026-08-05T08:34:16.256839-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-08-05T08:34:16.256839-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-08-05T08:34:16.261469-05:00", "motivo": null, "comentario": "Convertida en OT-000012", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 80, "actor": "Administrador MIP", "fecha": "2026-08-05T08:34:16.261469-05:00", "nuevo": {"numero": "OT-000012", "emergencia": false, "desde_solicitud": "ST-000010"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "cd790d32-39ab-4aba-b33d-2dc34a03831a", "entidad_tipo": "orden_trabajo"}, {"id": 81, "actor": "Administrador MIP", "fecha": "2026-08-05T08:34:16.277853-05:00", "nuevo": {"estado": "cancelada", "derivadas": []}, "evento": "ot_cancelada", "motivo": "El pasillo entra en el proyecto de recambio a LED de toda la planta; se atiende allí.", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "cd790d32-39ab-4aba-b33d-2dc34a03831a", "entidad_tipo": "orden_trabajo"}], "adjuntos": [], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": null, "responsable": null, "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": null, "inicio_sin_cotizacion": false}, "conversacion": {"id": "f149a501-ba59-48c3-9839-60a4a0a402ab", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Pedro Aliaga Vera", "usuario_id": "f71701ef-202b-4563-9c16-10f1d41b8135", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [], "diagnosticos": [], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
c7dd4771-3654-4aff-89a5-f7661193fb03	5c921062-21ab-4a01-8f9a-2e2500e95893	OT-000009	3c527e52-05d9-4490-b025-2785a2e0a7b2	\N	0	\N	\N	t	f	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	151f5ad1-9d5e-4f59-a283-15f6ec05f515	\N	e09565c0-2ff9-469c-9a84-c121c59bc9c7	bf147cd2-23c8-4e07-819e-a6cde044e15e	alta	f	\N	\N	\N	f	en_diagnostico	activa	sin_solped	472ed7f9-7862-406e-8075-50e2fdc26dbb	\N	2026-09-18 07:34:16.012792-05	\N	\N	\N	\N	\N	\N	0	2026-09-18 07:34:16.012792-05	2026-09-20 15:34:18.313548-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	7	f	2026-09-20 15:34:18.313548-05	{"ot": {"id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "nivel": 0, "estado": "en_diagnostico", "fechas": {"cierre": null, "creacion": "2026-09-18T07:34:16.012792-05:00", "cancelacion": null, "inicio_real": null, "termino_real": null}, "numero": "OT-000009", "ejecutor": null, "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": false, "tipo_trabajo": "Bombas y sistemas hidráulicos", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": false, "generado_en": "2026-09-20T15:34:18.313548-05:00", "total_nodos": 3, "profundidad_arbol": 1}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": null, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": []}, "origen": {"ot_padre": null, "solicitud": {"id": "3c527e52-05d9-4490-b025-2785a2e0a7b2", "lugar": "Patio de maniobras", "estado": "convertida_en_ot", "numero": "ST-000009", "titulo": "Montacargas 4 sin fuerza y con falla eléctrica", "impacto": "Parada total de la operación", "fecha_envio": "2026-09-18T07:34:16.003112-05:00", "solicitante": {"id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "nombre": "Nancy Ortiz Huamán"}, "impacto_comentario": null, "prioridad_percibida": "alta", "descripcion_original": "Levanta a media carga y en el tablero se prende una luz que no conocemos.", "fecha_primera_revision": "2026-09-18T07:34:16.008095-05:00"}, "decisiones": [{"tipo": "tomar_revision", "actor": "Administrador MIP", "fecha": "2026-09-18T07:34:16.008095-05:00", "motivo": null, "comentario": null, "estado_nuevo": "en_revision", "estado_anterior": "enviada"}, {"tipo": "aceptar", "actor": "Administrador MIP", "fecha": "2026-09-18T07:34:16.012792-05:00", "motivo": null, "comentario": "Convertida en OT-000009", "estado_nuevo": "convertida_en_ot", "estado_anterior": "en_revision"}]}, "eventos": [{"id": 65, "actor": "Administrador MIP", "fecha": "2026-09-18T07:34:16.012792-05:00", "nuevo": {"numero": "OT-000009", "emergencia": false, "desde_solicitud": "ST-000009"}, "evento": "ot_creada", "motivo": null, "dominio": "ot", "anterior": null, "entidad_id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "entidad_tipo": "orden_trabajo"}, {"id": 66, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-18T07:34:16.033936-05:00", "nuevo": {"estado": "en_diagnostico"}, "evento": "estado_cambiado", "motivo": "Primer diagnóstico registrado", "dominio": "ot", "anterior": {"estado": "creada"}, "entidad_id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "entidad_tipo": "orden_trabajo"}, {"id": 67, "actor": "Víctor Ramos Núñez", "fecha": "2026-09-18T07:34:16.033936-05:00", "nuevo": {"version": 1}, "evento": "diagnostico_creado", "motivo": null, "dominio": "diagnostico", "anterior": null, "entidad_id": "18354423-f450-4025-9dd2-d33d2f45b580", "entidad_tipo": "diagnostico"}, {"id": 69, "actor": "Administrador MIP", "fecha": "2026-09-18T07:34:16.051891-05:00", "nuevo": {"numero": "OT-000010", "bloqueante": true}, "evento": "derivada_generada", "motivo": "El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación.", "dominio": "ot", "anterior": null, "entidad_id": "ee9a06f5-0220-47a0-8e4a-d992333af106", "entidad_tipo": "orden_trabajo"}, {"id": 71, "actor": "Administrador MIP", "fecha": "2026-09-18T07:34:16.085222-05:00", "nuevo": {"numero": "OT-000011", "bloqueante": true}, "evento": "derivada_generada", "motivo": "El rectificado de la bomba va a un taller externo especializado.", "dominio": "ot", "anterior": null, "entidad_id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "entidad_tipo": "orden_trabajo"}], "adjuntos": [], "derivadas": [{"ot": {"id": "ee9a06f5-0220-47a0-8e4a-d992333af106", "nivel": 1, "estado": "creada", "fechas": {"cierre": null, "creacion": "2026-09-17T11:34:16.051891-05:00", "cancelacion": null, "inicio_real": null, "termino_real": null}, "numero": "OT-000010", "ejecutor": null, "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": true, "tipo_trabajo": "Bombas y sistemas hidráulicos", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": true, "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [], "reaperturas": [], "trabajo_realizado": []}, "costos": {"contable": null, "cotizado": null, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": []}, "origen": {"ot_padre": {"id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "estado": "en_diagnostico", "numero": "OT-000009", "es_bloqueante": true, "independizada": false, "motivo_derivacion": "El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación."}, "solicitud": null, "decisiones": []}, "adjuntos": [], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": null, "responsable": null, "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": null, "inicio_sin_cotizacion": false}, "cotizaciones": [], "diagnosticos": [], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}, {"ot": {"id": "a9859198-0a21-4309-8a00-2ca9a2cdc917", "nivel": 1, "estado": "cerrada", "fechas": {"cierre": "2026-08-06T15:34:16.210247-05:00", "creacion": "2026-08-06T15:34:16.085222-05:00", "cancelacion": null, "inicio_real": "2026-08-06T15:34:16.158376-05:00", "termino_real": "2026-08-06T15:34:16.17693-05:00"}, "numero": "OT-000011", "ejecutor": "Víctor Ramos Núñez", "condicion": "activa", "emergencia": null, "cancelacion": null, "coordinador": "Rosa Quispe Vargas", "es_derivada": true, "tipo_trabajo": "Bombas y sistemas hidráulicos", "es_emergencia": false, "veces_reabierta": 0, "prioridad_tecnica": "alta", "tipo_mantenimiento": "Correctivo", "estado_administrativo": "sin_solped", "es_bloqueante_para_padre": true}, "_meta": {"version": 1, "resumido": true, "total_nodos": 1, "profundidad_arbol": 0}, "cierre": {"cierres": [{"id": "fa696e6a-92fe-4d81-8afe-121994ed030e", "fecha": "2026-08-06T15:34:16.210247-05:00", "vigente": true, "secuencia": 1, "cerrado_por": "Administrador MIP", "admin_revisado": true, "observacion_pendiente": "Sin SOLPED: el gasto se imputó al contrato marco del taller externo.", "estado_admin_al_cierre": "sin_solped", "derivadas_bloqueantes_resueltas": true}], "reaperturas": [], "trabajo_realizado": [{"id": "204401ea-b3e8-4e6e-a8b1-6d503b51fe4e", "version": 1, "vigente": true, "adjuntos": [], "revision": {"fecha": "2026-08-06T15:34:16.194661-05:00", "revisor": "Administrador MIP", "resultado": "aprobado", "observacion": ""}, "resultado": null, "descripcion": "Bomba rectificada y sellos nuevos. Presión de elevación restituida a 180 bar.", "declarado_por": "Víctor Ramos Núñez", "fecha_termino": "2026-08-06T15:34:16.17693-05:00", "observaciones": null, "conformidad_solicitante": {"fecha": null, "estado": "sin_pronunciarse", "comentario": null}}]}, "costos": {"contable": null, "cotizado": {"monto": 1960.00, "fuente": "cotizacion_vigente", "moneda": "PEN"}, "liberado": {"monto": 0.00, "fuente": "liberacion_manual", "moneda": "PEN"}, "registros": [{"id": "1d69c883-fb44-477b-9c3f-971c74923db7", "fuente": "cotizacion", "moneda": "PEN", "unidad": "servicio", "calidad": {"confianza": null, "es_outlier": false, "es_comparable": true, "estado_validacion": "sin_validar", "justificacion_outlier": null}, "cantidad": 1.0000, "concepto": "servicio", "proveedor": "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", "monto_total": 1960.00, "tipo_trabajo": "Bombas y sistemas hidráulicos", "costo_unitario": 1960.0000, "texto_original": "RECTIFICADO BOMBA ENGRANAJES + SELLOS", "fecha_referencia": "2026-07-31", "descripcion_normalizada": null}]}, "origen": {"ot_padre": {"id": "c7dd4771-3654-4aff-89a5-f7661193fb03", "estado": "en_diagnostico", "numero": "OT-000009", "es_bloqueante": true, "independizada": false, "motivo_derivacion": "El rectificado de la bomba va a un taller externo especializado."}, "solicitud": null, "decisiones": []}, "adjuntos": [{"id": "3a80cc87-ddaf-4abc-ba2c-62acd0543a92", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.711979-05:00", "estado": "vigente", "nombre": "COT-2026-0436.pdf", "tamano": 1212, "entidad_id": "64dc018a-0a2e-45e7-913d-e1dcdf82baf9", "entidad_tipo": "cotizacion"}], "derivadas": [], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": "2026-08-06T15:34:16.158376-05:00", "responsable": "Víctor Ramos Núñez", "termino_real": "2026-08-06T15:34:16.17693-05:00", "duracion_dias": 0.00, "observaciones": null, "confirmado_por": "Administrador MIP", "inicio_sin_cotizacion": false}, "cotizaciones": [{"id": "64dc018a-0a2e-45e7-913d-e1dcdf82baf9", "fecha": "2026-07-31", "monto": 1960.00, "moneda": "PEN", "numero": "COT-2026-0436", "version": 1, "vigente": true, "adjuntos": [{"id": "3a80cc87-ddaf-4abc-ba2c-62acd0543a92", "mime": "application/pdf", "tipo": "pdf", "autor": "Administrador MIP", "etapa": "cotizacion", "fecha": "2026-09-20T15:34:17.711979-05:00", "estado": "vigente", "nombre": "COT-2026-0436.pdf", "tamano": 1212}], "proveedor": "HIDRÁULICA INDUSTRIAL LIMA S.A.C.", "cargada_at": "2026-08-06T15:34:16.140996-05:00", "invalidada": false, "cargada_por": "Administrador MIP", "reemplaza_a": null, "validez_dias": 30, "observaciones": null, "proveedor_ruc": "20456789014", "motivo_reemplazo": null, "plazo_ofrecido_dias": 8}], "diagnosticos": [{"id": "791fa998-20f5-400d-878e-5ee9b4313624", "autor": "Víctor Ramos Núñez", "fecha": "2026-08-06T15:34:16.122692-05:00", "alcance": "Bomba de elevación.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Bomba de engranajes con holgura fuera de tolerancia.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Desgaste normal por horas de servicio.", "trabajo_a_realizar": "Rectificar la bomba y reemplazar sellos.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": "Sin SOLPED: el gasto se imputó al contrato marco del taller externo.", "revisado_at": "2026-09-20T15:34:16.210247-05:00", "liberaciones": [], "revisado_por": "Administrador MIP", "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}], "ejecucion": {"pausas": [], "avances": [], "incidencias": [], "inicio_real": null, "responsable": null, "termino_real": null, "duracion_dias": null, "observaciones": null, "confirmado_por": null, "inicio_sin_cotizacion": false}, "conversacion": {"id": "e8172851-b434-4f84-9394-b48b02c47e6b", "mensajes": [], "solo_lectura": false, "participantes": [{"activo": true, "nombre": "Rosa Quispe Vargas", "usuario_id": "472ed7f9-7862-406e-8075-50e2fdc26dbb", "puede_escribir": true, "ve_notas_internas": true}, {"activo": true, "nombre": "Nancy Ortiz Huamán", "usuario_id": "89f7a8be-5af2-4d60-b578-9d01db2edce0", "puede_escribir": true, "ve_notas_internas": false}]}, "cotizaciones": [], "diagnosticos": [{"id": "18354423-f450-4025-9dd2-d33d2f45b580", "autor": "Víctor Ramos Núñez", "fecha": "2026-09-18T07:34:16.033936-05:00", "alcance": "Sistema hidráulico de elevación; el eléctrico se separa.", "version": 1, "vigente": true, "adjuntos": [], "aprobado_at": null, "diagnostico": "Dos problemas independientes: caída de presión en el circuito de elevación y falla en el módulo de control.", "reemplaza_a": null, "aprobado_por": null, "motivo_cambio": null, "observaciones": null, "causa_probable": "Bomba desgastada por un lado; módulo con avería de fábrica por otro.", "trabajo_a_realizar": "Reparar el circuito hidráulico y derivar la parte eléctrica a un especialista.", "lecturas_instrumentos": null}], "organizacion": {"area": {"id": "151f5ad1-9d5e-4f59-a283-15f6ec05f515", "codigo": "PROD", "nombre": "Producción"}, "cecos": null, "tenant": {"id": "5c921062-21ab-4a01-8f9a-2e2500e95893", "nombre": "Organización Demo MIP"}, "sucursal": {"id": "f2bffb8f-46b9-41a3-abf7-0c595ce21e33", "codigo": "PLANTA-01", "nombre": "Planta principal"}, "empresa_ruc": {"id": "1d2f2959-955c-41b0-96f0-cca1a3c631ba", "ruc": "20100000001", "estado": "activo", "razon_social": "DEMO INDUSTRIAL S.A.C."}}, "administrativo": {"oc": [], "moneda": "PEN", "solped": [], "observacion": null, "revisado_at": null, "liberaciones": [], "revisado_por": null, "estado_consolidado": "sin_solped", "monto_liberado_total": 0.00}}
\.


--
-- Data for Name: ot_avance; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.ot_avance (id, tenant_id, ot_id, descripcion, porcentaje, autor_id, created_at) FROM stdin;
97179a5b-66d0-4ded-bd2c-03374705e928	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	Compresor desmontado y kit de válvulas recibido del proveedor.	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.063196-05
6b424a1f-b2f0-4db2-9a11-fa76a416afae	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	Anillos reemplazados y aceite cambiado. Pendiente la prueba de cuatro horas.	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.079298-05
9032c5b9-7fa3-4221-847d-26ec63f47b93	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	Contactor reemplazado y térmico recalibrado a 24 A.	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.370424-05
59da0c27-04c6-4db4-b488-d899345240b6	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	Cilindro desmontado y enviado al taller de rectificado.	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.549013-05
710b89ee-4203-4297-a2cb-692b460048fd	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	Retenes nuevos recibidos; se monta mañana a primera hora.	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.566039-05
7832fa1d-ab85-42d8-aa41-9cf35ce2ca5e	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	Celda antigua retirada; se confirma el daño en el puente de galgas.	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-07 09:34:15.682034-05
853509f5-c7c6-4c6a-83a6-bf6c6bac2629	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	Planta desenergizada, borne reemplazado y barra reajustada a torque de catálogo.	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-03 14:34:15.987933-05
\.


--
-- Data for Name: ot_cierre; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.ot_cierre (id, tenant_id, ot_id, secuencia, vigente, fecha_cierre, cerrado_por, admin_revisado, estado_admin_al_cierre, observacion_pendiente, derivadas_bloqueantes_resueltas, created_at) FROM stdin;
3d37a873-d668-49eb-8227-2899d96f0d5b	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	1	t	2026-08-16 08:34:15.270008-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	f	administracion_completa	\N	t	2026-08-16 08:34:15.270008-05
8dbee6e1-1ded-47bc-a602-bc993c5f6482	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	1	t	2026-08-15 12:34:15.441202-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	t	solped_pendiente	Compras emite la OC la próxima semana; el equipo ya está operativo.	t	2026-08-15 12:34:15.441202-05
fa696e6a-92fe-4d81-8afe-121994ed030e	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	1	t	2026-08-06 15:34:16.210247-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	t	sin_solped	Sin SOLPED: el gasto se imputó al contrato marco del taller externo.	t	2026-08-06 15:34:16.210247-05
008864e3-0723-4b63-924b-a66243c6b139	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	1	f	2026-08-29 12:34:16.407424-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	t	sin_solped	Gasto menor imputado a caja chica; sin SOLPED.	t	2026-08-29 12:34:16.407424-05
\.


--
-- Data for Name: ot_estado_historial; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.ot_estado_historial (id, tenant_id, ot_id, estado_anterior, estado_nuevo, motivo_id, motivo_texto, actor_id, created_at) FROM stdin;
8fccb9e9-477c-4d18-ab38-7f59e3edb9b4	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	creada	en_diagnostico	\N	Primer diagnóstico registrado	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-12 10:34:15.894171-05
710e3de7-fa0d-4c07-81a9-57208df29a57	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	\N	creada	\N	Creada desde ST-000007	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-12 10:34:15.879017-05
1d598cc1-ff2e-42a4-b464-5cfa8974fdcd	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	en_diagnostico	en_trabajo	\N	Inicio en emergencia, sin cotización vigente	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-03 14:34:15.970837-05
815740f7-2691-49a6-96f3-f8a174736686	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	creada	en_diagnostico	\N	Primer diagnóstico registrado	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-03 14:34:15.953977-05
c7ff4047-8804-42d1-8184-c5cf11d9e69b	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	\N	creada	\N	Creada desde ST-000008	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-03 14:34:15.93803-05
0eef4f28-e9ee-41c8-8044-854688bc4bbd	5c921062-21ab-4a01-8f9a-2e2500e95893	ee9a06f5-0220-47a0-8e4a-d992333af106	\N	creada	\N	Derivada de OT-000009	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-17 11:34:16.051891-05
5e9f666d-b742-487b-9a3a-d6190a4456c6	5c921062-21ab-4a01-8f9a-2e2500e95893	cd790d32-39ab-4aba-b33d-2dc34a03831a	creada	cancelada	\N	El pasillo entra en el proyecto de recambio a LED de toda la planta; se atiende allí.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-05 08:34:16.277853-05
21115a55-0b3c-484a-83aa-553f1fc4f680	5c921062-21ab-4a01-8f9a-2e2500e95893	cd790d32-39ab-4aba-b33d-2dc34a03831a	\N	creada	\N	Creada desde ST-000010	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-05 08:34:16.261469-05
2ac9a9e2-d0f2-44d9-a61f-684493f1705f	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	trabajo_realizado	cerrada	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.270008-05
12d30f05-1679-4385-9576-41c4805cfd5c	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	en_trabajo	trabajo_realizado	\N	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.13043-05
2b9791b9-f813-40f7-b925-25cd61c147ce	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	en_cotizacion	en_trabajo	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.044115-05
0202dae9-039f-4dd6-92f3-3eafd3c7301e	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	en_diagnostico	en_cotizacion	\N	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.024621-05
748de791-3019-4f96-9ac2-9ffec2d577bf	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	creada	en_diagnostico	\N	Primer diagnóstico registrado	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.003489-05
dcfb29f7-9fe1-4bdd-ad71-06744c0a2f69	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	\N	creada	\N	Creada desde ST-000001	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:14.977113-05
f371fcf5-dde1-4b17-91fa-ab7452c21a1f	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	trabajo_realizado	cerrada	\N	Compras emite la OC la próxima semana; el equipo ya está operativo.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.441202-05
5158597b-ebbb-48d0-8fb1-537264146ed1	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	en_trabajo	trabajo_realizado	\N	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.386203-05
1586afb9-4511-4f4f-a529-867fc0f84102	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	en_cotizacion	en_trabajo	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.350916-05
18b6a881-f42d-4335-bc16-b2ab6c7ba576	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	en_diagnostico	en_cotizacion	\N	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.333867-05
6d5bc77b-942c-4757-9aa6-368712f00068	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	creada	en_diagnostico	\N	Primer diagnóstico registrado	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.317312-05
68d48283-0add-45ea-86b4-c0cef315c5fc	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	\N	creada	\N	Creada desde ST-000002	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.302141-05
68f1fdd8-a197-4db5-a59a-89acfe01177f	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	en_cotizacion	en_trabajo	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.529557-05
a2f8d43a-c8d1-47d4-ac67-e8a3a3bafac6	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	en_diagnostico	en_cotizacion	\N	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.508809-05
13ce9a7f-7eb9-4eb1-b239-7001a42f1f3e	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	creada	en_diagnostico	\N	Primer diagnóstico registrado	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.490058-05
49eda922-63c0-487c-913d-6db4711bc413	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	\N	creada	\N	Creada desde ST-000003	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.470721-05
53dec8d0-3749-40a6-8619-71cee8723a3a	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	en_diagnostico	en_cotizacion	\N	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:15.853975-05
6b95b7c4-1db7-437d-b146-84cf8e75b698	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	creada	en_diagnostico	\N	Primer diagnóstico registrado	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-13 06:34:15.836675-05
1b20bfb9-6c50-4f11-a26a-ece64c65cf42	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	\N	creada	\N	Creada desde ST-000006	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:15.821136-05
87befefc-f435-43c9-9b21-7e1741d6b963	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	creada	en_diagnostico	\N	Primer diagnóstico registrado	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-18 07:34:16.033936-05
ab745b17-b001-458d-b1f3-b664552cd834	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	\N	creada	\N	Creada desde ST-000009	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-18 07:34:16.012792-05
773846dd-8813-470b-8a54-f4331a44e9f0	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	trabajo_realizado	cerrada	\N	Sin SOLPED: el gasto se imputó al contrato marco del taller externo.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.210247-05
00188065-8608-4169-bafd-3082a364db1a	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	en_trabajo	trabajo_realizado	\N	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-08-06 15:34:16.17693-05
d299b72a-070d-4679-be6e-d66714ba0f01	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	en_cotizacion	en_trabajo	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.158376-05
a9590640-1a06-42ee-8f71-2dc8068a7e9e	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	en_diagnostico	en_cotizacion	\N	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.140996-05
0f23e669-7ce0-4700-aa57-c2ef1cd73c86	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	creada	en_diagnostico	\N	Primer diagnóstico registrado	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-08-06 15:34:16.122692-05
16957c65-fc01-4ab9-b051-b669edd54bd0	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	\N	creada	\N	Derivada de OT-000009	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.085222-05
047fb6be-848d-487e-9132-a215b1339d13	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	cerrada	en_trabajo	\N	La presión volvió a caer a los cuatro días; la fuga no era sólo la retención.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.42939-05
dd1ea76c-d9e9-41d3-91d1-5e5602c4b5f7	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	trabajo_realizado	cerrada	\N	Gasto menor imputado a caja chica; sin SOLPED.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.407424-05
9bb7ff58-d286-4ffe-9d38-7ea1520f79d7	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	en_trabajo	trabajo_realizado	\N	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-29 12:34:16.372475-05
21f59ab7-9298-4a87-9a1b-8a52ede4dc0c	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	en_cotizacion	en_trabajo	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.35434-05
2cbd7ab5-8b75-4d03-a1a9-90777d2ef45e	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	en_diagnostico	en_cotizacion	\N	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.336221-05
d477c206-8827-4932-9901-7408357e57f7	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	creada	en_diagnostico	\N	Primer diagnóstico registrado	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-29 12:34:16.320121-05
a6962ccf-aee6-4662-8671-ff4c4d72df79	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	\N	creada	\N	Creada desde ST-000011	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.304342-05
950076ae-19ae-454d-8bef-ce5f5100bdab	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	en_trabajo	trabajo_realizado	\N	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-06 13:34:15.795487-05
1a2319e5-2cd4-4212-8f69-da940f883ab6	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	en_cotizacion	en_trabajo	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.777671-05
01d2e62e-1497-46e3-8cbb-f781403049ad	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	en_diagnostico	en_cotizacion	\N	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.759791-05
30f764c0-a739-4b9b-8824-9b5d8c20509e	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	creada	en_diagnostico	\N	Primer diagnóstico registrado	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-06 13:34:15.742902-05
763bd507-22c6-48ca-90d8-742c9f97a264	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	\N	creada	\N	Creada desde ST-000005	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.727191-05
4b0837bd-0532-4884-b84f-c63debe73412	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	en_cotizacion	en_trabajo	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.663697-05
6ff984be-ac58-41f4-b0c3-96b8377a3751	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	en_diagnostico	en_cotizacion	\N	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.645482-05
0ce38c87-aa7c-47e6-a32d-d5d18a10c41b	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	creada	en_diagnostico	\N	Primer diagnóstico registrado	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-07 09:34:15.627826-05
a1d2a446-143a-4495-ba6c-f0251d48d37a	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	\N	creada	\N	Creada desde ST-000004	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.610587-05
\.


--
-- Data for Name: ot_evento; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.ot_evento (id, tenant_id, ot_id, dominio, evento, entidad_tipo, entidad_id, valor_anterior, valor_nuevo, motivo, actor_id, created_at) FROM stdin;
64	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	ejecucion	avance_registrado	ot_avance	853509f5-c7c6-4c6a-83a6-bf6c6bac2629	\N	{"porcentaje": null}	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-03 14:34:15.987933-05
58	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	diagnostico	diagnostico_creado	diagnostico	6c790e33-e72e-41e8-8b39-f674aee35b27	\N	{"version": 1}	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-12 10:34:15.894171-05
59	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	diagnostico	diagnostico_reemplazado	diagnostico	a7d1acee-a648-4a11-97e3-449d55bfd2a5	{"version": 1}	{"version": 2}	El registro nocturno descartó el presostato: la presión de red cae antes del corte.	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-12 10:34:15.912279-05
57	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	ot	estado_cambiado	orden_trabajo	f1c60e96-9925-4aa2-a68b-00a72489fd2f	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-12 10:34:15.894171-05
56	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	ot	ot_creada	orden_trabajo	f1c60e96-9925-4aa2-a68b-00a72489fd2f	\N	{"numero": "OT-000007", "emergencia": false, "desde_solicitud": "ST-000007"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-12 10:34:15.879017-05
63	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	ejecucion	ejecucion_iniciada	ejecucion	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	{"estado": "en_diagnostico"}	{"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.970837-05:00", "sin_cotizacion": true}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-03 14:34:15.970837-05
62	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	diagnostico	diagnostico_creado	diagnostico	b00067d2-e86e-4a23-adcf-13f448a9c1c0	\N	{"version": 1}	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-03 14:34:15.953977-05
61	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	ot	estado_cambiado	orden_trabajo	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-03 14:34:15.953977-05
60	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	ot	ot_creada	orden_trabajo	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	\N	{"numero": "OT-000008", "emergencia": true, "desde_solicitud": "ST-000008"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-03 14:34:15.93803-05
68	5c921062-21ab-4a01-8f9a-2e2500e95893	ee9a06f5-0220-47a0-8e4a-d992333af106	ot	derivada_creada	orden_trabajo	ee9a06f5-0220-47a0-8e4a-d992333af106	\N	{"padre": "OT-000009", "numero": "OT-000010", "bloqueante": true}	El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-17 11:34:16.051891-05
81	5c921062-21ab-4a01-8f9a-2e2500e95893	cd790d32-39ab-4aba-b33d-2dc34a03831a	ot	ot_cancelada	orden_trabajo	cd790d32-39ab-4aba-b33d-2dc34a03831a	{"estado": "creada"}	{"estado": "cancelada", "derivadas": []}	El pasillo entra en el proyecto de recambio a LED de toda la planta; se atiende allí.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-05 08:34:16.277853-05
80	5c921062-21ab-4a01-8f9a-2e2500e95893	cd790d32-39ab-4aba-b33d-2dc34a03831a	ot	ot_creada	orden_trabajo	cd790d32-39ab-4aba-b33d-2dc34a03831a	\N	{"numero": "OT-000012", "emergencia": false, "desde_solicitud": "ST-000010"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-05 08:34:16.261469-05
92	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	costos	costo_registrado	costo_unitario	f5d74e1b-a79b-4814-98fd-00a5c1c246c7	\N	{"monto": 4850, "fuente": "cotizacion", "moneda": "PEN"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:16.568911-05
16	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ot	ot_cerrada	ot_cierre	3d37a873-d668-49eb-8227-2899d96f0d5b	{"estado": "trabajo_realizado"}	{"estado": "cerrada", "con_pendiente": false, "estado_administrativo": "administracion_completa"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.270008-05
15	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	administracion	liberacion_actualizada	liberacion_historial	324d4ae5-914e-4861-b5df-ed126865bd64	{"monto": null, "estado": null}	{"monto": 4850, "estado": "total"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.249641-05
14	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	administracion	oc_registrada	orden_compra	a4885b26-f263-44c9-a0c0-27a9b056d34e	\N	{"monto": 4850, "numero_oc": "4500231188"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.229154-05
13	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	administracion	solped_numero_sap	solped	7c3a47d5-5bb4-4a19-928e-836c0b5386f0	{"estado": "lista_para_enviar", "numero_sap": null}	{"estado": "creada_en_sap", "numero_sap": "0010045612"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.209901-05
12	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	administracion	solped_lista	solped	7c3a47d5-5bb4-4a19-928e-836c0b5386f0	{"estado": "borrador"}	{"estado": "lista_para_enviar"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.193085-05
11	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	administracion	solped_preparada	solped	7c3a47d5-5bb4-4a19-928e-836c0b5386f0	\N	{"version": 1, "numero_interno": "OT-000001-SP1"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.168676-05
10	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ejecucion	trabajo_revisado	trabajo_realizado	b02261e6-c664-4abb-bf31-fa2cf4420cce	\N	{"resultado": "aprobado"}		3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.151084-05
9	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ejecucion	trabajo_declarado	trabajo_realizado	b02261e6-c664-4abb-bf31-fa2cf4420cce	{"estado": "en_trabajo"}	{"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:15.13043-05:00", "version": 1}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.13043-05
8	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ejecucion	avance_registrado	ot_avance	6b424a1f-b2f0-4db2-9a11-fa76a416afae	\N	{"porcentaje": null}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.079298-05
7	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ejecucion	avance_registrado	ot_avance	97179a5b-66d0-4ded-bd2c-03374705e928	\N	{"porcentaje": null}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.063196-05
6	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ejecucion	ejecucion_iniciada	ejecucion	be7b33db-85f9-4955-953c-f4e24d864dcc	{"estado": "en_cotizacion"}	{"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.044115-05:00", "sin_cotizacion": false}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.044115-05
5	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	cotizacion	cotizacion_cargada	cotizacion	8ae2a1b6-3d59-429f-abbf-8ea949d00930	\N	{"monto": 4850, "moneda": "PEN", "version": 1}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.024621-05
4	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ot	estado_cambiado	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	{"estado": "en_diagnostico"}	{"estado": "en_cotizacion"}	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.024621-05
3	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	diagnostico	diagnostico_creado	diagnostico	6aaf55e9-be62-46ac-a9bb-9689b116d49f	\N	{"version": 1}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.003489-05
2	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ot	estado_cambiado	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-16 08:34:15.003489-05
1	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ot	ot_creada	orden_trabajo	be7b33db-85f9-4955-953c-f4e24d864dcc	\N	{"numero": "OT-000001", "emergencia": false, "desde_solicitud": "ST-000001"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:14.977113-05
93	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	costos	costo_registrado	costo_unitario	bb557a13-f183-4ac1-9125-fb9611f609d3	\N	{"monto": 2140, "fuente": "cotizacion", "moneda": "PEN"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:16.595734-05
27	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ot	ot_cerrada	ot_cierre	8dbee6e1-1ded-47bc-a602-bc993c5f6482	{"estado": "trabajo_realizado"}	{"estado": "cerrada", "con_pendiente": true, "estado_administrativo": "solped_pendiente"}	Compras emite la OC la próxima semana; el equipo ya está operativo.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.441202-05
26	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	administracion	solped_preparada	solped	ca6be66a-aa2f-4744-b6b3-77e1d9a58429	\N	{"version": 1, "numero_interno": "OT-000002-SP1"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.422972-05
25	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ejecucion	trabajo_revisado	trabajo_realizado	f5c474b7-fd66-41e9-8ef4-d907862cdd95	\N	{"resultado": "aprobado"}		3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.405957-05
24	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ejecucion	trabajo_declarado	trabajo_realizado	f5c474b7-fd66-41e9-8ef4-d907862cdd95	{"estado": "en_trabajo"}	{"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:15.386203-05:00", "version": 1}	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.386203-05
23	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ejecucion	avance_registrado	ot_avance	9032c5b9-7fa3-4221-847d-26ec63f47b93	\N	{"porcentaje": null}	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.370424-05
22	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ejecucion	ejecucion_iniciada	ejecucion	14cd082a-4bcd-4661-8837-c47c4f762342	{"estado": "en_cotizacion"}	{"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.350916-05:00", "sin_cotizacion": false}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.350916-05
21	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	cotizacion	cotizacion_cargada	cotizacion	941e9e9a-0613-4288-a4f9-17a68d17668f	\N	{"monto": 2140, "moneda": "PEN", "version": 1}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.333867-05
20	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ot	estado_cambiado	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	{"estado": "en_diagnostico"}	{"estado": "en_cotizacion"}	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.333867-05
19	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	diagnostico	diagnostico_creado	diagnostico	0d9044ca-0479-4db1-b404-af45ca79d91d	\N	{"version": 1}	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.317312-05
18	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ot	estado_cambiado	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-08-15 12:34:15.317312-05
17	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ot	ot_creada	orden_trabajo	14cd082a-4bcd-4661-8837-c47c4f762342	\N	{"numero": "OT-000002", "emergencia": false, "desde_solicitud": "ST-000002"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.302141-05
94	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	costos	costo_registrado	costo_unitario	b4822b6f-0886-49b1-b848-7010954b9f5c	\N	{"monto": 3290, "fuente": "cotizacion", "moneda": "PEN"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:16.620954-05
35	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	ejecucion	avance_registrado	ot_avance	710b89ee-4203-4297-a2cb-692b460048fd	\N	{"porcentaje": null}	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.566039-05
34	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	ejecucion	avance_registrado	ot_avance	59da0c27-04c6-4db4-b488-d899345240b6	\N	{"porcentaje": null}	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.549013-05
33	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	ejecucion	ejecucion_iniciada	ejecucion	569b23e3-2a8b-4dd7-9f5a-262524af1c93	{"estado": "en_cotizacion"}	{"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.529557-05:00", "sin_cotizacion": false}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.529557-05
32	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	cotizacion	cotizacion_cargada	cotizacion	8145f65b-f63d-4121-96eb-3a1e7775f9af	\N	{"monto": 3290, "moneda": "PEN", "version": 1}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.508809-05
31	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	ot	estado_cambiado	orden_trabajo	569b23e3-2a8b-4dd7-9f5a-262524af1c93	{"estado": "en_diagnostico"}	{"estado": "en_cotizacion"}	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.508809-05
30	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	diagnostico	diagnostico_creado	diagnostico	dd9a49f5-646a-4dbb-ac19-9b87263fc462	\N	{"version": 1}	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.490058-05
29	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	ot	estado_cambiado	orden_trabajo	569b23e3-2a8b-4dd7-9f5a-262524af1c93	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-08 05:34:15.490058-05
28	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	ot	ot_creada	orden_trabajo	569b23e3-2a8b-4dd7-9f5a-262524af1c93	\N	{"numero": "OT-000003", "emergencia": false, "desde_solicitud": "ST-000003"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.470721-05
95	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	costos	costo_registrado	costo_unitario	41d1dc1c-9f24-4d60-aff5-8e04ebbbd82b	\N	{"monto": 2850, "fuente": "cotizacion", "moneda": "PEN"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:16.643365-05
55	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	cotizacion	cotizacion_cargada	cotizacion	f9af5c86-a168-40ec-a440-0c0fc849c120	\N	{"monto": 2850, "moneda": "PEN", "version": 1}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:15.853975-05
54	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	ot	estado_cambiado	orden_trabajo	2b0e0c54-42f5-45ce-9ff5-10b069071a30	{"estado": "en_diagnostico"}	{"estado": "en_cotizacion"}	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:15.853975-05
53	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	diagnostico	diagnostico_creado	diagnostico	58f91adb-9c05-4eb7-8d60-ceedb7194255	\N	{"version": 1}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-13 06:34:15.836675-05
52	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	ot	estado_cambiado	orden_trabajo	2b0e0c54-42f5-45ce-9ff5-10b069071a30	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-13 06:34:15.836675-05
51	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	ot	ot_creada	orden_trabajo	2b0e0c54-42f5-45ce-9ff5-10b069071a30	\N	{"numero": "OT-000006", "emergencia": false, "desde_solicitud": "ST-000006"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:15.821136-05
71	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	ot	derivada_generada	orden_trabajo	a9859198-0a21-4309-8a00-2ca9a2cdc917	\N	{"numero": "OT-000011", "bloqueante": true}	El rectificado de la bomba va a un taller externo especializado.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-18 07:34:16.085222-05
69	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	ot	derivada_generada	orden_trabajo	ee9a06f5-0220-47a0-8e4a-d992333af106	\N	{"numero": "OT-000010", "bloqueante": true}	El módulo de control lo atiende el concesionario de la marca, con otro proveedor y otra contratación.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-18 07:34:16.051891-05
67	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	diagnostico	diagnostico_creado	diagnostico	18354423-f450-4025-9dd2-d33d2f45b580	\N	{"version": 1}	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-18 07:34:16.033936-05
66	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	ot	estado_cambiado	orden_trabajo	c7dd4771-3654-4aff-89a5-f7661193fb03	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-09-18 07:34:16.033936-05
65	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	ot	ot_creada	orden_trabajo	c7dd4771-3654-4aff-89a5-f7661193fb03	\N	{"numero": "OT-000009", "emergencia": false, "desde_solicitud": "ST-000009"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-18 07:34:16.012792-05
96	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	costos	costo_registrado	costo_unitario	1d69c883-fb44-477b-9c3f-971c74923db7	\N	{"monto": 1960, "fuente": "cotizacion", "moneda": "PEN"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.665161-05
79	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	ot	ot_cerrada	ot_cierre	fa696e6a-92fe-4d81-8afe-121994ed030e	{"estado": "trabajo_realizado"}	{"estado": "cerrada", "con_pendiente": true, "estado_administrativo": "sin_solped"}	Sin SOLPED: el gasto se imputó al contrato marco del taller externo.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.210247-05
78	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	ejecucion	trabajo_revisado	trabajo_realizado	204401ea-b3e8-4e6e-a8b1-6d503b51fe4e	\N	{"resultado": "aprobado"}		3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.194661-05
77	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	ejecucion	trabajo_declarado	trabajo_realizado	204401ea-b3e8-4e6e-a8b1-6d503b51fe4e	{"estado": "en_trabajo"}	{"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:16.17693-05:00", "version": 1}	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-08-06 15:34:16.17693-05
76	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	ejecucion	ejecucion_iniciada	ejecucion	a9859198-0a21-4309-8a00-2ca9a2cdc917	{"estado": "en_cotizacion"}	{"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:16.158376-05:00", "sin_cotizacion": false}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.158376-05
75	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	cotizacion	cotizacion_cargada	cotizacion	64dc018a-0a2e-45e7-913d-e1dcdf82baf9	\N	{"monto": 1960, "moneda": "PEN", "version": 1}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.140996-05
74	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	ot	estado_cambiado	orden_trabajo	a9859198-0a21-4309-8a00-2ca9a2cdc917	{"estado": "en_diagnostico"}	{"estado": "en_cotizacion"}	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.140996-05
73	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	diagnostico	diagnostico_creado	diagnostico	791fa998-20f5-400d-878e-5ee9b4313624	\N	{"version": 1}	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-08-06 15:34:16.122692-05
72	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	ot	estado_cambiado	orden_trabajo	a9859198-0a21-4309-8a00-2ca9a2cdc917	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	2026-08-06 15:34:16.122692-05
70	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	ot	derivada_creada	orden_trabajo	a9859198-0a21-4309-8a00-2ca9a2cdc917	\N	{"padre": "OT-000009", "numero": "OT-000011", "bloqueante": true}	El rectificado de la bomba va a un taller externo especializado.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.085222-05
97	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	costos	costo_registrado	costo_unitario	14537c4c-089f-4ae2-8a1d-55d0275cede5	\N	{"monto": 980, "fuente": "cotizacion", "moneda": "PEN"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.69545-05
91	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ot	ot_reabierta	ot_reapertura	3b98dccc-1961-4ef9-adb9-25d7b7097771	{"estado": "cerrada", "cierre_secuencia": 1}	{"estado": "en_trabajo"}	La presión volvió a caer a los cuatro días; la fuga no era sólo la retención.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.42939-05
90	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ot	ot_cerrada	ot_cierre	008864e3-0723-4b63-924b-a66243c6b139	{"estado": "trabajo_realizado"}	{"estado": "cerrada", "con_pendiente": true, "estado_administrativo": "sin_solped"}	Gasto menor imputado a caja chica; sin SOLPED.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.407424-05
89	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ejecucion	trabajo_revisado	trabajo_realizado	b847fac3-a71a-4834-87b7-ffc96912e573	\N	{"resultado": "aprobado"}		3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.391197-05
88	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ejecucion	trabajo_declarado	trabajo_realizado	b847fac3-a71a-4834-87b7-ffc96912e573	{"estado": "en_trabajo"}	{"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:16.372475-05:00", "version": 1}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-29 12:34:16.372475-05
87	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ejecucion	ejecucion_iniciada	ejecucion	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	{"estado": "en_cotizacion"}	{"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:16.35434-05:00", "sin_cotizacion": false}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.35434-05
86	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	cotizacion	cotizacion_cargada	cotizacion	c04db5da-741c-4f8c-af00-8f461a5a55f3	\N	{"monto": 980, "moneda": "PEN", "version": 1}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.336221-05
85	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ot	estado_cambiado	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	{"estado": "en_diagnostico"}	{"estado": "en_cotizacion"}	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.336221-05
84	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	diagnostico	diagnostico_creado	diagnostico	d0368a13-9b72-498c-8baa-8b92ca667a0e	\N	{"version": 1}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-29 12:34:16.320121-05
83	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ot	estado_cambiado	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-08-29 12:34:16.320121-05
82	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ot	ot_creada	orden_trabajo	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	\N	{"numero": "OT-000013", "emergencia": false, "desde_solicitud": "ST-000011"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.304342-05
98	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	costos	costo_registrado	costo_unitario	fc517ca7-0336-4c07-bdaf-14a8235105df	\N	{"monto": 1180, "fuente": "cotizacion", "moneda": "PEN"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:16.717544-05
50	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	ejecucion	trabajo_declarado	trabajo_realizado	7f6624ce-bf77-4289-ba48-4ca5a7a3a478	{"estado": "en_trabajo"}	{"estado": "trabajo_realizado", "termino": "2026-09-20T15:34:15.795487-05:00", "version": 1}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-06 13:34:15.795487-05
49	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	ejecucion	ejecucion_iniciada	ejecucion	bd61bf6d-abeb-487f-91eb-3281f93643f0	{"estado": "en_cotizacion"}	{"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.777671-05:00", "sin_cotizacion": false}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.777671-05
48	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	cotizacion	cotizacion_cargada	cotizacion	fee02c0d-bc83-47cd-b082-7f25428e0fd3	\N	{"monto": 1180, "moneda": "PEN", "version": 1}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.759791-05
47	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	ot	estado_cambiado	orden_trabajo	bd61bf6d-abeb-487f-91eb-3281f93643f0	{"estado": "en_diagnostico"}	{"estado": "en_cotizacion"}	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.759791-05
46	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	diagnostico	diagnostico_creado	diagnostico	f02374ce-1ee7-40b8-99c8-e794d5c77646	\N	{"version": 1}	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-06 13:34:15.742902-05
45	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	ot	estado_cambiado	orden_trabajo	bd61bf6d-abeb-487f-91eb-3281f93643f0	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	5a11b0c5-7640-494f-9c8b-64a9a4e30673	2026-09-06 13:34:15.742902-05
44	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	ot	ot_creada	orden_trabajo	bd61bf6d-abeb-487f-91eb-3281f93643f0	\N	{"numero": "OT-000005", "emergencia": false, "desde_solicitud": "ST-000005"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.727191-05
99	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	costos	costo_registrado	costo_unitario	beea5c0c-b75b-4c50-b8d1-8c9b3f6ed775	\N	{"monto": 7800, "fuente": "cotizacion", "moneda": "PEN"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:16.739821-05
43	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	ejecucion	pausa_registrada	ot_pausa	fe3821cc-f565-4013-b805-aedc97cf74c3	\N	{"fecha_pausa": "2026-09-20T15:34:15.698235-05:00"}	Esperando la celda importada; el proveedor confirma tres semanas.	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.698235-05
42	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	ejecucion	avance_registrado	ot_avance	7832fa1d-ab85-42d8-aa41-9cf35ce2ca5e	\N	{"porcentaje": null}	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-07 09:34:15.682034-05
41	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	ejecucion	ejecucion_iniciada	ejecucion	1400addf-2f07-4784-a1f6-62c95da13ef1	{"estado": "en_cotizacion"}	{"estado": "en_trabajo", "inicio_real": "2026-09-20T15:34:15.663697-05:00", "sin_cotizacion": false}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.663697-05
40	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	cotizacion	cotizacion_cargada	cotizacion	20dd8496-ea84-44bb-8740-a36c597b1147	\N	{"monto": 7800, "moneda": "PEN", "version": 1}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.645482-05
39	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	ot	estado_cambiado	orden_trabajo	1400addf-2f07-4784-a1f6-62c95da13ef1	{"estado": "en_diagnostico"}	{"estado": "en_cotizacion"}	Cotización seleccionada cargada	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.645482-05
38	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	diagnostico	diagnostico_creado	diagnostico	ea9f0825-89c1-4aae-a404-c87094cfea37	\N	{"version": 1}	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-07 09:34:15.627826-05
37	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	ot	estado_cambiado	orden_trabajo	1400addf-2f07-4784-a1f6-62c95da13ef1	{"estado": "creada"}	{"estado": "en_diagnostico"}	Primer diagnóstico registrado	a7ee34e2-43bd-496d-99b0-ad8013072cea	2026-09-07 09:34:15.627826-05
36	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	ot	ot_creada	orden_trabajo	1400addf-2f07-4784-a1f6-62c95da13ef1	\N	{"numero": "OT-000004", "emergencia": false, "desde_solicitud": "ST-000004"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.610587-05
100	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	ejecucion	adjunto_cargado	cotizacion	8145f65b-f63d-4121-96eb-3a1e7775f9af	\N	{"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0421.pdf"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:17.539707-05
101	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	ejecucion	adjunto_cargado	cotizacion	c04db5da-741c-4f8c-af00-8f461a5a55f3	\N	{"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0440.pdf"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:17.581748-05
102	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	ejecucion	adjunto_cargado	cotizacion	8ae2a1b6-3d59-429f-abbf-8ea949d00930	\N	{"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0412.pdf"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:17.622807-05
103	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	ejecucion	adjunto_cargado	cotizacion	941e9e9a-0613-4288-a4f9-17a68d17668f	\N	{"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0418.pdf"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:17.673677-05
104	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	ejecucion	adjunto_cargado	cotizacion	64dc018a-0a2e-45e7-913d-e1dcdf82baf9	\N	{"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0436.pdf"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:17.711979-05
105	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	ejecucion	adjunto_cargado	cotizacion	f9af5c86-a168-40ec-a440-0c0fc849c120	\N	{"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0433.pdf"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:17.750313-05
106	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	ejecucion	adjunto_cargado	cotizacion	20dd8496-ea84-44bb-8740-a36c597b1147	\N	{"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0425.pdf"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:17.788369-05
107	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	ejecucion	adjunto_cargado	cotizacion	fee02c0d-bc83-47cd-b082-7f25428e0fd3	\N	{"tipo": "pdf", "etapa": "cotizacion", "nombre": "COT-2026-0430.pdf"}	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:17.827492-05
\.


--
-- Data for Name: ot_incidencia; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.ot_incidencia (id, tenant_id, ot_id, tipo_id, descripcion, resuelta, resuelta_at, resolucion, autor_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ot_pausa; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.ot_pausa (id, tenant_id, ot_id, motivo_id, motivo_texto, fecha_pausa, fecha_reanudacion, observacion_reanudacion, pausada_por, reanudada_por, created_at, updated_at) FROM stdin;
fe3821cc-f565-4013-b805-aedc97cf74c3	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	\N	Esperando la celda importada; el proveedor confirma tres semanas.	2026-09-07 09:34:15.698235-05	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	2026-09-07 09:34:15.698235-05	2026-09-20 15:34:16.878667-05
\.


--
-- Data for Name: ot_reapertura; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.ot_reapertura (id, tenant_id, ot_id, cierre_id, motivo_id, motivo_texto, estado_retorno, reabierta_por, created_at) FROM stdin;
3b98dccc-1961-4ef9-adb9-25d7b7097771	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	008864e3-0723-4b63-924b-a66243c6b139	\N	La presión volvió a caer a los cuatro días; la fuga no era sólo la retención.	en_trabajo	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.42939-05
\.


--
-- Data for Name: permiso; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.permiso (id, codigo, modulo, accion, descripcion, created_at) FROM stdin;
37ec6c33-adfc-48fb-921c-8b6cf5cb070b	solicitudes:crear	solicitudes	crear	Registrar una solicitud de trabajo	2026-08-22 22:53:35.584032-05
d67842c2-c640-4da4-be3a-707f6ff34052	solicitudes:listar	solicitudes	listar	Consultar solicitudes dentro del alcance	2026-08-22 22:53:35.584032-05
22b86620-318f-419d-aac3-cd861258b1b0	solicitudes:decidir	solicitudes	decidir	Revisar y decidir sobre una solicitud	2026-08-22 22:53:35.584032-05
5cb701aa-fe88-4c8f-b6b6-c6027b6f701f	ot:crear	ot	crear	Convertir una solicitud en OT	2026-08-22 22:53:35.584032-05
14f776f1-0bb2-4522-9a86-60fc11df7baf	ot:editar	ot	editar	Editar el contexto técnico de una OT	2026-08-22 22:53:35.584032-05
7e36af66-0214-4c43-92bb-5a7efa498206	ot:listar	ot	listar	Consultar el listado de OT	2026-08-22 22:53:35.584032-05
4bd5df0b-d9ce-4702-ba7e-0afe1aa450ff	ot:ver	ot	ver	Ver la ficha y la trazabilidad de una OT	2026-08-22 22:53:35.584032-05
df857e48-6e1b-43c5-87b9-cfd89eb6d972	ot:cambiar_estado	ot	cambiar_estado	Ejecutar transiciones de estado de la OT	2026-08-22 22:53:35.584032-05
3160eb08-5cf2-44d2-a65e-24275289aea9	ot:cambiar_prioridad	ot	cambiar_prioridad	Cambiar la prioridad técnica	2026-08-22 22:53:35.584032-05
3844d92a-9825-45f9-9041-7bffaf42921c	ot:derivar	ot	derivar	Crear OT derivadas	2026-08-22 22:53:35.584032-05
9bc25e60-c342-4235-bf29-f2b03fc764e1	ot:cancelar	ot	cancelar	Cancelar una OT	2026-08-22 22:53:35.584032-05
01ec1a04-2b9a-4900-9850-afe71713013c	ot:revisar	ot	revisar	Revisar el trabajo realizado	2026-08-22 22:53:35.584032-05
0d920c26-b213-491b-9dd6-3349f93ecbcd	ot:cerrar	ot	cerrar	Cerrar técnicamente una OT	2026-08-22 22:53:35.584032-05
1dc564f2-c459-4982-87ad-f967f7dcf9ea	ot:reabrir	ot	reabrir	Reabrir una OT cerrada	2026-08-22 22:53:35.584032-05
02398316-b1eb-49f3-b3d8-535f304ddea5	diagnosticos:registrar	diagnosticos	registrar	Registrar o versionar un diagnóstico	2026-08-22 22:53:35.584032-05
44830715-9cba-432d-9753-c981c6a3d8ce	diagnosticos:aprobar	diagnosticos	aprobar	Aprobar el diagnóstico vigente	2026-08-22 22:53:35.584032-05
776b0a37-c0d1-427c-a1b7-0508d36eaa9c	cotizaciones:cargar	cotizaciones	cargar	Cargar o reemplazar la cotización seleccionada	2026-08-22 22:53:35.584032-05
6103617d-9a8b-42eb-abec-fd656ee93c3e	cotizaciones:ver	cotizaciones	ver	Ver cotizaciones de la OT	2026-08-22 22:53:35.584032-05
3b6aad8a-3ce3-4743-b7e4-c31ab360bb4a	ejecucion:iniciar	ejecucion	iniciar	Iniciar la ejecución de una OT	2026-08-22 22:53:35.584032-05
e932a93a-f6e7-4f99-bce5-4f6efa066b52	ejecucion:avanzar	ejecucion	avanzar	Registrar avances e incidencias	2026-08-22 22:53:35.584032-05
c61cfe7f-ae2a-4e82-b0a6-24df1c4c4436	ejecucion:pausar	ejecucion	pausar	Pausar y reanudar la ejecución	2026-08-22 22:53:35.584032-05
7117a920-70de-4fe0-8255-a7f05a177632	ejecucion:declarar_trabajo	ejecucion	declarar_trabajo	Declarar el trabajo realizado	2026-08-22 22:53:35.584032-05
3d300060-c1f7-4fbb-aa09-17821b04f12f	administrativo:ver	administrativo	ver	Ver el seguimiento administrativo	2026-08-22 22:53:35.584032-05
dcf728a9-be62-4232-b7f2-c2161c7db168	administrativo:solped	administrativo	solped	Preparar, enviar y regularizar SOLPED	2026-08-22 22:53:35.584032-05
db78103b-2e9d-4417-bf5c-b6522986963b	administrativo:oc	administrativo	oc	Registrar órdenes de compra	2026-08-22 22:53:35.584032-05
d6b26e4d-f611-4251-99ea-53786c63b37e	administrativo:liberacion	administrativo	liberacion	Registrar liberaciones	2026-08-22 22:53:35.584032-05
5de6e54c-0f2e-4202-bf07-6d32cfd60d5f	conversacion:escribir	conversacion	escribir	Participar en la conversación de la OT	2026-08-22 22:53:35.584032-05
0b5c7bf4-86a1-4ea2-8445-052018482bdd	conversacion:invitar	conversacion	invitar	Incorporar participantes a la conversación	2026-08-22 22:53:35.584032-05
b03bc964-f3d4-499a-9f4c-1603092a8d19	adjuntos:cargar	adjuntos	cargar	Adjuntar evidencias y documentos	2026-08-22 22:53:35.584032-05
86531193-3e84-4a81-adb5-0e09ff7495eb	adjuntos:retirar	adjuntos	retirar	Retirar lógicamente un adjunto	2026-08-22 22:53:35.584032-05
8faa5549-3f37-411c-ac48-2331a7b27111	costos:ver	costos	ver	Consultar costos e históricos	2026-08-22 22:53:35.584032-05
48b300ae-0436-4e33-99e1-bd6421b78977	costos:registrar	costos	registrar	Registrar y calificar costos unitarios	2026-08-22 22:53:35.584032-05
f98716ce-7f5f-48b8-b70b-e2837159ba47	reportes:ver	reportes	ver	Consultar dashboards y reportes	2026-08-22 22:53:35.584032-05
0fab9267-442b-4cd4-a691-6f5c8b7de428	auditoria:ver	auditoria	ver	Consultar la auditoría técnica	2026-08-22 22:53:35.584032-05
d085dc8c-0336-4f5c-a618-d28399a15143	usuarios:listar	usuarios	listar	Consultar usuarios	2026-08-22 22:53:35.584032-05
25d9098a-da65-4fb2-aabe-35eb9b76972a	usuarios:crear	usuarios	crear	Crear usuarios	2026-08-22 22:53:35.584032-05
ad600020-3779-4926-b5a8-a7d5f7d0f243	usuarios:editar	usuarios	editar	Editar o inactivar usuarios	2026-08-22 22:53:35.584032-05
d132a406-6d39-4f59-90f3-7ea8546b0a87	roles:listar	roles	listar	Consultar roles y permisos	2026-08-22 22:53:35.584032-05
ec97f3c5-64fe-4dd4-8375-ebbd00177f28	roles:editar	roles	editar	Asignar permisos a roles	2026-08-22 22:53:35.584032-05
b5ece096-c3c9-4887-a723-4fcf1a886a39	organizacion:crear	organizacion	crear	Crear sucursales, empresas/RUC y áreas	2026-08-22 22:53:35.584032-05
d40ceadf-d9be-43a8-b4f4-b785bcdde9b3	organizacion:editar	organizacion	editar	Editar o inactivar la organización	2026-08-22 22:53:35.584032-05
50536bbd-45b9-473a-8c11-51424156a49b	catalogos:crear	catalogos	crear	Crear ítems de catálogo y tipos de trabajo	2026-08-22 22:53:35.584032-05
9efbdd0b-077a-4b11-b74e-514bda463c4b	proveedores:crear	proveedores	crear	Registrar proveedores	2026-08-22 22:53:35.584032-05
fbcea506-58cf-4aaf-bbff-785bc299da48	configuracion:editar	configuracion	editar	Cambiar la configuración del tenant	2026-08-22 22:53:35.584032-05
\.


--
-- Data for Name: proveedor; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.proveedor (id, tenant_id, ruc, razon_social, contacto, telefono, email, estado, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
65d951bb-e837-4af9-9d40-218eb27f8abc	5c921062-21ab-4a01-8f9a-2e2500e95893	20512345671	SERVICIOS NEUMÁTICOS DEL PERÚ S.A.C.	Luis Bravo	987654321	\N	activo	2026-09-20 00:24:41.482359-05	2026-09-20 00:24:41.482359-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
2dc1f1f5-4c5b-40d8-aeaf-1cad7d293eb7	5c921062-21ab-4a01-8f9a-2e2500e95893	20487654320	ELECTROMONTAJES ANDINOS S.R.L.	Sonia Rojas	986123456	\N	activo	2026-09-20 00:24:41.487479-05	2026-09-20 00:24:41.487479-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
e33609de-3734-4b1b-badf-f08ce365c2a2	5c921062-21ab-4a01-8f9a-2e2500e95893	20456789014	HIDRÁULICA INDUSTRIAL LIMA S.A.C.	Jorge Salas	985222111	\N	activo	2026-09-20 00:24:41.49207-05	2026-09-20 00:24:41.49207-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
74322f64-4408-4da3-b4af-f6e53dbcf203	5c921062-21ab-4a01-8f9a-2e2500e95893	20398765436	INSTRUMENTACIÓN Y CONTROL S.A.	Rocío Prado	984333222	\N	activo	2026-09-20 00:24:41.49704-05	2026-09-20 00:24:41.49704-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
d78f64df-a44d-4ed8-a2b2-3ca5a7b26955	5c921062-21ab-4a01-8f9a-2e2500e95893	20555123451	RECTIFICACIONES DEL SUR S.A.C.	Iván Flores	983444333	\N	activo	2026-09-20 00:24:41.501705-05	2026-09-20 00:24:41.501705-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
b89663d0-2b51-40b1-8e21-488ff2328367	5c921062-21ab-4a01-8f9a-2e2500e95893	20567890121	PUERTAS Y ACCESOS INDUSTRIALES E.I.R.L.	Dora Lino	982555444	\N	activo	2026-09-20 00:24:41.506569-05	2026-09-20 00:24:41.506569-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
6347f0eb-53cf-41d2-8df5-32cf26fb5a74	5c921062-21ab-4a01-8f9a-2e2500e95893	20601234565	SISTEMAS CONTRA INCENDIO S.A.C.	Raúl Cáceres	981666555	\N	activo	2026-09-20 00:24:41.513189-05	2026-09-20 00:24:41.513189-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Data for Name: regla_normalizacion; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.regla_normalizacion (id, tenant_id, patron, descripcion_normalizada_id, confianza, aprobada, aprobada_por, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: rol; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.rol (id, tenant_id, codigo, nombre, descripcion, scope, es_sistema, created_at, updated_at, deleted_at) FROM stdin;
d0d339c8-0f65-4160-b047-5dd489e91b75	\N	solicitante	Solicitante	Registra necesidades, aporta evidencia, consulta sus casos y conversa.	tenant	t	2026-08-22 22:53:35.588434-05	2026-08-22 22:53:35.588434-05	\N
b22b1e1d-7bd6-492b-b847-075d26e65ce9	\N	tecnico	Técnico	Apoya el diagnóstico, registra avances y declara el trabajo realizado.	tenant	t	2026-08-22 22:53:35.588434-05	2026-08-22 22:53:35.588434-05	\N
0a107d58-4871-4315-a8a8-0766f98576bf	\N	coordinador	Coordinador de mantenimiento	Dueño del ciclo técnico: revisa solicitudes, crea y cierra OT, dirige diagnóstico y ejecución.	tenant	t	2026-08-22 22:53:35.588434-05	2026-08-22 22:53:35.588434-05	\N
bacda630-34e8-4c9a-9e0d-2385c2789e31	\N	abastecimiento	Abastecimiento	Apoya la carga de cotización, la preparación administrativa y el seguimiento.	tenant	t	2026-08-22 22:53:35.588434-05	2026-08-22 22:53:35.588434-05	\N
5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	\N	administrador	Administrador	Gestiona usuarios, roles, catálogos, configuración e integraciones.	tenant	t	2026-08-22 22:53:35.588434-05	2026-08-22 22:53:35.588434-05	\N
8073c2fc-42e1-4c32-b29f-6fc8fb62d065	\N	gerencia	Gerencia / consulta	Consulta KPIs, dashboards y reportes. Sin cambios operativos.	tenant	t	2026-08-22 22:53:35.588434-05	2026-08-22 22:53:35.588434-05	\N
dddfee51-13c2-4ce5-82ea-f94e98b4b675	\N	super_admin	Super administrador	Administración de la plataforma MIP, por encima del tenant.	global	t	2026-08-22 22:53:35.588434-05	2026-08-22 22:53:35.588434-05	\N
\.


--
-- Data for Name: rol_permiso; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.rol_permiso (id, rol_id, permiso_id, created_at) FROM stdin;
c33c5531-0dc9-4535-9c8d-1a7db31ee8de	b22b1e1d-7bd6-492b-b847-075d26e65ce9	37ec6c33-adfc-48fb-921c-8b6cf5cb070b	2026-08-22 22:53:35.592355-05
791bddee-b9ea-4558-b841-3e237756c01a	b22b1e1d-7bd6-492b-b847-075d26e65ce9	d67842c2-c640-4da4-be3a-707f6ff34052	2026-08-22 22:53:35.592355-05
d0edae32-c0ca-4f60-8ad6-a39e2051dfe3	b22b1e1d-7bd6-492b-b847-075d26e65ce9	7e36af66-0214-4c43-92bb-5a7efa498206	2026-08-22 22:53:35.592355-05
329cebf8-2436-4f48-839b-594b20790eb0	b22b1e1d-7bd6-492b-b847-075d26e65ce9	4bd5df0b-d9ce-4702-ba7e-0afe1aa450ff	2026-08-22 22:53:35.592355-05
2f26b3d9-f4df-4971-a42d-9dc3d3a74ceb	b22b1e1d-7bd6-492b-b847-075d26e65ce9	02398316-b1eb-49f3-b3d8-535f304ddea5	2026-08-22 22:53:35.592355-05
0006eb2c-e83a-43a1-a5bf-81fdf2fb0a05	b22b1e1d-7bd6-492b-b847-075d26e65ce9	e932a93a-f6e7-4f99-bce5-4f6efa066b52	2026-08-22 22:53:35.592355-05
44775b80-fb5e-49f3-a98d-8939ff5f698c	b22b1e1d-7bd6-492b-b847-075d26e65ce9	c61cfe7f-ae2a-4e82-b0a6-24df1c4c4436	2026-08-22 22:53:35.592355-05
272670ad-855a-4180-af05-5036e8572d57	b22b1e1d-7bd6-492b-b847-075d26e65ce9	7117a920-70de-4fe0-8255-a7f05a177632	2026-08-22 22:53:35.592355-05
c59de78d-99ee-4aae-b7ba-404d2a5bcf7e	b22b1e1d-7bd6-492b-b847-075d26e65ce9	5de6e54c-0f2e-4202-bf07-6d32cfd60d5f	2026-08-22 22:53:35.592355-05
f2e3fb5c-01c7-4dfe-9242-086a9435d521	b22b1e1d-7bd6-492b-b847-075d26e65ce9	b03bc964-f3d4-499a-9f4c-1603092a8d19	2026-08-22 22:53:35.592355-05
aa0e50d2-e1b0-44e4-a285-36989fd1b017	b22b1e1d-7bd6-492b-b847-075d26e65ce9	6103617d-9a8b-42eb-abec-fd656ee93c3e	2026-08-22 22:53:35.592355-05
715aa9ea-b405-4d69-a3bc-66058dbe8a9f	8073c2fc-42e1-4c32-b29f-6fc8fb62d065	7e36af66-0214-4c43-92bb-5a7efa498206	2026-08-22 22:53:35.592355-05
ad5e297e-4481-48b2-a8d6-1974ad364b15	8073c2fc-42e1-4c32-b29f-6fc8fb62d065	4bd5df0b-d9ce-4702-ba7e-0afe1aa450ff	2026-08-22 22:53:35.592355-05
31b1a059-d486-4d5d-8ed2-8e1dab55de24	8073c2fc-42e1-4c32-b29f-6fc8fb62d065	6103617d-9a8b-42eb-abec-fd656ee93c3e	2026-08-22 22:53:35.592355-05
b4e030ef-4db4-4aaa-8ce5-d75ee48a72db	8073c2fc-42e1-4c32-b29f-6fc8fb62d065	3d300060-c1f7-4fbb-aa09-17821b04f12f	2026-08-22 22:53:35.592355-05
598f1878-bca1-4f6d-a0e7-daa1176ad037	8073c2fc-42e1-4c32-b29f-6fc8fb62d065	8faa5549-3f37-411c-ac48-2331a7b27111	2026-08-22 22:53:35.592355-05
57131668-929b-4ad7-96ea-fae0cf5127e5	8073c2fc-42e1-4c32-b29f-6fc8fb62d065	f98716ce-7f5f-48b8-b70b-e2837159ba47	2026-08-22 22:53:35.592355-05
60a2ff62-0564-4e6b-ac88-03880c14f02f	0a107d58-4871-4315-a8a8-0766f98576bf	37ec6c33-adfc-48fb-921c-8b6cf5cb070b	2026-08-22 22:53:35.592355-05
b642d14e-0197-449a-b766-4fc59cd7ad59	0a107d58-4871-4315-a8a8-0766f98576bf	d67842c2-c640-4da4-be3a-707f6ff34052	2026-08-22 22:53:35.592355-05
4922d879-b995-446e-8fc2-81c5e357e43c	0a107d58-4871-4315-a8a8-0766f98576bf	22b86620-318f-419d-aac3-cd861258b1b0	2026-08-22 22:53:35.592355-05
a170984d-96ea-4a1c-81a3-021858144eb3	0a107d58-4871-4315-a8a8-0766f98576bf	5cb701aa-fe88-4c8f-b6b6-c6027b6f701f	2026-08-22 22:53:35.592355-05
c2e06804-aaff-4f22-9756-417cd36c2fd3	0a107d58-4871-4315-a8a8-0766f98576bf	14f776f1-0bb2-4522-9a86-60fc11df7baf	2026-08-22 22:53:35.592355-05
8c6de379-99b0-41a1-bfdc-e65eb39bce80	0a107d58-4871-4315-a8a8-0766f98576bf	7e36af66-0214-4c43-92bb-5a7efa498206	2026-08-22 22:53:35.592355-05
ac970162-dce7-44f1-a46e-56f1c7036503	0a107d58-4871-4315-a8a8-0766f98576bf	4bd5df0b-d9ce-4702-ba7e-0afe1aa450ff	2026-08-22 22:53:35.592355-05
26dd110e-f199-4eb5-94f7-f1a201c8c887	0a107d58-4871-4315-a8a8-0766f98576bf	df857e48-6e1b-43c5-87b9-cfd89eb6d972	2026-08-22 22:53:35.592355-05
0c8b4de8-d761-4ece-bce1-49e50958dbdd	0a107d58-4871-4315-a8a8-0766f98576bf	3160eb08-5cf2-44d2-a65e-24275289aea9	2026-08-22 22:53:35.592355-05
53f7c334-8488-4a88-98e2-4efb3d46c901	0a107d58-4871-4315-a8a8-0766f98576bf	3844d92a-9825-45f9-9041-7bffaf42921c	2026-08-22 22:53:35.592355-05
c1e7643a-bdd7-418b-81ba-fd8d1747b951	0a107d58-4871-4315-a8a8-0766f98576bf	9bc25e60-c342-4235-bf29-f2b03fc764e1	2026-08-22 22:53:35.592355-05
3b2c5716-1b06-4734-9435-ba12d4aba297	0a107d58-4871-4315-a8a8-0766f98576bf	01ec1a04-2b9a-4900-9850-afe71713013c	2026-08-22 22:53:35.592355-05
4a56bd0d-3b2c-4999-becd-7bf5adca7f33	0a107d58-4871-4315-a8a8-0766f98576bf	0d920c26-b213-491b-9dd6-3349f93ecbcd	2026-08-22 22:53:35.592355-05
422e1da8-7349-44e0-9e68-148f57d6a4e6	0a107d58-4871-4315-a8a8-0766f98576bf	1dc564f2-c459-4982-87ad-f967f7dcf9ea	2026-08-22 22:53:35.592355-05
bb558156-b5ad-4dc0-9737-bf9ed851e708	0a107d58-4871-4315-a8a8-0766f98576bf	02398316-b1eb-49f3-b3d8-535f304ddea5	2026-08-22 22:53:35.592355-05
126640a0-89c7-47bd-9c20-350acbf359f2	0a107d58-4871-4315-a8a8-0766f98576bf	44830715-9cba-432d-9753-c981c6a3d8ce	2026-08-22 22:53:35.592355-05
d38a0229-7e09-4af5-b8b3-5e3dd2271847	0a107d58-4871-4315-a8a8-0766f98576bf	776b0a37-c0d1-427c-a1b7-0508d36eaa9c	2026-08-22 22:53:35.592355-05
b957ccf2-b5dd-46fb-9d98-2c2ddd9d9147	0a107d58-4871-4315-a8a8-0766f98576bf	6103617d-9a8b-42eb-abec-fd656ee93c3e	2026-08-22 22:53:35.592355-05
91add7d4-e988-4faa-ba25-b2bf022f65bd	0a107d58-4871-4315-a8a8-0766f98576bf	3b6aad8a-3ce3-4743-b7e4-c31ab360bb4a	2026-08-22 22:53:35.592355-05
61a1d190-a249-42d0-b07c-3225aa76d626	0a107d58-4871-4315-a8a8-0766f98576bf	e932a93a-f6e7-4f99-bce5-4f6efa066b52	2026-08-22 22:53:35.592355-05
37e59b41-3a91-4e3e-abb7-025ed147c22f	0a107d58-4871-4315-a8a8-0766f98576bf	c61cfe7f-ae2a-4e82-b0a6-24df1c4c4436	2026-08-22 22:53:35.592355-05
be6293ab-2dca-47c0-80b4-b4a5ac65edae	0a107d58-4871-4315-a8a8-0766f98576bf	7117a920-70de-4fe0-8255-a7f05a177632	2026-08-22 22:53:35.592355-05
a57fc053-b83f-4b02-90e5-e55f99a01a46	0a107d58-4871-4315-a8a8-0766f98576bf	3d300060-c1f7-4fbb-aa09-17821b04f12f	2026-08-22 22:53:35.592355-05
1a51a015-1044-43dd-9f39-aa17c9b6328d	0a107d58-4871-4315-a8a8-0766f98576bf	dcf728a9-be62-4232-b7f2-c2161c7db168	2026-08-22 22:53:35.592355-05
3a63906c-f916-4286-96d6-0acba9f2eaf0	0a107d58-4871-4315-a8a8-0766f98576bf	db78103b-2e9d-4417-bf5c-b6522986963b	2026-08-22 22:53:35.592355-05
507375c0-58e5-4450-893b-872acc7e6cf4	0a107d58-4871-4315-a8a8-0766f98576bf	d6b26e4d-f611-4251-99ea-53786c63b37e	2026-08-22 22:53:35.592355-05
e804e5c7-dc34-44be-a5c6-a9b10817925d	0a107d58-4871-4315-a8a8-0766f98576bf	5de6e54c-0f2e-4202-bf07-6d32cfd60d5f	2026-08-22 22:53:35.592355-05
2b0baf72-73f1-47e9-84e0-5135ac3855d2	0a107d58-4871-4315-a8a8-0766f98576bf	0b5c7bf4-86a1-4ea2-8445-052018482bdd	2026-08-22 22:53:35.592355-05
7d0a2340-3a45-4f70-b159-ad512399448d	0a107d58-4871-4315-a8a8-0766f98576bf	b03bc964-f3d4-499a-9f4c-1603092a8d19	2026-08-22 22:53:35.592355-05
7675ee0c-b885-4c37-b40b-4a7732a0c3bc	0a107d58-4871-4315-a8a8-0766f98576bf	86531193-3e84-4a81-adb5-0e09ff7495eb	2026-08-22 22:53:35.592355-05
10ea50e7-6a32-4040-9311-366a11a7a312	0a107d58-4871-4315-a8a8-0766f98576bf	8faa5549-3f37-411c-ac48-2331a7b27111	2026-08-22 22:53:35.592355-05
1bf00408-df65-40a1-a57b-7f969963df33	0a107d58-4871-4315-a8a8-0766f98576bf	48b300ae-0436-4e33-99e1-bd6421b78977	2026-08-22 22:53:35.592355-05
fb9d3e09-ff35-42fe-92dd-8a72c8f3f915	0a107d58-4871-4315-a8a8-0766f98576bf	f98716ce-7f5f-48b8-b70b-e2837159ba47	2026-08-22 22:53:35.592355-05
d3e4bbbb-33cc-4901-a733-ce84424363af	d0d339c8-0f65-4160-b047-5dd489e91b75	37ec6c33-adfc-48fb-921c-8b6cf5cb070b	2026-08-22 22:53:35.592355-05
1a6a4ef9-933f-4cc2-8d97-138f419c5e51	d0d339c8-0f65-4160-b047-5dd489e91b75	d67842c2-c640-4da4-be3a-707f6ff34052	2026-08-22 22:53:35.592355-05
6a4b37b7-2f47-4f2a-bae3-e53409583adc	d0d339c8-0f65-4160-b047-5dd489e91b75	4bd5df0b-d9ce-4702-ba7e-0afe1aa450ff	2026-08-22 22:53:35.592355-05
49d603c6-2524-4163-9888-00d2fe670802	d0d339c8-0f65-4160-b047-5dd489e91b75	5de6e54c-0f2e-4202-bf07-6d32cfd60d5f	2026-08-22 22:53:35.592355-05
0b342a71-0c1b-47c0-a2ae-0b4bda79aa0e	d0d339c8-0f65-4160-b047-5dd489e91b75	b03bc964-f3d4-499a-9f4c-1603092a8d19	2026-08-22 22:53:35.592355-05
be170179-93fc-439e-854f-028e35eb5f5c	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	d085dc8c-0336-4f5c-a618-d28399a15143	2026-08-22 22:53:35.592355-05
b036cd7c-4039-4dd1-b07d-d191984699ad	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	25d9098a-da65-4fb2-aabe-35eb9b76972a	2026-08-22 22:53:35.592355-05
6175fc9b-9882-4079-adfd-391ac8c4e05e	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	ad600020-3779-4926-b5a8-a7d5f7d0f243	2026-08-22 22:53:35.592355-05
12ad47c5-7547-4904-b08f-9292be13b247	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	d132a406-6d39-4f59-90f3-7ea8546b0a87	2026-08-22 22:53:35.592355-05
f1700a27-5c2c-4c02-b182-a4d15ee8133b	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	ec97f3c5-64fe-4dd4-8375-ebbd00177f28	2026-08-22 22:53:35.592355-05
13486ef1-fe49-40f9-b78d-bf21c6b8b08e	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	b5ece096-c3c9-4887-a723-4fcf1a886a39	2026-08-22 22:53:35.592355-05
7e85bc5e-8b86-4c54-b4ef-4b14d6bbcb4e	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	d40ceadf-d9be-43a8-b4f4-b785bcdde9b3	2026-08-22 22:53:35.592355-05
108d3b08-7e8e-4c68-9b55-8c03254c3a6e	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	50536bbd-45b9-473a-8c11-51424156a49b	2026-08-22 22:53:35.592355-05
cff8cb2a-0fd1-48ec-b345-95689162251a	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	9efbdd0b-077a-4b11-b74e-514bda463c4b	2026-08-22 22:53:35.592355-05
5ddfe983-6234-488e-8a5e-afa90aee8be2	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	fbcea506-58cf-4aaf-bbff-785bc299da48	2026-08-22 22:53:35.592355-05
a29301f2-b3f7-478a-b567-3066ed975550	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	0fab9267-442b-4cd4-a691-6f5c8b7de428	2026-08-22 22:53:35.592355-05
a00efa75-2d4d-43ca-88db-d1c0c097da32	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	f98716ce-7f5f-48b8-b70b-e2837159ba47	2026-08-22 22:53:35.592355-05
4f7b6296-6a18-4512-aa95-12c9334ec725	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	8faa5549-3f37-411c-ac48-2331a7b27111	2026-08-22 22:53:35.592355-05
cb0ebd56-6e1e-423d-9626-132d53ed8ab6	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	7e36af66-0214-4c43-92bb-5a7efa498206	2026-08-22 22:53:35.592355-05
f3273236-aa24-437b-87b8-e8739d204cce	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	4bd5df0b-d9ce-4702-ba7e-0afe1aa450ff	2026-08-22 22:53:35.592355-05
ee6986f3-fa50-4390-8a10-df737ad2eca2	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	d67842c2-c640-4da4-be3a-707f6ff34052	2026-08-22 22:53:35.592355-05
9a6b197b-6e4c-4ce7-a37b-01b234e5f221	5b74e43d-d0b1-41f0-9ace-47aaa23d96b6	3d300060-c1f7-4fbb-aa09-17821b04f12f	2026-08-22 22:53:35.592355-05
5ae5e498-02cc-465b-8e8d-946adfecd32d	bacda630-34e8-4c9a-9e0d-2385c2789e31	7e36af66-0214-4c43-92bb-5a7efa498206	2026-08-22 22:53:35.592355-05
464f729e-8f6f-4cbf-9ab0-6b7561a16aa2	bacda630-34e8-4c9a-9e0d-2385c2789e31	4bd5df0b-d9ce-4702-ba7e-0afe1aa450ff	2026-08-22 22:53:35.592355-05
ffa97cb9-407d-4bf1-858d-2b2c7d1bfbe4	bacda630-34e8-4c9a-9e0d-2385c2789e31	776b0a37-c0d1-427c-a1b7-0508d36eaa9c	2026-08-22 22:53:35.592355-05
dd51d0e9-a1c5-4ae3-abee-47aa79481215	bacda630-34e8-4c9a-9e0d-2385c2789e31	6103617d-9a8b-42eb-abec-fd656ee93c3e	2026-08-22 22:53:35.592355-05
7dd87c4c-428d-41dc-b937-3c085402e7ca	bacda630-34e8-4c9a-9e0d-2385c2789e31	3d300060-c1f7-4fbb-aa09-17821b04f12f	2026-08-22 22:53:35.592355-05
a933255e-a385-44ad-82bd-2ffe9896c0f8	bacda630-34e8-4c9a-9e0d-2385c2789e31	dcf728a9-be62-4232-b7f2-c2161c7db168	2026-08-22 22:53:35.592355-05
6d907057-ea46-493e-bcb5-266d87762d01	bacda630-34e8-4c9a-9e0d-2385c2789e31	db78103b-2e9d-4417-bf5c-b6522986963b	2026-08-22 22:53:35.592355-05
26cdf592-a65c-4ed8-9c9a-9117a7bb78a1	bacda630-34e8-4c9a-9e0d-2385c2789e31	d6b26e4d-f611-4251-99ea-53786c63b37e	2026-08-22 22:53:35.592355-05
3e10efa4-f887-43b1-bda3-267a058614c8	bacda630-34e8-4c9a-9e0d-2385c2789e31	5de6e54c-0f2e-4202-bf07-6d32cfd60d5f	2026-08-22 22:53:35.592355-05
a2a8d8d8-9270-4f78-b6a6-64e0d163a225	bacda630-34e8-4c9a-9e0d-2385c2789e31	b03bc964-f3d4-499a-9f4c-1603092a8d19	2026-08-22 22:53:35.592355-05
7f8c9637-3a92-416c-a3a4-2f75c82622d2	bacda630-34e8-4c9a-9e0d-2385c2789e31	8faa5549-3f37-411c-ac48-2331a7b27111	2026-08-22 22:53:35.592355-05
f9b0cda4-eb58-4233-9f0d-4add85c22e9c	bacda630-34e8-4c9a-9e0d-2385c2789e31	f98716ce-7f5f-48b8-b70b-e2837159ba47	2026-08-22 22:53:35.592355-05
\.


--
-- Data for Name: seguimiento_administrativo; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.seguimiento_administrativo (id, tenant_id, ot_id, estado_consolidado, monto_liberado_total, moneda, revisado_por, revisado_at, observacion, created_at, updated_at, created_by, updated_by) FROM stdin;
766fc8f8-449b-4ba8-ac29-70bcec0e2741	5c921062-21ab-4a01-8f9a-2e2500e95893	569b23e3-2a8b-4dd7-9f5a-262524af1c93	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:15.470721-05	2026-09-20 15:34:15.470721-05	\N	\N
915758df-1ee4-4bc0-bf0e-90b7f628b89b	5c921062-21ab-4a01-8f9a-2e2500e95893	1400addf-2f07-4784-a1f6-62c95da13ef1	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:15.610587-05	2026-09-20 15:34:15.610587-05	\N	\N
45a2c62e-f215-48ef-83de-b9436348ad69	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:15.727191-05	2026-09-20 15:34:15.727191-05	\N	\N
50cf5db3-58cf-4052-830d-75dac68124ae	5c921062-21ab-4a01-8f9a-2e2500e95893	2b0e0c54-42f5-45ce-9ff5-10b069071a30	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:15.821136-05	2026-09-20 15:34:15.821136-05	\N	\N
b4f61797-e036-4eb1-b100-d190541b46f0	5c921062-21ab-4a01-8f9a-2e2500e95893	f1c60e96-9925-4aa2-a68b-00a72489fd2f	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:15.879017-05	2026-09-20 15:34:15.879017-05	\N	\N
8fefb6af-b725-4c77-91b1-6d06efc18d23	5c921062-21ab-4a01-8f9a-2e2500e95893	bf832c74-c7c4-4cdd-a316-2a92dbbfc301	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:15.93803-05	2026-09-20 15:34:15.93803-05	\N	\N
0498b06e-baba-4808-8c34-c0e0104d37ae	5c921062-21ab-4a01-8f9a-2e2500e95893	c7dd4771-3654-4aff-89a5-f7661193fb03	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:16.012792-05	2026-09-20 15:34:16.012792-05	\N	\N
e4785109-c89f-4202-b92d-50e00ca3ee8b	5c921062-21ab-4a01-8f9a-2e2500e95893	ee9a06f5-0220-47a0-8e4a-d992333af106	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:16.051891-05	2026-09-20 15:34:16.051891-05	\N	\N
b9c7e1c2-6b7a-4312-aa5b-67bb1360ead9	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	sin_solped	0.00	PEN	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:16.210247-05	Sin SOLPED: el gasto se imputó al contrato marco del taller externo.	2026-09-20 15:34:16.085222-05	2026-09-20 15:34:16.210247-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
48320add-7c24-434f-b6c5-df75c1eedf14	5c921062-21ab-4a01-8f9a-2e2500e95893	cd790d32-39ab-4aba-b33d-2dc34a03831a	sin_solped	0.00	PEN	\N	\N	\N	2026-09-20 15:34:16.261469-05	2026-09-20 15:34:16.261469-05	\N	\N
69f43aae-339f-4ead-8b22-133afc1020af	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	sin_solped	0.00	PEN	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:16.407424-05	Gasto menor imputado a caja chica; sin SOLPED.	2026-09-20 15:34:16.304342-05	2026-09-20 15:34:16.407424-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
b14cf194-1944-4d74-8c96-d736fe924fc7	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	solped_pendiente	0.00	PEN	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:15.441202-05	Compras emite la OC la próxima semana; el equipo ya está operativo.	2026-09-20 15:34:15.302141-05	2026-09-20 15:34:16.878667-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
0b13dd8e-6e1d-4b10-a471-e8a68115f0c9	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	administracion_completa	4850.00	PEN	\N	\N	\N	2026-09-20 15:34:14.977113-05	2026-09-20 15:34:16.878667-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Data for Name: solicitud_decision; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.solicitud_decision (id, tenant_id, solicitud_id, tipo, estado_anterior, estado_nuevo, motivo_id, comentario, destinatario_id, solicitud_relacionada_id, actor_id, created_at) FROM stdin;
ee910fe2-cbb8-4578-bca4-05d8f28dec35	5c921062-21ab-4a01-8f9a-2e2500e95893	c4432d97-1ac8-49c5-9bb8-c072cd287501	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:16.496047-05
6948b77e-bb81-4c81-bee6-b98692e09c49	5c921062-21ab-4a01-8f9a-2e2500e95893	c4432d97-1ac8-49c5-9bb8-c072cd287501	observar	en_revision	observada	\N	Indique en qué máquina se oye y en qué momento del turno, para poder asignar al técnico correcto.	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:16.502291-05
c9c866ab-df76-4e49-a10f-3d85b7d50586	5c921062-21ab-4a01-8f9a-2e2500e95893	8cdd7cb1-4234-473c-b22d-43133e531194	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:16.512878-05
604e95b3-1ce4-4ead-b97e-b578edcf9f16	5c921062-21ab-4a01-8f9a-2e2500e95893	8cdd7cb1-4234-473c-b22d-43133e531194	rechazar	en_revision	rechazada	\N	No corresponde a mantenimiento industrial; canalícelo con Administración como compra de bien de oficina.	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-20 15:34:16.51712-05
54e67efe-d7c2-40e5-9179-21a47b71496c	5c921062-21ab-4a01-8f9a-2e2500e95893	e54dbab5-2c51-433d-9c19-0400620d5f99	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000007	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-12 10:34:15.879017-05
849dbbcb-c44d-40f0-989c-e98dc0d325e7	5c921062-21ab-4a01-8f9a-2e2500e95893	e54dbab5-2c51-433d-9c19-0400620d5f99	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-12 10:34:15.875058-05
e90191d6-e5c1-4ea5-8fe7-c56878ef70f3	5c921062-21ab-4a01-8f9a-2e2500e95893	998d96e3-cb46-45ff-abf5-2f8885f40930	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000008	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-03 14:34:15.93803-05
7e91d3b5-7631-43e2-bc1c-e35b10945553	5c921062-21ab-4a01-8f9a-2e2500e95893	998d96e3-cb46-45ff-abf5-2f8885f40930	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-03 14:34:15.933878-05
669933ef-248d-4d18-af64-3de80f4874f7	5c921062-21ab-4a01-8f9a-2e2500e95893	48ebc1d1-f4de-4401-9cca-06e3d91e3621	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000012	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-05 08:34:16.261469-05
9e43a857-63f2-429e-97ed-b6fbf52c24a4	5c921062-21ab-4a01-8f9a-2e2500e95893	48ebc1d1-f4de-4401-9cca-06e3d91e3621	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-05 08:34:16.256839-05
ad88b03d-be0a-4e73-8e83-81192112b6a4	5c921062-21ab-4a01-8f9a-2e2500e95893	c5d4a2a9-9988-4d7a-ad76-555e3020bafe	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000001	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:14.977113-05
30af9903-353d-4342-9161-9609b70664c9	5c921062-21ab-4a01-8f9a-2e2500e95893	c5d4a2a9-9988-4d7a-ad76-555e3020bafe	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:14.972338-05
97515f22-264c-44b4-858a-34948fc3bdf9	5c921062-21ab-4a01-8f9a-2e2500e95893	99d4f059-ece9-4360-9490-c612a98ede66	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000002	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.302141-05
72c720e1-8fd6-4545-97ab-98b48ff24609	5c921062-21ab-4a01-8f9a-2e2500e95893	99d4f059-ece9-4360-9490-c612a98ede66	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.297393-05
68da868a-7c58-4326-b765-589f476ad97a	5c921062-21ab-4a01-8f9a-2e2500e95893	5787000f-3be4-46c8-849b-51b922142d11	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000003	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.470721-05
4ba8bfd9-318b-47ee-a38c-2c315164b8f3	5c921062-21ab-4a01-8f9a-2e2500e95893	5787000f-3be4-46c8-849b-51b922142d11	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-08 05:34:15.466151-05
e8bac390-88dc-44ae-9ef4-c6ab96e4531e	5c921062-21ab-4a01-8f9a-2e2500e95893	6b1ecb72-330f-4e70-8e65-14b41fd94f77	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000006	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:15.821136-05
43b9c97b-bc59-4308-ae1b-72e9d6fd0b1d	5c921062-21ab-4a01-8f9a-2e2500e95893	6b1ecb72-330f-4e70-8e65-14b41fd94f77	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-13 06:34:15.81737-05
5dbc358d-2fbd-464d-a3b4-740067cf560d	5c921062-21ab-4a01-8f9a-2e2500e95893	3c527e52-05d9-4490-b025-2785a2e0a7b2	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000009	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-18 07:34:16.012792-05
19b73558-38c7-4b1c-b504-632743d12d20	5c921062-21ab-4a01-8f9a-2e2500e95893	3c527e52-05d9-4490-b025-2785a2e0a7b2	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-18 07:34:16.008095-05
f379a942-7048-41e2-8f84-58fba02efa33	5c921062-21ab-4a01-8f9a-2e2500e95893	9d56b79e-e16a-497a-a936-985e184807c1	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000013	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.304342-05
85980678-f19a-422d-89a0-f2c762d685d1	5c921062-21ab-4a01-8f9a-2e2500e95893	9d56b79e-e16a-497a-a936-985e184807c1	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.299692-05
c6b998bc-7aa8-4c42-b7c3-0439f9e40c81	5c921062-21ab-4a01-8f9a-2e2500e95893	15e5d80b-173b-451f-a58f-f49dd40813e9	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000005	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.727191-05
918afceb-9063-4e4c-ac90-266cbfaff258	5c921062-21ab-4a01-8f9a-2e2500e95893	15e5d80b-173b-451f-a58f-f49dd40813e9	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-06 13:34:15.722364-05
46a4f0f3-8350-4adb-8375-25e32727f70b	5c921062-21ab-4a01-8f9a-2e2500e95893	0c01b409-e417-4a5b-baad-acba87bbf851	aceptar	en_revision	convertida_en_ot	\N	Convertida en OT-000004	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.610587-05
64ab0485-58b7-41da-81b7-d0c3d0273d9f	5c921062-21ab-4a01-8f9a-2e2500e95893	0c01b409-e417-4a5b-baad-acba87bbf851	tomar_revision	enviada	en_revision	\N	\N	\N	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-09-07 09:34:15.605531-05
\.


--
-- Data for Name: solicitud_trabajo; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.solicitud_trabajo (id, tenant_id, numero, estado, titulo, descripcion, lugar, impacto_operativo_id, impacto_comentario, prioridad_percibida, area_id, empresa_ruc_id, sucursal_id, solicitante_id, fecha_envio, fecha_primera_revision, coordinador_revisor_id, solicitud_principal_id, motivo_rechazo_id, observacion_actual, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
30e96f19-2a6f-4224-a207-1e96e32a5bbb	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000012	enviada	Vibración en el extractor de la zona de soldadura	El extractor vibra y hace más ruido que de costumbre desde el lunes.	Zona de soldadura	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	media	151f5ad1-9d5e-4f59-a283-15f6ec05f515	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-20 15:34:16.453022-05	\N	\N	\N	\N	\N	2026-09-20 15:34:16.453022-05	2026-09-20 15:34:16.453022-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	f71701ef-202b-4563-9c16-10f1d41b8135
5c591e07-051b-4dfa-9890-a6f964c9bcc4	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000013	enviada	Gotera sobre el estante de repuestos	Cuando llueve cae agua justo encima del estante A del almacén.	Almacén central	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	alta	a8d349a2-f03d-44c0-a268-42264076d560	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	89f7a8be-5af2-4d60-b578-9d01db2edce0	2026-09-20 15:34:16.458687-05	\N	\N	\N	\N	\N	2026-09-20 15:34:16.458687-05	2026-09-20 15:34:16.458687-05	\N	89f7a8be-5af2-4d60-b578-9d01db2edce0	89f7a8be-5af2-4d60-b578-9d01db2edce0
ded455bf-93a0-4484-b8b2-c9f4785f173c	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000014	enviada	Balanza de recepción descuadra 3 kg	Pesa de más comparada con la balanza patrón; ya nos rechazaron un despacho.	Recepción de materiales	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	alta	a8d349a2-f03d-44c0-a268-42264076d560	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	89f7a8be-5af2-4d60-b578-9d01db2edce0	2026-09-20 15:34:16.466756-05	\N	\N	\N	\N	\N	2026-09-20 15:34:16.466756-05	2026-09-20 15:34:16.466756-05	\N	89f7a8be-5af2-4d60-b578-9d01db2edce0	89f7a8be-5af2-4d60-b578-9d01db2edce0
5accb670-c0d4-4e81-a5da-d4d9634614eb	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000015	enviada	Aire acondicionado de la sala de control no enfría	La sala está a 31 °C y los tableros se calientan.	Sala de control	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	critica	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-20 15:34:16.475637-05	\N	\N	\N	\N	\N	2026-09-20 15:34:16.475637-05	2026-09-20 15:34:16.475637-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	f71701ef-202b-4563-9c16-10f1d41b8135
35a97525-51a5-4a29-bdec-97d0e29e563c	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000016	enviada	Faja transportadora se desalinea sola	Se corre hacia la derecha y hay que centrarla dos veces por turno.	Línea de empaque	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	media	151f5ad1-9d5e-4f59-a283-15f6ec05f515	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-20 15:34:16.482433-05	\N	\N	\N	\N	\N	2026-09-20 15:34:16.482433-05	2026-09-20 15:34:16.482433-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	f71701ef-202b-4563-9c16-10f1d41b8135
c4432d97-1ac8-49c5-9bb8-c072cd287501	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000017	observada	Algo suena raro en el taller	Se escucha un ruido, no sé de dónde viene.	Taller 1	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	\N	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-20 15:34:16.490087-05	2026-09-20 15:34:16.496047-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	Indique en qué máquina se oye y en qué momento del turno, para poder asignar al técnico correcto.	2026-09-20 15:34:16.490087-05	2026-09-20 15:34:16.502291-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
8cdd7cb1-4234-473c-b22d-43133e531194	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000018	rechazada	Compra de una cafetera para la oficina	La cafetera de la oficina administrativa dejó de funcionar.	Oficina administrativa	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	\N	151f5ad1-9d5e-4f59-a283-15f6ec05f515	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	89f7a8be-5af2-4d60-b578-9d01db2edce0	2026-09-20 15:34:16.507979-05	2026-09-20 15:34:16.512878-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	No corresponde a mantenimiento industrial; canalícelo con Administración como compra de bien de oficina.	2026-09-20 15:34:16.507979-05	2026-09-20 15:34:16.51712-05	\N	89f7a8be-5af2-4d60-b578-9d01db2edce0	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
cc74a708-0627-41be-85c8-57a4ad86cee2	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000019	borrador	Revisión preventiva del grupo electrógeno	Borrador: falta confirmar la fecha con el proveedor del servicio.	Casa de fuerza	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	\N	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	\N	\N	\N	\N	\N	\N	2026-09-20 15:34:16.522589-05	2026-09-20 15:34:16.522589-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	f71701ef-202b-4563-9c16-10f1d41b8135
e54dbab5-2c51-433d-9c19-0400620d5f99	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000007	convertida_en_ot	Caldera se apaga sola por las noches	Amanece apagada dos o tres veces por semana y hay que reencenderla manualmente.	Casa de fuerza	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	alta	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-12 10:34:15.870973-05	2026-09-12 10:34:15.875058-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-09-12 10:34:15.870973-05	2026-09-20 15:34:16.878667-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
998d96e3-cb46-45ff-abf5-2f8885f40930	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000008	convertida_en_ot	Tablero principal con olor a quemado	Huele a quemado en el tablero general y saltó el diferencial dos veces.	Subestación	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	critica	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-03 14:34:15.92883-05	2026-09-03 14:34:15.933878-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-09-03 14:34:15.92883-05	2026-09-20 15:34:16.878667-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
48ebc1d1-f4de-4401-9cca-06e3d91e3621	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000010	convertida_en_ot	Cambiar luminarias del pasillo 3	Las luminarias parpadean y algunas ya no encienden.	Pasillo 3	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	baja	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-08-05 08:34:16.251273-05	2026-08-05 08:34:16.256839-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-08-05 08:34:16.251273-05	2026-09-20 15:34:16.878667-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
c5d4a2a9-9988-4d7a-ad76-555e3020bafe	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000001	convertida_en_ot	Compresor de planta pierde presión	Desde el martes el compresor no mantiene los 8 bar y la línea de pintura se queda sin aire a media jornada.	Sala de compresores, nivel 1	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	alta	151f5ad1-9d5e-4f59-a283-15f6ec05f515	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-08-16 08:34:14.965094-05	2026-08-16 08:34:14.972338-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-08-16 08:34:14.965094-05	2026-09-20 15:34:16.878667-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
99d4f059-ece9-4360-9490-c612a98ede66	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000002	convertida_en_ot	Puente grúa se detiene en el tramo central	El puente grúa del taller 2 se corta a media carrera y hay que reiniciarlo desde el tablero.	Taller 2	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	alta	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	89f7a8be-5af2-4d60-b578-9d01db2edce0	2026-08-15 12:34:15.292016-05	2026-08-15 12:34:15.297393-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-08-15 12:34:15.292016-05	2026-09-20 15:34:16.878667-05	\N	89f7a8be-5af2-4d60-b578-9d01db2edce0	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
5787000f-3be4-46c8-849b-51b922142d11	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000003	convertida_en_ot	Fuga de aceite en la prensa hidráulica 3	Hay un charco bajo la prensa al final de cada turno y el nivel del tanque baja.	Nave de prensas	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	alta	151f5ad1-9d5e-4f59-a283-15f6ec05f515	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-08 05:34:15.460481-05	2026-09-08 05:34:15.466151-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-09-08 05:34:15.460481-05	2026-09-20 15:34:16.878667-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
6b1ecb72-330f-4e70-8e65-14b41fd94f77	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000006	convertida_en_ot	Ruido metálico en el ventilador de extracción	Se oye un golpeteo al arrancar y vibra más de lo normal.	Cabina de pintura	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	media	151f5ad1-9d5e-4f59-a283-15f6ec05f515	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-13 06:34:15.813004-05	2026-09-13 06:34:15.81737-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-09-13 06:34:15.813004-05	2026-09-20 15:34:16.878667-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
3c527e52-05d9-4490-b025-2785a2e0a7b2	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000009	convertida_en_ot	Montacargas 4 sin fuerza y con falla eléctrica	Levanta a media carga y en el tablero se prende una luz que no conocemos.	Patio de maniobras	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	alta	a8d349a2-f03d-44c0-a268-42264076d560	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	89f7a8be-5af2-4d60-b578-9d01db2edce0	2026-09-18 07:34:16.003112-05	2026-09-18 07:34:16.008095-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-09-18 07:34:16.003112-05	2026-09-20 15:34:16.878667-05	\N	89f7a8be-5af2-4d60-b578-9d01db2edce0	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
9d56b79e-e16a-497a-a936-985e184807c1	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000011	convertida_en_ot	Bomba de agua del sistema contra incendios pierde presión	El manómetro del sistema baja durante la noche.	Cuarto de bombas	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	alta	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-08-29 12:34:16.293498-05	2026-08-29 12:34:16.299692-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-08-29 12:34:16.293498-05	2026-09-20 15:34:16.878667-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
15e5d80b-173b-451f-a58f-f49dd40813e9	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000005	convertida_en_ot	Portón del almacén no cierra completo	Queda una luz de veinte centímetros y entra polvo al almacén.	Almacén central	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	baja	a8d349a2-f03d-44c0-a268-42264076d560	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	89f7a8be-5af2-4d60-b578-9d01db2edce0	2026-09-06 13:34:15.716094-05	2026-09-06 13:34:15.722364-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-09-06 13:34:15.716094-05	2026-09-20 15:34:16.878667-05	\N	89f7a8be-5af2-4d60-b578-9d01db2edce0	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
0c01b409-e417-4a5b-baad-acba87bbf851	5c921062-21ab-4a01-8f9a-2e2500e95893	ST-000004	convertida_en_ot	Banco de pruebas sin lectura de par	El banco no muestra el par en pantalla; marca cero con el motor girando.	Laboratorio de pruebas	84f0c1c1-6d59-479a-9d85-3542bfc7f683	\N	media	36883387-4f15-411a-83f2-c8dfea7f88ca	1d2f2959-955c-41b0-96f0-cca1a3c631ba	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	f71701ef-202b-4563-9c16-10f1d41b8135	2026-09-07 09:34:15.599742-05	2026-09-07 09:34:15.605531-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	\N	\N	\N	2026-09-07 09:34:15.599742-05	2026-09-20 15:34:16.878667-05	\N	f71701ef-202b-4563-9c16-10f1d41b8135	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Data for Name: solped; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.solped (id, tenant_id, ot_id, version, vigente, numero_interno, numero_sap, referencia_externa, estado_integracion, formulario, cotizacion_id, monto, moneda, fecha_solped, mensaje_sap, intentos, ultimo_intento_at, anulada, motivo_anulacion, anulada_por, anulada_at, reemplaza_a, created_at, updated_at, created_by, updated_by) FROM stdin;
7c3a47d5-5bb4-4a19-928e-836c0b5386f0	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	1	t	OT-000001-SP1	0010045612	OT-000001-1-c648b37a	creada_en_sap	{}	8ae2a1b6-3d59-429f-abbf-8ea949d00930	4850.00	PEN	2026-08-15	\N	0	\N	f	\N	\N	\N	\N	2026-08-16 08:34:15.168676-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
ca6be66a-aa2f-4744-b6b3-77e1d9a58429	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	1	t	OT-000002-SP1	\N	OT-000002-1-3dd0e535	borrador	{}	941e9e9a-0613-4288-a4f9-17a68d17668f	2140.00	PEN	2026-08-14	\N	0	\N	f	\N	\N	\N	\N	2026-08-15 12:34:15.422972-05	2026-09-20 15:34:16.878667-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Data for Name: sucursal; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.sucursal (id, tenant_id, codigo, nombre, direccion, estado, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
f2bffb8f-46b9-41a3-abf7-0c595ce21e33	5c921062-21ab-4a01-8f9a-2e2500e95893	PLANTA-01	Planta principal	Av. Industrial 1000	activo	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N	\N	\N
\.


--
-- Data for Name: sucursal_empresa_ruc; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.sucursal_empresa_ruc (id, tenant_id, sucursal_id, empresa_ruc_id, created_at) FROM stdin;
86a53590-5e68-42a8-87a0-98690a5eb5b3	5c921062-21ab-4a01-8f9a-2e2500e95893	f2bffb8f-46b9-41a3-abf7-0c595ce21e33	1d2f2959-955c-41b0-96f0-cca1a3c631ba	2026-08-22 22:53:35.61569-05
\.


--
-- Data for Name: tenant; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.tenant (id, codigo, nombre, zona_horaria, moneda_base, estado, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
5c921062-21ab-4a01-8f9a-2e2500e95893	demo	Organización Demo MIP	America/Lima	PEN	activo	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N	\N	\N
\.


--
-- Data for Name: tenant_configuracion; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.tenant_configuracion (id, tenant_id, clave, valor, descripcion, created_at, updated_at, updated_by) FROM stdin;
faf68660-dd5b-4bba-8c8d-cbd71998dec3	5c921062-21ab-4a01-8f9a-2e2500e95893	sla_primera_revision	{"alta": 60, "baja": 1440, "media": 480, "critica": 15}	Minutos máximos de primera revisión por prioridad (cap. 34.2). Son objetivos, no cierran nada.	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N
16fe3b19-8c31-4333-b5e9-de78d4a38853	5c921062-21ab-4a01-8f9a-2e2500e95893	umbral_muestra_costos	{"minimo": 3}	Mínimo de casos comparables para publicar un promedio (cap. 32.4).	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N
98e5edeb-f5e4-4c99-9c20-ffe16db96251	5c921062-21ab-4a01-8f9a-2e2500e95893	exige_evidencia_cierre	false	Si el cierre exige evidencias finales (cap. 14.3).	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N
085ef88c-ac14-40fc-9324-c9b410472b95	5c921062-21ab-4a01-8f9a-2e2500e95893	exige_conformidad	false	La conformidad del solicitante es opcional y no bloquea el cierre (cap. 14.2).	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N
9be2afdc-350c-4ddc-9e4d-9555e4538b52	5c921062-21ab-4a01-8f9a-2e2500e95893	permite_derivada_no_bloqueante	true	Permite marcar una derivada como no bloqueante para el cierre del padre (cap. 10).	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N
0dc5db67-7239-4cab-88f3-c6fcecb10dc0	5c921062-21ab-4a01-8f9a-2e2500e95893	titulo_min_caracteres	5	Longitud mínima del título de solicitud (cap. 24.3).	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N
e2e7755b-f399-4799-a634-ab4af6e434f1	5c921062-21ab-4a01-8f9a-2e2500e95893	titulo_max_caracteres	180	Longitud máxima del título de solicitud (cap. 24.3).	2026-08-22 22:53:35.61569-05	2026-08-22 22:53:35.61569-05	\N
6ad0912f-892a-4e2b-8f19-7162cfc8bb54	5c921062-21ab-4a01-8f9a-2e2500e95893	limites_adjunto	{"pdf": 26214400, "video": 104857600, "imagen": 10485760, "total_ot": 524288000, "documento": 26214400}	Límites de archivos en bytes (cap. 28.3): PDF y documento 25 MB, foto 10 MB, video 100 MB, 500 MB por OT.	2026-08-22 22:53:35.61569-05	2026-09-20 15:32:59.638281-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
d9580f1f-cd5d-4e71-b996-eb9a8f76914a	5c921062-21ab-4a01-8f9a-2e2500e95893	bloqueo_credenciales	{"minutos": 15, "intentos": 5}	Intentos fallidos consecutivos antes de bloquear la cuenta, y minutos de espera (OWASP A07).	2026-09-19 22:58:06.463411-05	2026-09-19 22:58:06.463411-05	\N
\.


--
-- Data for Name: tipo_trabajo; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.tipo_trabajo (id, tenant_id, codigo, nombre, padre_id, descripcion, es_base, estado, created_at, updated_at, deleted_at, created_by, updated_by) FROM stdin;
d225b40b-2205-4c34-b131-ee2c6e44fd9f	\N	MEC_GENERAL	Mecánica general	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
191c571d-7b81-452c-8c99-92905ba5ca57	\N	MEC_SOLDADURA	Soldadura y estructuras	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
bf147cd2-23c8-4e07-819e-a6cde044e15e	\N	MEC_BOMBAS	Bombas y sistemas hidráulicos	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
a92169d4-06ea-4d10-b36b-d8092b14f709	\N	MEC_RODAMIENTO	Rodamientos y transmisión	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
efc65d1b-8ad8-4eb2-8e49-783b09a0cff0	\N	ELE_GENERAL	Electricidad general	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
007b7515-45bb-407e-96f0-49d0df4c6e3f	\N	ELE_MOTORES	Motores eléctricos	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
70d72bcc-44dd-4383-add9-d2e21e9c0477	\N	ELE_TABLEROS	Tableros y control	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
1eed878f-1909-4f26-81c5-e8a85a527e9f	\N	INSTRUMENT	Instrumentación	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
052dad95-749d-4c46-89ad-c6ec16edb4d2	\N	CLIMA	Climatización y refrigeración	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
1fc8222e-7132-4bf9-9235-433a3cae0d21	\N	CIVIL	Obra civil y albañilería	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
ba2ddc63-4f7e-4561-ab2b-b31f6ba5f551	\N	PINTURA	Pintura y recubrimientos	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
3edd6fb2-8268-4204-a998-eb72ae53e077	\N	SANITARIO	Sanitarias y gasfitería	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
743ce9a9-33cc-4c22-b6de-b0bd15bdfa61	\N	NEUMATICA	Neumática	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
5851d5ce-efd8-4a1d-b104-d6ea08dd67ff	\N	LUBRICACION	Lubricación	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
cda62971-ad07-4566-b641-39f6880586be	\N	LIMPIEZA_TEC	Limpieza técnica industrial	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
d2b6dd1b-bd41-4d05-b26e-dee4d07ceb57	\N	TRANSPORTE	Transporte y montaje	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
7d5b75d6-1269-425e-94d5-544b720f7869	\N	SERV_TERCERO	Servicio de tercero especializado	\N	\N	t	activo	2026-08-22 22:53:35.612403-05	2026-08-22 22:53:35.612403-05	\N	\N	\N
\.


--
-- Data for Name: trabajo_realizado; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.trabajo_realizado (id, tenant_id, ot_id, version, vigente, descripcion, resultado_id, resultado_texto, fecha_termino, observaciones, declarado_por, resultado_revision, revision_observacion, revisado_por, revisado_at, conformidad, conformidad_comentario, conformidad_at, created_at, updated_at, created_by, updated_by) FROM stdin;
b02261e6-c664-4abb-bf31-fa2cf4420cce	5c921062-21ab-4a01-8f9a-2e2500e95893	be7b33db-85f9-4955-953c-f4e24d864dcc	1	t	Kit de válvulas y anillos reemplazados. Cuatro horas de prueba sostenidas a 8,1 bar y 71 °C.	\N	\N	2026-08-16 08:34:15.13043-05	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	aprobado		3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-16 08:34:15.151084-05	sin_pronunciarse	\N	\N	2026-08-16 08:34:15.13043-05	2026-09-20 15:34:16.878667-05	5a11b0c5-7640-494f-9c8b-64a9a4e30673	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
f5c474b7-fd66-41e9-8ef4-d907862cdd95	5c921062-21ab-4a01-8f9a-2e2500e95893	14cd082a-4bcd-4661-8837-c47c4f762342	1	t	Contactor nuevo instalado. Diez ciclos de prueba con carga nominal sin cortes.	\N	\N	2026-08-15 12:34:15.386203-05	\N	a7ee34e2-43bd-496d-99b0-ad8013072cea	aprobado		3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-15 12:34:15.405957-05	sin_pronunciarse	\N	\N	2026-08-15 12:34:15.386203-05	2026-09-20 15:34:16.878667-05	a7ee34e2-43bd-496d-99b0-ad8013072cea	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
7f6624ce-bf77-4289-ba48-4ca5a7a3a478	5c921062-21ab-4a01-8f9a-2e2500e95893	bd61bf6d-abeb-487f-91eb-3281f93643f0	1	t	Guía enderezada, sensor nuevo y recorrido recalibrado. El portón cierra a ras de piso.	\N	\N	2026-09-06 13:34:15.795487-05	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	\N	\N	\N	\N	sin_pronunciarse	\N	\N	2026-09-06 13:34:15.795487-05	2026-09-20 15:34:16.878667-05	5a11b0c5-7640-494f-9c8b-64a9a4e30673	5a11b0c5-7640-494f-9c8b-64a9a4e30673
204401ea-b3e8-4e6e-a8b1-6d503b51fe4e	5c921062-21ab-4a01-8f9a-2e2500e95893	a9859198-0a21-4309-8a00-2ca9a2cdc917	1	t	Bomba rectificada y sellos nuevos. Presión de elevación restituida a 180 bar.	\N	\N	2026-08-06 15:34:16.17693-05	\N	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	aprobado		3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-06 15:34:16.194661-05	sin_pronunciarse	\N	\N	2026-08-06 15:34:16.17693-05	2026-09-20 15:34:16.878667-05	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
b847fac3-a71a-4834-87b7-ffc96912e573	5c921062-21ab-4a01-8f9a-2e2500e95893	32eaf0e5-c562-4bfd-b4f7-eb3716f077b3	1	t	Válvula limpia y resorte nuevo. Presión estable en la prueba de dos horas.	\N	\N	2026-08-29 12:34:16.372475-05	\N	5a11b0c5-7640-494f-9c8b-64a9a4e30673	aprobado		3e46b47b-7ca6-466b-8a2e-b01a8473df5b	2026-08-29 12:34:16.391197-05	sin_pronunciarse	\N	\N	2026-08-29 12:34:16.372475-05	2026-09-20 15:34:16.878667-05	5a11b0c5-7640-494f-9c8b-64a9a4e30673	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.usuario (id, tenant_id, email, password_hash, nombres, apellidos, documento, telefono, cargo, estado, is_super_admin, ultimo_acceso_at, preferencias, created_at, updated_at, deleted_at, created_by, updated_by, intentos_fallidos, bloqueado_hasta, ultimo_intento_fallido_at) FROM stdin;
3e46b47b-7ca6-466b-8a2e-b01a8473df5b	5c921062-21ab-4a01-8f9a-2e2500e95893	admin@mip.local	$2a$12$wbnzpKs0agLTpwnCQs.hje3nWkAADFyDxmy2iW6RoJPRPGOER6pou	Administrador	MIP	\N	\N	Super administrador	activo	t	2026-09-20 15:35:10.321144-05	{}	2026-08-22 22:53:35.61569-05	2026-09-20 15:35:10.321144-05	\N	\N	\N	0	\N	2026-09-20 15:33:07.496981-05
472ed7f9-7862-406e-8075-50e2fdc26dbb	5c921062-21ab-4a01-8f9a-2e2500e95893	rosa.quispe@demoindustrial.pe	$2a$12$e9F9yGeJGpMX.GOQXQJ5yeTq8xc/EzftuNyUYTLsnDDMR6v5p/U0e	Rosa	Quispe Vargas	\N	\N	Coordinadora de mantenimiento	activo	f	2026-09-20 15:36:30.309807-05	{}	2026-09-20 15:34:11.609412-05	2026-09-20 15:36:30.309807-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
8b99e5c2-f44f-4d1e-84e5-f658747ba01c	5c921062-21ab-4a01-8f9a-2e2500e95893	julio.paredes@demoindustrial.pe	$2a$12$4eqYvteym1bSdaQj9WWZfuTA9Dxbwi8eEG2j8QXnkW/piJupxuQ4q	Julio	Paredes Ramos	\N	\N	Coordinador de taller	activo	f	2026-09-20 15:34:12.153295-05	{}	2026-09-20 15:34:11.973119-05	2026-09-20 15:34:12.153295-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
5a11b0c5-7640-494f-9c8b-64a9a4e30673	5c921062-21ab-4a01-8f9a-2e2500e95893	marco.tuesta@demoindustrial.pe	$2a$12$1PzhvWN3iD5JpndqrBE/ZuX3EBHf/6osXHrHC89NieKN/h6gm0cC6	Marco	Tuesta Ríos	\N	\N	Técnico mecánico	activo	f	2026-09-20 15:34:12.520818-05	{}	2026-09-20 15:34:12.3373-05	2026-09-20 15:34:12.520818-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
a7ee34e2-43bd-496d-99b0-ad8013072cea	5c921062-21ab-4a01-8f9a-2e2500e95893	elena.chavez@demoindustrial.pe	$2a$12$k3xeyuuboN5ZhukGKSAoQ.ONQslORbKzolRQ2WjbP3BAM.poPYIpm	Elena	Chávez Soto	\N	\N	Técnica electricista	activo	f	2026-09-20 15:34:12.8839-05	{}	2026-09-20 15:34:12.703354-05	2026-09-20 15:34:12.8839-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
0a2b7719-37d2-44fa-84d2-6004c3a7b9df	5c921062-21ab-4a01-8f9a-2e2500e95893	victor.ramos@demoindustrial.pe	$2a$12$cUqpjRCRQ4Yqq4cE3OKPgukf53w21dU2mqc6nrse5L0kZo/rIurdO	Víctor	Ramos Núñez	\N	\N	Técnico hidráulico	activo	f	2026-09-20 15:34:13.249163-05	{}	2026-09-20 15:34:13.065438-05	2026-09-20 15:34:13.249163-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
96364941-9f48-4525-8edd-565c4d37949d	5c921062-21ab-4a01-8f9a-2e2500e95893	carla.mendoza@demoindustrial.pe	$2a$12$.Xw7mPa8utKpmy34UlJMVOOcSqeALgtlq1Gww2Ekzz/VBL07o3lGe	Carla	Mendoza León	\N	\N	Analista de abastecimiento	activo	f	2026-09-20 15:34:13.61196-05	{}	2026-09-20 15:34:13.428616-05	2026-09-20 15:34:13.61196-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
f71701ef-202b-4563-9c16-10f1d41b8135	5c921062-21ab-4a01-8f9a-2e2500e95893	pedro.aliaga@demoindustrial.pe	$2a$12$8gNnAhXeM1EjLolGl31HneVRDj18pbO3Op7SmmtoJwfK0.mUizmLm	Pedro	Aliaga Vera	\N	\N	Supervisor de producción	activo	f	2026-09-20 15:34:13.980139-05	{}	2026-09-20 15:34:13.796344-05	2026-09-20 15:34:13.980139-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
89f7a8be-5af2-4d60-b578-9d01db2edce0	5c921062-21ab-4a01-8f9a-2e2500e95893	nancy.ortiz@demoindustrial.pe	$2a$12$GyRszJG5zWCbBAfJgfbWvejF57568KhPPDDC0h12KgXmu9ra9X1Ya	Nancy	Ortiz Huamán	\N	\N	Jefa de almacén	activo	f	2026-09-20 15:34:14.353549-05	{}	2026-09-20 15:34:14.163446-05	2026-09-20 15:34:14.353549-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
3f242551-ee85-4b4e-aa57-c7ab67215e58	5c921062-21ab-4a01-8f9a-2e2500e95893	andres.ferrer@demoindustrial.pe	$2a$12$GjFu3GXdTG9eO6obRbyK8OCFGYtIOmmPkDzkpYCvrmGlXkxKz6qja	Andrés	Ferrer Díaz	\N	\N	Gerente de operaciones	activo	f	2026-09-20 15:34:14.743039-05	{}	2026-09-20 15:34:14.551007-05	2026-09-20 15:34:14.743039-05	\N	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	0	\N	\N
\.


--
-- Data for Name: usuario_alcance; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.usuario_alcance (id, tenant_id, usuario_id, sucursal_id, empresa_ruc_id, area_id, created_at, created_by) FROM stdin;
\.


--
-- Data for Name: usuario_rol; Type: TABLE DATA; Schema: core; Owner: -
--

COPY core.usuario_rol (id, usuario_id, rol_id, created_at, created_by) FROM stdin;
2361de43-c71b-48a1-b53a-5af6b05f7a59	3e46b47b-7ca6-466b-8a2e-b01a8473df5b	dddfee51-13c2-4ce5-82ea-f94e98b4b675	2026-08-22 22:53:35.61569-05	\N
4cba1487-553d-48f1-b16e-9aa91a604e8d	472ed7f9-7862-406e-8075-50e2fdc26dbb	0a107d58-4871-4315-a8a8-0766f98576bf	2026-09-20 15:34:11.609412-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
95a1726b-dd19-41ed-91b9-6263fdad022f	8b99e5c2-f44f-4d1e-84e5-f658747ba01c	0a107d58-4871-4315-a8a8-0766f98576bf	2026-09-20 15:34:11.973119-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
280e64f2-3256-4f13-888c-5844c6410c02	5a11b0c5-7640-494f-9c8b-64a9a4e30673	b22b1e1d-7bd6-492b-b847-075d26e65ce9	2026-09-20 15:34:12.3373-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
358c759b-2ad1-4767-8aa1-d55796d9b46d	a7ee34e2-43bd-496d-99b0-ad8013072cea	b22b1e1d-7bd6-492b-b847-075d26e65ce9	2026-09-20 15:34:12.703354-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
08662ba7-433a-4aff-aeb3-448bb533193f	0a2b7719-37d2-44fa-84d2-6004c3a7b9df	b22b1e1d-7bd6-492b-b847-075d26e65ce9	2026-09-20 15:34:13.065438-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
1251585a-3c42-4fba-afd0-87a37bc119b8	96364941-9f48-4525-8edd-565c4d37949d	bacda630-34e8-4c9a-9e0d-2385c2789e31	2026-09-20 15:34:13.428616-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
8f0c26f2-837c-4ac0-8467-5cd0999d160a	f71701ef-202b-4563-9c16-10f1d41b8135	d0d339c8-0f65-4160-b047-5dd489e91b75	2026-09-20 15:34:13.796344-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
da146c9d-a3a0-43cd-95d2-b2f8435f9bb5	89f7a8be-5af2-4d60-b578-9d01db2edce0	d0d339c8-0f65-4160-b047-5dd489e91b75	2026-09-20 15:34:14.163446-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
7780dbbf-1808-4a32-8d68-ec8adf30649d	3f242551-ee85-4b4e-aa57-c7ab67215e58	8073c2fc-42e1-4c32-b29f-6fc8fb62d065	2026-09-20 15:34:14.551007-05	3e46b47b-7ca6-466b-8a2e-b01a8473df5b
\.


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: audit; Owner: -
--

SELECT pg_catalog.setval('audit.audit_log_id_seq', 111, true);


--
-- Name: liberacion_historial_secuencia_seq; Type: SEQUENCE SET; Schema: core; Owner: -
--

SELECT pg_catalog.setval('core.liberacion_historial_secuencia_seq', 1, true);


--
-- Name: ot_evento_id_seq; Type: SEQUENCE SET; Schema: core; Owner: -
--

SELECT pg_catalog.setval('core.ot_evento_id_seq', 107, true);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: audit; Owner: -
--

ALTER TABLE ONLY audit.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: adjunto adjunto_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.adjunto
    ADD CONSTRAINT adjunto_pkey PRIMARY KEY (id);


--
-- Name: area area_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--
-- Name: catalogo_item catalogo_item_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.catalogo_item
    ADD CONSTRAINT catalogo_item_pkey PRIMARY KEY (id);


--
-- Name: cecos cecos_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cecos
    ADD CONSTRAINT cecos_pkey PRIMARY KEY (id);


--
-- Name: conversacion_participante conversacion_participante_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion_participante
    ADD CONSTRAINT conversacion_participante_pkey PRIMARY KEY (id);


--
-- Name: conversacion conversacion_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion
    ADD CONSTRAINT conversacion_pkey PRIMARY KEY (id);


--
-- Name: correlativo correlativo_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.correlativo
    ADD CONSTRAINT correlativo_pkey PRIMARY KEY (id);


--
-- Name: costo_unitario costo_unitario_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_pkey PRIMARY KEY (id);


--
-- Name: cotizacion cotizacion_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT cotizacion_pkey PRIMARY KEY (id);


--
-- Name: descripcion_normalizada descripcion_normalizada_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.descripcion_normalizada
    ADD CONSTRAINT descripcion_normalizada_pkey PRIMARY KEY (id);


--
-- Name: diagnostico diagnostico_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT diagnostico_pkey PRIMARY KEY (id);


--
-- Name: ejecucion ejecucion_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ejecucion
    ADD CONSTRAINT ejecucion_pkey PRIMARY KEY (id);


--
-- Name: empresa_ruc empresa_ruc_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.empresa_ruc
    ADD CONSTRAINT empresa_ruc_pkey PRIMARY KEY (id);


--
-- Name: liberacion_historial liberacion_historial_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.liberacion_historial
    ADD CONSTRAINT liberacion_historial_pkey PRIMARY KEY (id);


--
-- Name: mensaje mensaje_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.mensaje
    ADD CONSTRAINT mensaje_pkey PRIMARY KEY (id);


--
-- Name: notificacion notificacion_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.notificacion
    ADD CONSTRAINT notificacion_pkey PRIMARY KEY (id);


--
-- Name: orden_compra orden_compra_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_compra
    ADD CONSTRAINT orden_compra_pkey PRIMARY KEY (id);


--
-- Name: orden_trabajo orden_trabajo_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_pkey PRIMARY KEY (id);


--
-- Name: ot_avance ot_avance_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_avance
    ADD CONSTRAINT ot_avance_pkey PRIMARY KEY (id);


--
-- Name: ot_cierre ot_cierre_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_cierre
    ADD CONSTRAINT ot_cierre_pkey PRIMARY KEY (id);


--
-- Name: ot_estado_historial ot_estado_historial_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_estado_historial
    ADD CONSTRAINT ot_estado_historial_pkey PRIMARY KEY (id);


--
-- Name: ot_evento ot_evento_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_evento
    ADD CONSTRAINT ot_evento_pkey PRIMARY KEY (id);


--
-- Name: ot_incidencia ot_incidencia_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_incidencia
    ADD CONSTRAINT ot_incidencia_pkey PRIMARY KEY (id);


--
-- Name: ot_pausa ot_pausa_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_pausa
    ADD CONSTRAINT ot_pausa_pkey PRIMARY KEY (id);


--
-- Name: ot_reapertura ot_reapertura_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_reapertura
    ADD CONSTRAINT ot_reapertura_pkey PRIMARY KEY (id);


--
-- Name: permiso permiso_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.permiso
    ADD CONSTRAINT permiso_pkey PRIMARY KEY (id);


--
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);


--
-- Name: regla_normalizacion regla_normalizacion_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.regla_normalizacion
    ADD CONSTRAINT regla_normalizacion_pkey PRIMARY KEY (id);


--
-- Name: rol_permiso rol_permiso_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.rol_permiso
    ADD CONSTRAINT rol_permiso_pkey PRIMARY KEY (id);


--
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id);


--
-- Name: seguimiento_administrativo seguimiento_administrativo_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.seguimiento_administrativo
    ADD CONSTRAINT seguimiento_administrativo_pkey PRIMARY KEY (id);


--
-- Name: solicitud_decision solicitud_decision_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_decision
    ADD CONSTRAINT solicitud_decision_pkey PRIMARY KEY (id);


--
-- Name: solicitud_trabajo solicitud_trabajo_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_pkey PRIMARY KEY (id);


--
-- Name: solped solped_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT solped_pkey PRIMARY KEY (id);


--
-- Name: sucursal_empresa_ruc sucursal_empresa_ruc_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sucursal_empresa_ruc
    ADD CONSTRAINT sucursal_empresa_ruc_pkey PRIMARY KEY (id);


--
-- Name: sucursal sucursal_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sucursal
    ADD CONSTRAINT sucursal_pkey PRIMARY KEY (id);


--
-- Name: tenant_configuracion tenant_configuracion_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant_configuracion
    ADD CONSTRAINT tenant_configuracion_pkey PRIMARY KEY (id);


--
-- Name: tenant tenant_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant
    ADD CONSTRAINT tenant_pkey PRIMARY KEY (id);


--
-- Name: tipo_trabajo tipo_trabajo_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tipo_trabajo
    ADD CONSTRAINT tipo_trabajo_pkey PRIMARY KEY (id);


--
-- Name: trabajo_realizado trabajo_realizado_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT trabajo_realizado_pkey PRIMARY KEY (id);


--
-- Name: area uq_area_codigo; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.area
    ADD CONSTRAINT uq_area_codigo UNIQUE (empresa_ruc_id, codigo);


--
-- Name: catalogo_item uq_catalogo_item; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.catalogo_item
    ADD CONSTRAINT uq_catalogo_item UNIQUE NULLS NOT DISTINCT (tenant_id, tipo, codigo);


--
-- Name: cecos uq_cecos_codigo; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cecos
    ADD CONSTRAINT uq_cecos_codigo UNIQUE (empresa_ruc_id, codigo);


--
-- Name: conversacion uq_conversacion_ot; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion
    ADD CONSTRAINT uq_conversacion_ot UNIQUE (ot_id);


--
-- Name: conversacion_participante uq_conversacion_participante; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion_participante
    ADD CONSTRAINT uq_conversacion_participante UNIQUE (conversacion_id, usuario_id);


--
-- Name: correlativo uq_correlativo; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.correlativo
    ADD CONSTRAINT uq_correlativo UNIQUE (tenant_id, tipo_documento);


--
-- Name: cotizacion uq_cotizacion_version; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT uq_cotizacion_version UNIQUE (ot_id, version);


--
-- Name: descripcion_normalizada uq_descripcion_normalizada; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.descripcion_normalizada
    ADD CONSTRAINT uq_descripcion_normalizada UNIQUE (tenant_id, etiqueta, version);


--
-- Name: diagnostico uq_diagnostico_version; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT uq_diagnostico_version UNIQUE (ot_id, version);


--
-- Name: ejecucion uq_ejecucion_ot; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ejecucion
    ADD CONSTRAINT uq_ejecucion_ot UNIQUE (ot_id);


--
-- Name: empresa_ruc uq_empresa_ruc_ruc; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.empresa_ruc
    ADD CONSTRAINT uq_empresa_ruc_ruc UNIQUE (tenant_id, ruc);


--
-- Name: ot_cierre uq_ot_cierre_secuencia; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_cierre
    ADD CONSTRAINT uq_ot_cierre_secuencia UNIQUE (ot_id, secuencia);


--
-- Name: orden_trabajo uq_ot_numero; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT uq_ot_numero UNIQUE (tenant_id, numero_ot);


--
-- Name: permiso uq_permiso_codigo; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.permiso
    ADD CONSTRAINT uq_permiso_codigo UNIQUE (codigo);


--
-- Name: proveedor uq_proveedor_ruc; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.proveedor
    ADD CONSTRAINT uq_proveedor_ruc UNIQUE (tenant_id, ruc);


--
-- Name: rol uq_rol_codigo; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.rol
    ADD CONSTRAINT uq_rol_codigo UNIQUE NULLS NOT DISTINCT (tenant_id, codigo);


--
-- Name: rol_permiso uq_rol_permiso; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.rol_permiso
    ADD CONSTRAINT uq_rol_permiso UNIQUE (rol_id, permiso_id);


--
-- Name: seguimiento_administrativo uq_seguimiento_admin_ot; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.seguimiento_administrativo
    ADD CONSTRAINT uq_seguimiento_admin_ot UNIQUE (ot_id);


--
-- Name: solicitud_trabajo uq_solicitud_numero; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT uq_solicitud_numero UNIQUE (tenant_id, numero);


--
-- Name: solped uq_solped_version; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT uq_solped_version UNIQUE (ot_id, version);


--
-- Name: sucursal uq_sucursal_codigo; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sucursal
    ADD CONSTRAINT uq_sucursal_codigo UNIQUE (tenant_id, codigo);


--
-- Name: sucursal_empresa_ruc uq_sucursal_empresa_ruc; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sucursal_empresa_ruc
    ADD CONSTRAINT uq_sucursal_empresa_ruc UNIQUE (sucursal_id, empresa_ruc_id);


--
-- Name: tenant uq_tenant_codigo; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant
    ADD CONSTRAINT uq_tenant_codigo UNIQUE (codigo);


--
-- Name: tenant_configuracion uq_tenant_configuracion; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant_configuracion
    ADD CONSTRAINT uq_tenant_configuracion UNIQUE (tenant_id, clave);


--
-- Name: tipo_trabajo uq_tipo_trabajo_codigo; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tipo_trabajo
    ADD CONSTRAINT uq_tipo_trabajo_codigo UNIQUE NULLS NOT DISTINCT (tenant_id, codigo);


--
-- Name: trabajo_realizado uq_trabajo_realizado_version; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT uq_trabajo_realizado_version UNIQUE (ot_id, version);


--
-- Name: usuario uq_usuario_email; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario
    ADD CONSTRAINT uq_usuario_email UNIQUE (email);


--
-- Name: usuario_rol uq_usuario_rol; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_rol
    ADD CONSTRAINT uq_usuario_rol UNIQUE (usuario_id, rol_id);


--
-- Name: usuario_alcance usuario_alcance_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_alcance
    ADD CONSTRAINT usuario_alcance_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: usuario_rol usuario_rol_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_rol
    ADD CONSTRAINT usuario_rol_pkey PRIMARY KEY (id);


--
-- Name: ix_audit_log_actor; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_log_actor ON audit.audit_log USING btree (actor_id, created_at DESC);


--
-- Name: ix_audit_log_entidad; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_log_entidad ON audit.audit_log USING btree (entidad, entidad_id, created_at DESC);


--
-- Name: ix_audit_log_tenant; Type: INDEX; Schema: audit; Owner: -
--

CREATE INDEX ix_audit_log_tenant ON audit.audit_log USING btree (tenant_id, created_at DESC);


--
-- Name: ix_adjunto_entidad; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_adjunto_entidad ON core.adjunto USING btree (entidad_tipo, entidad_id);


--
-- Name: ix_adjunto_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_adjunto_ot ON core.adjunto USING btree (ot_id, etapa) WHERE (estado = 'vigente'::core.estado_adjunto);


--
-- Name: ix_area_empresa_ruc; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_area_empresa_ruc ON core.area USING btree (empresa_ruc_id) WHERE (deleted_at IS NULL);


--
-- Name: ix_area_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_area_tenant ON core.area USING btree (tenant_id) WHERE (deleted_at IS NULL);


--
-- Name: ix_catalogo_item_tipo; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_catalogo_item_tipo ON core.catalogo_item USING btree (tipo, tenant_id) WHERE (deleted_at IS NULL);


--
-- Name: ix_costo_busqueda; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_costo_busqueda ON core.costo_unitario USING btree (tenant_id, tipo_trabajo_id, empresa_ruc_id, fecha_referencia DESC) WHERE (es_comparable = true);


--
-- Name: ix_costo_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_costo_ot ON core.costo_unitario USING btree (ot_id);


--
-- Name: ix_costo_texto_trgm; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_costo_texto_trgm ON core.costo_unitario USING gin (texto_original public.gin_trgm_ops);


--
-- Name: ix_cotizacion_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_cotizacion_ot ON core.cotizacion USING btree (ot_id, version DESC);


--
-- Name: ix_cotizacion_proveedor; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_cotizacion_proveedor ON core.cotizacion USING btree (proveedor_id, fecha_cotizacion DESC);


--
-- Name: ix_diagnostico_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_diagnostico_ot ON core.diagnostico USING btree (ot_id, version DESC);


--
-- Name: ix_empresa_ruc_razon_trgm; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_empresa_ruc_razon_trgm ON core.empresa_ruc USING gin (razon_social public.gin_trgm_ops);


--
-- Name: ix_empresa_ruc_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_empresa_ruc_tenant ON core.empresa_ruc USING btree (tenant_id) WHERE (deleted_at IS NULL);


--
-- Name: ix_liberacion_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_liberacion_ot ON core.liberacion_historial USING btree (ot_id, secuencia DESC);


--
-- Name: ix_mensaje_conversacion; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_mensaje_conversacion ON core.mensaje USING btree (conversacion_id, created_at);


--
-- Name: ix_notificacion_destinatario; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_notificacion_destinatario ON core.notificacion USING btree (destinatario_id, created_at DESC) WHERE (leida_at IS NULL);


--
-- Name: ix_orden_compra_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_orden_compra_ot ON core.orden_compra USING btree (ot_id, created_at DESC);


--
-- Name: ix_ot_admin; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_admin ON core.orden_trabajo USING btree (tenant_id, estado_administrativo);


--
-- Name: ix_ot_avance_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_avance_ot ON core.ot_avance USING btree (ot_id, created_at DESC);


--
-- Name: ix_ot_coordinador; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_coordinador ON core.orden_trabajo USING btree (coordinador_id, estado);


--
-- Name: ix_ot_dirty; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_dirty ON core.orden_trabajo USING btree (id) WHERE (trazabilidad_dirty = true);


--
-- Name: ix_ot_ejecutor; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_ejecutor ON core.orden_trabajo USING btree (ejecutor_id, estado);


--
-- Name: ix_ot_emergencia; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_emergencia ON core.orden_trabajo USING btree (tenant_id) WHERE (es_emergencia = true);


--
-- Name: ix_ot_estado_historial_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_estado_historial_ot ON core.ot_estado_historial USING btree (ot_id, created_at);


--
-- Name: ix_ot_evento_dominio; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_evento_dominio ON core.ot_evento USING btree (tenant_id, dominio, created_at DESC);


--
-- Name: ix_ot_evento_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_evento_ot ON core.ot_evento USING btree (ot_id, created_at);


--
-- Name: ix_ot_incidencia_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_incidencia_ot ON core.ot_incidencia USING btree (ot_id, created_at DESC);


--
-- Name: ix_ot_organizacion; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_organizacion ON core.orden_trabajo USING btree (sucursal_id, empresa_ruc_id, area_id);


--
-- Name: ix_ot_padre; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_padre ON core.orden_trabajo USING btree (ot_padre_id) WHERE (ot_padre_id IS NOT NULL);


--
-- Name: ix_ot_pausa_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_pausa_ot ON core.ot_pausa USING btree (ot_id, fecha_pausa DESC);


--
-- Name: ix_ot_reapertura_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_reapertura_ot ON core.ot_reapertura USING btree (ot_id, created_at);


--
-- Name: ix_ot_tenant_estado; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_tenant_estado ON core.orden_trabajo USING btree (tenant_id, estado) WHERE (deleted_at IS NULL);


--
-- Name: ix_ot_trazabilidad_gin; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_ot_trazabilidad_gin ON core.orden_trabajo USING gin (trazabilidad jsonb_path_ops);


--
-- Name: ix_proveedor_razon_trgm; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_proveedor_razon_trgm ON core.proveedor USING gin (razon_social public.gin_trgm_ops);


--
-- Name: ix_solicitud_area; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_solicitud_area ON core.solicitud_trabajo USING btree (area_id) WHERE (deleted_at IS NULL);


--
-- Name: ix_solicitud_decision_solicitud; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_solicitud_decision_solicitud ON core.solicitud_decision USING btree (solicitud_id, created_at);


--
-- Name: ix_solicitud_solicitante; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_solicitud_solicitante ON core.solicitud_trabajo USING btree (solicitante_id, created_at DESC);


--
-- Name: ix_solicitud_tenant_estado; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_solicitud_tenant_estado ON core.solicitud_trabajo USING btree (tenant_id, estado) WHERE (deleted_at IS NULL);


--
-- Name: ix_solicitud_titulo_trgm; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_solicitud_titulo_trgm ON core.solicitud_trabajo USING gin (titulo public.gin_trgm_ops);


--
-- Name: ix_solped_numero_sap; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_solped_numero_sap ON core.solped USING btree (tenant_id, numero_sap) WHERE (numero_sap IS NOT NULL);


--
-- Name: ix_solped_ot; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_solped_ot ON core.solped USING btree (ot_id, version DESC);


--
-- Name: ix_sucursal_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_sucursal_tenant ON core.sucursal USING btree (tenant_id) WHERE (deleted_at IS NULL);


--
-- Name: ix_usuario_alcance_usuario; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_usuario_alcance_usuario ON core.usuario_alcance USING btree (usuario_id);


--
-- Name: ix_usuario_email_lower; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_usuario_email_lower ON core.usuario USING btree (lower((email)::text));


--
-- Name: ix_usuario_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX ix_usuario_tenant ON core.usuario USING btree (tenant_id) WHERE (deleted_at IS NULL);


--
-- Name: uq_cotizacion_vigente; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX uq_cotizacion_vigente ON core.cotizacion USING btree (ot_id) WHERE ((vigente = true) AND (invalidada = false));


--
-- Name: uq_diagnostico_vigente; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX uq_diagnostico_vigente ON core.diagnostico USING btree (ot_id) WHERE (vigente = true);


--
-- Name: uq_ot_cierre_vigente; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX uq_ot_cierre_vigente ON core.ot_cierre USING btree (ot_id) WHERE (vigente = true);


--
-- Name: uq_ot_solicitud_origen; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX uq_ot_solicitud_origen ON core.orden_trabajo USING btree (solicitud_origen_id) WHERE ((solicitud_origen_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: uq_pausa_abierta; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX uq_pausa_abierta ON core.ot_pausa USING btree (ot_id) WHERE (fecha_reanudacion IS NULL);


--
-- Name: uq_solped_vigente; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX uq_solped_vigente ON core.solped USING btree (ot_id) WHERE ((vigente = true) AND (anulada = false));


--
-- Name: uq_trabajo_realizado_vigente; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX uq_trabajo_realizado_vigente ON core.trabajo_realizado USING btree (ot_id) WHERE (vigente = true);


--
-- Name: adjunto trg_adjunto_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_adjunto_dirty AFTER INSERT OR DELETE OR UPDATE ON core.adjunto FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: adjunto trg_adjunto_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_adjunto_set_updated_at BEFORE UPDATE ON core.adjunto FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: area trg_area_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_area_dirty AFTER UPDATE ON core.area FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_organizacion('area_id');


--
-- Name: area trg_area_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_area_set_updated_at BEFORE UPDATE ON core.area FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: catalogo_item trg_catalogo_item_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_catalogo_item_set_updated_at BEFORE UPDATE ON core.catalogo_item FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: cecos trg_cecos_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_cecos_set_updated_at BEFORE UPDATE ON core.cecos FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: conversacion trg_conversacion_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_conversacion_dirty AFTER INSERT OR DELETE OR UPDATE ON core.conversacion FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: conversacion_participante trg_conversacion_participante_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_conversacion_participante_dirty AFTER INSERT OR DELETE OR UPDATE ON core.conversacion_participante FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_conversacion();


--
-- Name: conversacion_participante trg_conversacion_participante_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_conversacion_participante_set_updated_at BEFORE UPDATE ON core.conversacion_participante FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: conversacion trg_conversacion_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_conversacion_set_updated_at BEFORE UPDATE ON core.conversacion FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: correlativo trg_correlativo_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_correlativo_set_updated_at BEFORE UPDATE ON core.correlativo FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: costo_unitario trg_costo_unitario_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_costo_unitario_dirty AFTER INSERT OR DELETE OR UPDATE ON core.costo_unitario FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: costo_unitario trg_costo_unitario_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_costo_unitario_set_updated_at BEFORE UPDATE ON core.costo_unitario FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: cotizacion trg_cotizacion_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_cotizacion_dirty AFTER INSERT OR DELETE OR UPDATE ON core.cotizacion FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: cotizacion trg_cotizacion_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_cotizacion_set_updated_at BEFORE UPDATE ON core.cotizacion FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: descripcion_normalizada trg_descripcion_normalizada_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_descripcion_normalizada_set_updated_at BEFORE UPDATE ON core.descripcion_normalizada FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: diagnostico trg_diagnostico_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_diagnostico_dirty AFTER INSERT OR DELETE OR UPDATE ON core.diagnostico FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: diagnostico trg_diagnostico_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_diagnostico_set_updated_at BEFORE UPDATE ON core.diagnostico FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: ejecucion trg_ejecucion_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ejecucion_dirty AFTER INSERT OR DELETE OR UPDATE ON core.ejecucion FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: ejecucion trg_ejecucion_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ejecucion_set_updated_at BEFORE UPDATE ON core.ejecucion FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: empresa_ruc trg_empresa_ruc_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_empresa_ruc_dirty AFTER UPDATE ON core.empresa_ruc FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_organizacion('empresa_ruc_id');


--
-- Name: empresa_ruc trg_empresa_ruc_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_empresa_ruc_set_updated_at BEFORE UPDATE ON core.empresa_ruc FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: liberacion_historial trg_liberacion_historial_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_liberacion_historial_dirty AFTER INSERT OR DELETE OR UPDATE ON core.liberacion_historial FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: liberacion_historial trg_liberacion_historial_estado_admin; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_liberacion_historial_estado_admin AFTER INSERT OR DELETE OR UPDATE ON core.liberacion_historial FOR EACH ROW EXECUTE FUNCTION core.refrescar_estado_administrativo();


--
-- Name: mensaje trg_mensaje_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_mensaje_dirty AFTER INSERT OR DELETE OR UPDATE ON core.mensaje FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_conversacion();


--
-- Name: mensaje trg_mensaje_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_mensaje_set_updated_at BEFORE UPDATE ON core.mensaje FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: notificacion trg_notificacion_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_notificacion_dirty AFTER INSERT OR DELETE OR UPDATE ON core.notificacion FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: notificacion trg_notificacion_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_notificacion_set_updated_at BEFORE UPDATE ON core.notificacion FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: orden_compra trg_orden_compra_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_orden_compra_dirty AFTER INSERT OR DELETE OR UPDATE ON core.orden_compra FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: orden_compra trg_orden_compra_estado_admin; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_orden_compra_estado_admin AFTER INSERT OR DELETE OR UPDATE ON core.orden_compra FOR EACH ROW EXECUTE FUNCTION core.refrescar_estado_administrativo();


--
-- Name: orden_compra trg_orden_compra_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_orden_compra_set_updated_at BEFORE UPDATE ON core.orden_compra FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: orden_trabajo trg_orden_trabajo_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_orden_trabajo_set_updated_at BEFORE UPDATE ON core.orden_trabajo FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: ot_avance trg_ot_avance_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_avance_dirty AFTER INSERT OR DELETE OR UPDATE ON core.ot_avance FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: ot_cierre trg_ot_cierre_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_cierre_dirty AFTER INSERT OR DELETE OR UPDATE ON core.ot_cierre FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: orden_trabajo trg_ot_dirty_self; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_dirty_self AFTER INSERT OR UPDATE ON core.orden_trabajo FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_ot_self();


--
-- Name: ot_estado_historial trg_ot_estado_historial_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_estado_historial_dirty AFTER INSERT OR DELETE OR UPDATE ON core.ot_estado_historial FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: ot_evento trg_ot_evento_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_evento_dirty AFTER INSERT OR DELETE OR UPDATE ON core.ot_evento FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: ot_evento trg_ot_evento_inmutable; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_evento_inmutable BEFORE DELETE OR UPDATE ON core.ot_evento FOR EACH ROW EXECUTE FUNCTION core.bloquear_mutacion_bitacora();


--
-- Name: orden_trabajo trg_ot_guarda_cerrada; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_guarda_cerrada BEFORE UPDATE ON core.orden_trabajo FOR EACH ROW EXECUTE FUNCTION core.guardar_ot_cerrada();


--
-- Name: ot_incidencia trg_ot_incidencia_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_incidencia_dirty AFTER INSERT OR DELETE OR UPDATE ON core.ot_incidencia FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: ot_incidencia trg_ot_incidencia_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_incidencia_set_updated_at BEFORE UPDATE ON core.ot_incidencia FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: orden_trabajo trg_ot_jerarquia; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_jerarquia BEFORE INSERT OR UPDATE OF ot_padre_id ON core.orden_trabajo FOR EACH ROW EXECUTE FUNCTION core.validar_jerarquia_ot();


--
-- Name: ot_pausa trg_ot_pausa_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_pausa_dirty AFTER INSERT OR DELETE OR UPDATE ON core.ot_pausa FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: ot_pausa trg_ot_pausa_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_pausa_set_updated_at BEFORE UPDATE ON core.ot_pausa FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: ot_reapertura trg_ot_reapertura_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_ot_reapertura_dirty AFTER INSERT OR DELETE OR UPDATE ON core.ot_reapertura FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: ot_pausa trg_pausa_condicion; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_pausa_condicion AFTER INSERT OR DELETE OR UPDATE ON core.ot_pausa FOR EACH ROW EXECUTE FUNCTION core.refrescar_condicion_ot();


--
-- Name: proveedor trg_proveedor_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_proveedor_set_updated_at BEFORE UPDATE ON core.proveedor FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: regla_normalizacion trg_regla_normalizacion_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_regla_normalizacion_set_updated_at BEFORE UPDATE ON core.regla_normalizacion FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: rol trg_rol_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_rol_set_updated_at BEFORE UPDATE ON core.rol FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: seguimiento_administrativo trg_seguimiento_administrativo_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_seguimiento_administrativo_dirty AFTER INSERT OR DELETE OR UPDATE ON core.seguimiento_administrativo FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: seguimiento_administrativo trg_seguimiento_administrativo_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_seguimiento_administrativo_set_updated_at BEFORE UPDATE ON core.seguimiento_administrativo FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: solicitud_decision trg_solicitud_decision_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_solicitud_decision_dirty AFTER INSERT OR DELETE OR UPDATE ON core.solicitud_decision FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_solicitud_hija();


--
-- Name: solicitud_trabajo trg_solicitud_trabajo_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_solicitud_trabajo_dirty AFTER INSERT OR DELETE OR UPDATE ON core.solicitud_trabajo FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_solicitud();


--
-- Name: solicitud_trabajo trg_solicitud_trabajo_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_solicitud_trabajo_set_updated_at BEFORE UPDATE ON core.solicitud_trabajo FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: solped trg_solped_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_solped_dirty AFTER INSERT OR DELETE OR UPDATE ON core.solped FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: solped trg_solped_estado_admin; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_solped_estado_admin AFTER INSERT OR DELETE OR UPDATE ON core.solped FOR EACH ROW EXECUTE FUNCTION core.refrescar_estado_administrativo();


--
-- Name: solped trg_solped_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_solped_set_updated_at BEFORE UPDATE ON core.solped FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: sucursal trg_sucursal_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_sucursal_dirty AFTER UPDATE ON core.sucursal FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_organizacion('sucursal_id');


--
-- Name: sucursal trg_sucursal_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_sucursal_set_updated_at BEFORE UPDATE ON core.sucursal FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: tenant_configuracion trg_tenant_configuracion_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_tenant_configuracion_set_updated_at BEFORE UPDATE ON core.tenant_configuracion FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: tenant trg_tenant_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_tenant_set_updated_at BEFORE UPDATE ON core.tenant FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: tipo_trabajo trg_tipo_trabajo_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_tipo_trabajo_set_updated_at BEFORE UPDATE ON core.tipo_trabajo FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: trabajo_realizado trg_trabajo_realizado_dirty; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_trabajo_realizado_dirty AFTER INSERT OR DELETE OR UPDATE ON core.trabajo_realizado FOR EACH ROW EXECUTE FUNCTION core.trg_dirty_por_ot_id();


--
-- Name: trabajo_realizado trg_trabajo_realizado_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_trabajo_realizado_set_updated_at BEFORE UPDATE ON core.trabajo_realizado FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: usuario trg_usuario_set_updated_at; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_usuario_set_updated_at BEFORE UPDATE ON core.usuario FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();


--
-- Name: adjunto adjunto_autor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.adjunto
    ADD CONSTRAINT adjunto_autor_id_fkey FOREIGN KEY (autor_id) REFERENCES core.usuario(id);


--
-- Name: adjunto adjunto_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.adjunto
    ADD CONSTRAINT adjunto_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: adjunto adjunto_retirado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.adjunto
    ADD CONSTRAINT adjunto_retirado_por_fkey FOREIGN KEY (retirado_por) REFERENCES core.usuario(id);


--
-- Name: adjunto adjunto_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.adjunto
    ADD CONSTRAINT adjunto_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: area area_empresa_ruc_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.area
    ADD CONSTRAINT area_empresa_ruc_id_fkey FOREIGN KEY (empresa_ruc_id) REFERENCES core.empresa_ruc(id);


--
-- Name: area area_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.area
    ADD CONSTRAINT area_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: catalogo_item catalogo_item_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.catalogo_item
    ADD CONSTRAINT catalogo_item_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: cecos cecos_area_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cecos
    ADD CONSTRAINT cecos_area_id_fkey FOREIGN KEY (area_id) REFERENCES core.area(id);


--
-- Name: cecos cecos_empresa_ruc_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cecos
    ADD CONSTRAINT cecos_empresa_ruc_id_fkey FOREIGN KEY (empresa_ruc_id) REFERENCES core.empresa_ruc(id);


--
-- Name: cecos cecos_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cecos
    ADD CONSTRAINT cecos_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: conversacion conversacion_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion
    ADD CONSTRAINT conversacion_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: conversacion_participante conversacion_participante_conversacion_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion_participante
    ADD CONSTRAINT conversacion_participante_conversacion_id_fkey FOREIGN KEY (conversacion_id) REFERENCES core.conversacion(id);


--
-- Name: conversacion_participante conversacion_participante_invitado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion_participante
    ADD CONSTRAINT conversacion_participante_invitado_por_fkey FOREIGN KEY (invitado_por) REFERENCES core.usuario(id);


--
-- Name: conversacion_participante conversacion_participante_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion_participante
    ADD CONSTRAINT conversacion_participante_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: conversacion_participante conversacion_participante_usuario_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion_participante
    ADD CONSTRAINT conversacion_participante_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES core.usuario(id);


--
-- Name: conversacion conversacion_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.conversacion
    ADD CONSTRAINT conversacion_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: correlativo correlativo_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.correlativo
    ADD CONSTRAINT correlativo_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: costo_unitario costo_unitario_area_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_area_id_fkey FOREIGN KEY (area_id) REFERENCES core.area(id);


--
-- Name: costo_unitario costo_unitario_cotizacion_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_cotizacion_id_fkey FOREIGN KEY (cotizacion_id) REFERENCES core.cotizacion(id);


--
-- Name: costo_unitario costo_unitario_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: costo_unitario costo_unitario_descripcion_normalizada_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_descripcion_normalizada_id_fkey FOREIGN KEY (descripcion_normalizada_id) REFERENCES core.descripcion_normalizada(id);


--
-- Name: costo_unitario costo_unitario_empresa_ruc_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_empresa_ruc_id_fkey FOREIGN KEY (empresa_ruc_id) REFERENCES core.empresa_ruc(id);


--
-- Name: costo_unitario costo_unitario_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: costo_unitario costo_unitario_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES core.proveedor(id);


--
-- Name: costo_unitario costo_unitario_sucursal_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_sucursal_id_fkey FOREIGN KEY (sucursal_id) REFERENCES core.sucursal(id);


--
-- Name: costo_unitario costo_unitario_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: costo_unitario costo_unitario_tipo_trabajo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_tipo_trabajo_id_fkey FOREIGN KEY (tipo_trabajo_id) REFERENCES core.tipo_trabajo(id);


--
-- Name: costo_unitario costo_unitario_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.costo_unitario
    ADD CONSTRAINT costo_unitario_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: cotizacion cotizacion_cargada_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT cotizacion_cargada_por_fkey FOREIGN KEY (cargada_por) REFERENCES core.usuario(id);


--
-- Name: cotizacion cotizacion_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT cotizacion_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: cotizacion cotizacion_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT cotizacion_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: cotizacion cotizacion_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT cotizacion_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES core.proveedor(id);


--
-- Name: cotizacion cotizacion_reemplaza_a_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT cotizacion_reemplaza_a_fkey FOREIGN KEY (reemplaza_a) REFERENCES core.cotizacion(id);


--
-- Name: cotizacion cotizacion_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT cotizacion_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: cotizacion cotizacion_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.cotizacion
    ADD CONSTRAINT cotizacion_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: descripcion_normalizada descripcion_normalizada_aprobada_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.descripcion_normalizada
    ADD CONSTRAINT descripcion_normalizada_aprobada_por_fkey FOREIGN KEY (aprobada_por) REFERENCES core.usuario(id);


--
-- Name: descripcion_normalizada descripcion_normalizada_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.descripcion_normalizada
    ADD CONSTRAINT descripcion_normalizada_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: descripcion_normalizada descripcion_normalizada_tipo_trabajo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.descripcion_normalizada
    ADD CONSTRAINT descripcion_normalizada_tipo_trabajo_id_fkey FOREIGN KEY (tipo_trabajo_id) REFERENCES core.tipo_trabajo(id);


--
-- Name: diagnostico diagnostico_aprobado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT diagnostico_aprobado_por_fkey FOREIGN KEY (aprobado_por) REFERENCES core.usuario(id);


--
-- Name: diagnostico diagnostico_autor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT diagnostico_autor_id_fkey FOREIGN KEY (autor_id) REFERENCES core.usuario(id);


--
-- Name: diagnostico diagnostico_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT diagnostico_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: diagnostico diagnostico_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT diagnostico_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: diagnostico diagnostico_reemplaza_a_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT diagnostico_reemplaza_a_fkey FOREIGN KEY (reemplaza_a) REFERENCES core.diagnostico(id);


--
-- Name: diagnostico diagnostico_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT diagnostico_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: diagnostico diagnostico_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.diagnostico
    ADD CONSTRAINT diagnostico_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: ejecucion ejecucion_confirmado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ejecucion
    ADD CONSTRAINT ejecucion_confirmado_por_fkey FOREIGN KEY (confirmado_por) REFERENCES core.usuario(id);


--
-- Name: ejecucion ejecucion_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ejecucion
    ADD CONSTRAINT ejecucion_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: ejecucion ejecucion_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ejecucion
    ADD CONSTRAINT ejecucion_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: ejecucion ejecucion_responsable_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ejecucion
    ADD CONSTRAINT ejecucion_responsable_id_fkey FOREIGN KEY (responsable_id) REFERENCES core.usuario(id);


--
-- Name: ejecucion ejecucion_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ejecucion
    ADD CONSTRAINT ejecucion_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: ejecucion ejecucion_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ejecucion
    ADD CONSTRAINT ejecucion_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: empresa_ruc empresa_ruc_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.empresa_ruc
    ADD CONSTRAINT empresa_ruc_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: liberacion_historial liberacion_historial_actor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.liberacion_historial
    ADD CONSTRAINT liberacion_historial_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES core.usuario(id);


--
-- Name: liberacion_historial liberacion_historial_orden_compra_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.liberacion_historial
    ADD CONSTRAINT liberacion_historial_orden_compra_id_fkey FOREIGN KEY (orden_compra_id) REFERENCES core.orden_compra(id);


--
-- Name: liberacion_historial liberacion_historial_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.liberacion_historial
    ADD CONSTRAINT liberacion_historial_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: liberacion_historial liberacion_historial_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.liberacion_historial
    ADD CONSTRAINT liberacion_historial_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: mensaje mensaje_autor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.mensaje
    ADD CONSTRAINT mensaje_autor_id_fkey FOREIGN KEY (autor_id) REFERENCES core.usuario(id);


--
-- Name: mensaje mensaje_conversacion_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.mensaje
    ADD CONSTRAINT mensaje_conversacion_id_fkey FOREIGN KEY (conversacion_id) REFERENCES core.conversacion(id);


--
-- Name: mensaje mensaje_responde_a_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.mensaje
    ADD CONSTRAINT mensaje_responde_a_fkey FOREIGN KEY (responde_a) REFERENCES core.mensaje(id);


--
-- Name: mensaje mensaje_retirado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.mensaje
    ADD CONSTRAINT mensaje_retirado_por_fkey FOREIGN KEY (retirado_por) REFERENCES core.usuario(id);


--
-- Name: mensaje mensaje_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.mensaje
    ADD CONSTRAINT mensaje_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: notificacion notificacion_destinatario_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.notificacion
    ADD CONSTRAINT notificacion_destinatario_id_fkey FOREIGN KEY (destinatario_id) REFERENCES core.usuario(id);


--
-- Name: notificacion notificacion_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.notificacion
    ADD CONSTRAINT notificacion_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: notificacion notificacion_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.notificacion
    ADD CONSTRAINT notificacion_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: orden_compra orden_compra_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_compra
    ADD CONSTRAINT orden_compra_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: orden_compra orden_compra_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_compra
    ADD CONSTRAINT orden_compra_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: orden_compra orden_compra_registrada_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_compra
    ADD CONSTRAINT orden_compra_registrada_por_fkey FOREIGN KEY (registrada_por) REFERENCES core.usuario(id);


--
-- Name: orden_compra orden_compra_solped_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_compra
    ADD CONSTRAINT orden_compra_solped_id_fkey FOREIGN KEY (solped_id) REFERENCES core.solped(id);


--
-- Name: orden_compra orden_compra_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_compra
    ADD CONSTRAINT orden_compra_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: orden_compra orden_compra_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_compra
    ADD CONSTRAINT orden_compra_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: orden_trabajo orden_trabajo_area_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_area_id_fkey FOREIGN KEY (area_id) REFERENCES core.area(id);


--
-- Name: orden_trabajo orden_trabajo_cecos_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_cecos_id_fkey FOREIGN KEY (cecos_id) REFERENCES core.cecos(id);


--
-- Name: orden_trabajo orden_trabajo_coordinador_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_coordinador_id_fkey FOREIGN KEY (coordinador_id) REFERENCES core.usuario(id);


--
-- Name: orden_trabajo orden_trabajo_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: orden_trabajo orden_trabajo_ejecutor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_ejecutor_id_fkey FOREIGN KEY (ejecutor_id) REFERENCES core.usuario(id);


--
-- Name: orden_trabajo orden_trabajo_emergencia_declarada_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_emergencia_declarada_por_fkey FOREIGN KEY (emergencia_declarada_por) REFERENCES core.usuario(id);


--
-- Name: orden_trabajo orden_trabajo_empresa_ruc_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_empresa_ruc_id_fkey FOREIGN KEY (empresa_ruc_id) REFERENCES core.empresa_ruc(id);


--
-- Name: orden_trabajo orden_trabajo_motivo_cancelacion_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_motivo_cancelacion_id_fkey FOREIGN KEY (motivo_cancelacion_id) REFERENCES core.catalogo_item(id);


--
-- Name: orden_trabajo orden_trabajo_motivo_derivacion_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_motivo_derivacion_id_fkey FOREIGN KEY (motivo_derivacion_id) REFERENCES core.catalogo_item(id);


--
-- Name: orden_trabajo orden_trabajo_ot_padre_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_ot_padre_id_fkey FOREIGN KEY (ot_padre_id) REFERENCES core.orden_trabajo(id);


--
-- Name: orden_trabajo orden_trabajo_solicitud_origen_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_solicitud_origen_id_fkey FOREIGN KEY (solicitud_origen_id) REFERENCES core.solicitud_trabajo(id);


--
-- Name: orden_trabajo orden_trabajo_sucursal_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_sucursal_id_fkey FOREIGN KEY (sucursal_id) REFERENCES core.sucursal(id);


--
-- Name: orden_trabajo orden_trabajo_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: orden_trabajo orden_trabajo_tipo_mantenimiento_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_tipo_mantenimiento_id_fkey FOREIGN KEY (tipo_mantenimiento_id) REFERENCES core.catalogo_item(id);


--
-- Name: orden_trabajo orden_trabajo_tipo_trabajo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_tipo_trabajo_id_fkey FOREIGN KEY (tipo_trabajo_id) REFERENCES core.tipo_trabajo(id);


--
-- Name: orden_trabajo orden_trabajo_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.orden_trabajo
    ADD CONSTRAINT orden_trabajo_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: ot_avance ot_avance_autor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_avance
    ADD CONSTRAINT ot_avance_autor_id_fkey FOREIGN KEY (autor_id) REFERENCES core.usuario(id);


--
-- Name: ot_avance ot_avance_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_avance
    ADD CONSTRAINT ot_avance_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: ot_avance ot_avance_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_avance
    ADD CONSTRAINT ot_avance_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: ot_cierre ot_cierre_cerrado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_cierre
    ADD CONSTRAINT ot_cierre_cerrado_por_fkey FOREIGN KEY (cerrado_por) REFERENCES core.usuario(id);


--
-- Name: ot_cierre ot_cierre_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_cierre
    ADD CONSTRAINT ot_cierre_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: ot_cierre ot_cierre_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_cierre
    ADD CONSTRAINT ot_cierre_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: ot_estado_historial ot_estado_historial_actor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_estado_historial
    ADD CONSTRAINT ot_estado_historial_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES core.usuario(id);


--
-- Name: ot_estado_historial ot_estado_historial_motivo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_estado_historial
    ADD CONSTRAINT ot_estado_historial_motivo_id_fkey FOREIGN KEY (motivo_id) REFERENCES core.catalogo_item(id);


--
-- Name: ot_estado_historial ot_estado_historial_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_estado_historial
    ADD CONSTRAINT ot_estado_historial_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: ot_estado_historial ot_estado_historial_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_estado_historial
    ADD CONSTRAINT ot_estado_historial_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: ot_evento ot_evento_actor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_evento
    ADD CONSTRAINT ot_evento_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES core.usuario(id);


--
-- Name: ot_evento ot_evento_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_evento
    ADD CONSTRAINT ot_evento_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: ot_evento ot_evento_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_evento
    ADD CONSTRAINT ot_evento_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: ot_incidencia ot_incidencia_autor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_incidencia
    ADD CONSTRAINT ot_incidencia_autor_id_fkey FOREIGN KEY (autor_id) REFERENCES core.usuario(id);


--
-- Name: ot_incidencia ot_incidencia_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_incidencia
    ADD CONSTRAINT ot_incidencia_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: ot_incidencia ot_incidencia_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_incidencia
    ADD CONSTRAINT ot_incidencia_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: ot_incidencia ot_incidencia_tipo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_incidencia
    ADD CONSTRAINT ot_incidencia_tipo_id_fkey FOREIGN KEY (tipo_id) REFERENCES core.catalogo_item(id);


--
-- Name: ot_pausa ot_pausa_motivo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_pausa
    ADD CONSTRAINT ot_pausa_motivo_id_fkey FOREIGN KEY (motivo_id) REFERENCES core.catalogo_item(id);


--
-- Name: ot_pausa ot_pausa_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_pausa
    ADD CONSTRAINT ot_pausa_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: ot_pausa ot_pausa_pausada_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_pausa
    ADD CONSTRAINT ot_pausa_pausada_por_fkey FOREIGN KEY (pausada_por) REFERENCES core.usuario(id);


--
-- Name: ot_pausa ot_pausa_reanudada_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_pausa
    ADD CONSTRAINT ot_pausa_reanudada_por_fkey FOREIGN KEY (reanudada_por) REFERENCES core.usuario(id);


--
-- Name: ot_pausa ot_pausa_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_pausa
    ADD CONSTRAINT ot_pausa_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: ot_reapertura ot_reapertura_cierre_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_reapertura
    ADD CONSTRAINT ot_reapertura_cierre_id_fkey FOREIGN KEY (cierre_id) REFERENCES core.ot_cierre(id);


--
-- Name: ot_reapertura ot_reapertura_motivo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_reapertura
    ADD CONSTRAINT ot_reapertura_motivo_id_fkey FOREIGN KEY (motivo_id) REFERENCES core.catalogo_item(id);


--
-- Name: ot_reapertura ot_reapertura_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_reapertura
    ADD CONSTRAINT ot_reapertura_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: ot_reapertura ot_reapertura_reabierta_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_reapertura
    ADD CONSTRAINT ot_reapertura_reabierta_por_fkey FOREIGN KEY (reabierta_por) REFERENCES core.usuario(id);


--
-- Name: ot_reapertura ot_reapertura_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.ot_reapertura
    ADD CONSTRAINT ot_reapertura_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: proveedor proveedor_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.proveedor
    ADD CONSTRAINT proveedor_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: regla_normalizacion regla_normalizacion_aprobada_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.regla_normalizacion
    ADD CONSTRAINT regla_normalizacion_aprobada_por_fkey FOREIGN KEY (aprobada_por) REFERENCES core.usuario(id);


--
-- Name: regla_normalizacion regla_normalizacion_descripcion_normalizada_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.regla_normalizacion
    ADD CONSTRAINT regla_normalizacion_descripcion_normalizada_id_fkey FOREIGN KEY (descripcion_normalizada_id) REFERENCES core.descripcion_normalizada(id);


--
-- Name: regla_normalizacion regla_normalizacion_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.regla_normalizacion
    ADD CONSTRAINT regla_normalizacion_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: rol_permiso rol_permiso_permiso_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.rol_permiso
    ADD CONSTRAINT rol_permiso_permiso_id_fkey FOREIGN KEY (permiso_id) REFERENCES core.permiso(id);


--
-- Name: rol_permiso rol_permiso_rol_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.rol_permiso
    ADD CONSTRAINT rol_permiso_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES core.rol(id);


--
-- Name: rol rol_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.rol
    ADD CONSTRAINT rol_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: seguimiento_administrativo seguimiento_administrativo_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.seguimiento_administrativo
    ADD CONSTRAINT seguimiento_administrativo_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: seguimiento_administrativo seguimiento_administrativo_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.seguimiento_administrativo
    ADD CONSTRAINT seguimiento_administrativo_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: seguimiento_administrativo seguimiento_administrativo_revisado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.seguimiento_administrativo
    ADD CONSTRAINT seguimiento_administrativo_revisado_por_fkey FOREIGN KEY (revisado_por) REFERENCES core.usuario(id);


--
-- Name: seguimiento_administrativo seguimiento_administrativo_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.seguimiento_administrativo
    ADD CONSTRAINT seguimiento_administrativo_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: seguimiento_administrativo seguimiento_administrativo_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.seguimiento_administrativo
    ADD CONSTRAINT seguimiento_administrativo_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: solicitud_decision solicitud_decision_actor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_decision
    ADD CONSTRAINT solicitud_decision_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES core.usuario(id);


--
-- Name: solicitud_decision solicitud_decision_destinatario_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_decision
    ADD CONSTRAINT solicitud_decision_destinatario_id_fkey FOREIGN KEY (destinatario_id) REFERENCES core.usuario(id);


--
-- Name: solicitud_decision solicitud_decision_motivo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_decision
    ADD CONSTRAINT solicitud_decision_motivo_id_fkey FOREIGN KEY (motivo_id) REFERENCES core.catalogo_item(id);


--
-- Name: solicitud_decision solicitud_decision_solicitud_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_decision
    ADD CONSTRAINT solicitud_decision_solicitud_id_fkey FOREIGN KEY (solicitud_id) REFERENCES core.solicitud_trabajo(id);


--
-- Name: solicitud_decision solicitud_decision_solicitud_relacionada_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_decision
    ADD CONSTRAINT solicitud_decision_solicitud_relacionada_id_fkey FOREIGN KEY (solicitud_relacionada_id) REFERENCES core.solicitud_trabajo(id);


--
-- Name: solicitud_decision solicitud_decision_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_decision
    ADD CONSTRAINT solicitud_decision_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_area_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_area_id_fkey FOREIGN KEY (area_id) REFERENCES core.area(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_coordinador_revisor_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_coordinador_revisor_id_fkey FOREIGN KEY (coordinador_revisor_id) REFERENCES core.usuario(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_empresa_ruc_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_empresa_ruc_id_fkey FOREIGN KEY (empresa_ruc_id) REFERENCES core.empresa_ruc(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_impacto_operativo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_impacto_operativo_id_fkey FOREIGN KEY (impacto_operativo_id) REFERENCES core.catalogo_item(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_motivo_rechazo_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_motivo_rechazo_id_fkey FOREIGN KEY (motivo_rechazo_id) REFERENCES core.catalogo_item(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_solicitante_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_solicitante_id_fkey FOREIGN KEY (solicitante_id) REFERENCES core.usuario(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_solicitud_principal_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_solicitud_principal_id_fkey FOREIGN KEY (solicitud_principal_id) REFERENCES core.solicitud_trabajo(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_sucursal_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_sucursal_id_fkey FOREIGN KEY (sucursal_id) REFERENCES core.sucursal(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: solicitud_trabajo solicitud_trabajo_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solicitud_trabajo
    ADD CONSTRAINT solicitud_trabajo_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: solped solped_anulada_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT solped_anulada_por_fkey FOREIGN KEY (anulada_por) REFERENCES core.usuario(id);


--
-- Name: solped solped_cotizacion_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT solped_cotizacion_id_fkey FOREIGN KEY (cotizacion_id) REFERENCES core.cotizacion(id);


--
-- Name: solped solped_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT solped_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: solped solped_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT solped_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: solped solped_reemplaza_a_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT solped_reemplaza_a_fkey FOREIGN KEY (reemplaza_a) REFERENCES core.solped(id);


--
-- Name: solped solped_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT solped_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: solped solped_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.solped
    ADD CONSTRAINT solped_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: sucursal_empresa_ruc sucursal_empresa_ruc_empresa_ruc_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sucursal_empresa_ruc
    ADD CONSTRAINT sucursal_empresa_ruc_empresa_ruc_id_fkey FOREIGN KEY (empresa_ruc_id) REFERENCES core.empresa_ruc(id);


--
-- Name: sucursal_empresa_ruc sucursal_empresa_ruc_sucursal_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sucursal_empresa_ruc
    ADD CONSTRAINT sucursal_empresa_ruc_sucursal_id_fkey FOREIGN KEY (sucursal_id) REFERENCES core.sucursal(id);


--
-- Name: sucursal_empresa_ruc sucursal_empresa_ruc_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sucursal_empresa_ruc
    ADD CONSTRAINT sucursal_empresa_ruc_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: sucursal sucursal_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sucursal
    ADD CONSTRAINT sucursal_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: tenant_configuracion tenant_configuracion_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant_configuracion
    ADD CONSTRAINT tenant_configuracion_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: tipo_trabajo tipo_trabajo_padre_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tipo_trabajo
    ADD CONSTRAINT tipo_trabajo_padre_id_fkey FOREIGN KEY (padre_id) REFERENCES core.tipo_trabajo(id);


--
-- Name: tipo_trabajo tipo_trabajo_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tipo_trabajo
    ADD CONSTRAINT tipo_trabajo_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: trabajo_realizado trabajo_realizado_created_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT trabajo_realizado_created_by_fkey FOREIGN KEY (created_by) REFERENCES core.usuario(id);


--
-- Name: trabajo_realizado trabajo_realizado_declarado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT trabajo_realizado_declarado_por_fkey FOREIGN KEY (declarado_por) REFERENCES core.usuario(id);


--
-- Name: trabajo_realizado trabajo_realizado_ot_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT trabajo_realizado_ot_id_fkey FOREIGN KEY (ot_id) REFERENCES core.orden_trabajo(id);


--
-- Name: trabajo_realizado trabajo_realizado_resultado_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT trabajo_realizado_resultado_id_fkey FOREIGN KEY (resultado_id) REFERENCES core.catalogo_item(id);


--
-- Name: trabajo_realizado trabajo_realizado_revisado_por_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT trabajo_realizado_revisado_por_fkey FOREIGN KEY (revisado_por) REFERENCES core.usuario(id);


--
-- Name: trabajo_realizado trabajo_realizado_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT trabajo_realizado_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: trabajo_realizado trabajo_realizado_updated_by_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.trabajo_realizado
    ADD CONSTRAINT trabajo_realizado_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES core.usuario(id);


--
-- Name: usuario_alcance usuario_alcance_area_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_alcance
    ADD CONSTRAINT usuario_alcance_area_id_fkey FOREIGN KEY (area_id) REFERENCES core.area(id);


--
-- Name: usuario_alcance usuario_alcance_empresa_ruc_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_alcance
    ADD CONSTRAINT usuario_alcance_empresa_ruc_id_fkey FOREIGN KEY (empresa_ruc_id) REFERENCES core.empresa_ruc(id);


--
-- Name: usuario_alcance usuario_alcance_sucursal_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_alcance
    ADD CONSTRAINT usuario_alcance_sucursal_id_fkey FOREIGN KEY (sucursal_id) REFERENCES core.sucursal(id);


--
-- Name: usuario_alcance usuario_alcance_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_alcance
    ADD CONSTRAINT usuario_alcance_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- Name: usuario_alcance usuario_alcance_usuario_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_alcance
    ADD CONSTRAINT usuario_alcance_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES core.usuario(id);


--
-- Name: usuario_rol usuario_rol_rol_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_rol
    ADD CONSTRAINT usuario_rol_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES core.rol(id);


--
-- Name: usuario_rol usuario_rol_usuario_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario_rol
    ADD CONSTRAINT usuario_rol_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES core.usuario(id);


--
-- Name: usuario usuario_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usuario
    ADD CONSTRAINT usuario_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenant(id);


--
-- PostgreSQL database dump complete
--


