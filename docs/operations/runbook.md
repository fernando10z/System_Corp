# Runbook

## Comprobar que todo está bien

```bash
curl -fsS http://localhost:3200/api/health | python3 -m json.tool
```

`estado: operativo` exige la base. Redis y el almacén pueden estar caídos:
degradan funcionalidad concreta (revocar sesiones, subir adjuntos) sin tumbar la
aplicación.

## Síntomas y qué mirar

### "La trazabilidad de una OT se ve desactualizada"

El árbol se refresca de forma perezosa. Abrir la ficha ya lo reconstruye. Si aun
así no cuadra:

```sql
SELECT app.fn_trazabilidad_verificar(<user>, <tenant>, true, 200);
```

`desviadas` distinto de vacío significa que un trigger de marcado dejó de
dispararse. Para reconstruir todo lo pendiente:

```sql
SELECT app.sp_trazabilidad_refrescar_pendientes(1000);
```

Para forzar una en concreto:

```sql
SELECT app.sp_ot_trazabilidad_refrescar('<ot_id>', true);
```

### "No puedo cerrar una OT"

Por orden de probabilidad:

1. El trabajo realizado no está **aprobado** — sin revisión aprobada no hay cierre.
2. Hay una **derivada bloqueante** abierta. La pestaña Derivadas la señala.
3. Hay pendientes administrativos y falta confirmar. No es un error: la interfaz
   pide la confirmación y una observación obligatoria.

### "Un usuario no ve una OT que debería ver"

Casi siempre es alcance organizacional, no permisos:

```sql
SELECT * FROM core.usuario_alcance WHERE usuario_id = '<id>';
```

Sin filas, el usuario no está restringido a nivel organizacional. Con filas, sólo
ve lo que casa; recuerde que `NULL` en un nivel significa "todo ese nivel".

### "Un stored procedure devuelve INTERNAL_ERROR"

`error.sqlstate` trae el SQLSTATE crudo. Si es un código de PostgreSQL y no uno
de la clase `MIP`, es un fallo real, no una regla de negocio. El `request_id` de
la respuesta aparece en el log y en `audit.audit_log.request_id`.

### "El correo no sale"

Es esperado si `MAIL_ENABLED=false`. Las notificaciones internas funcionan igual:
el correo es una copia, no la fuente de verdad. Los fallos de entrega quedan en
`core.notificacion.error_envio` y no revierten ninguna operación de negocio.

## Tareas periódicas

| Cada | Qué |
|---|---|
| día | Respaldo (ver `backup-restore.md`) |
| semana | `fn_trazabilidad_verificar` sobre una muestra |
| semana | Revisar `core.notificacion` en estado `fallida` |
| mes | `VACUUM ANALYZE` sobre `core.ot_evento` y `audit.audit_log` |

## Lo que NUNCA hay que hacer

- `DELETE` sobre `core.ot_evento` o `audit.audit_log`. Están bloqueados por
  trigger y por privilegios, y esquivarlo destruye la evidencia que justifica
  todo el sistema.
- Editar `core.orden_trabajo.estado` a mano. Las transiciones pasan por
  `app.sp_ot_cambiar_estado`, que valida el Anexo A y deja historial.
- Poner el superusuario de PostgreSQL en `DATABASE_URL`. Anula el modelo de
  seguridad completo.
