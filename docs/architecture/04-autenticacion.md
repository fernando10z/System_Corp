# Autenticación y autorización

## Tokens

- **Acceso** · 15 min. Lleva `sub`, `email`, `tenant_id`, `is_super_admin`,
  `roles` y `permisos`. Es lo que el frontend usa para pintar el menú.
- **Refresh** · 7 d, con un `jti` en whitelist de Redis. Revocar una sesión es
  borrar su `jti`, sin esperar a que caduque el token.

La contraseña se verifica **dentro de la base** con `pgcrypto`: en claro no sale
de la transacción, y el backend nunca ve el hash.

Si Redis no está disponible, el login sigue funcionando y lo que se pierde es la
capacidad de revocar. El servicio degrada en lugar de tumbar la aplicación, y lo
deja claro en el log.

En cada refresh se **relee el perfil**: si a un usuario le cambiaron los roles o
lo inactivaron, el token nuevo ya lo refleja.

## Tres capas de autorización

1. **Frontend** — `useAuth().puede(permiso)` decide qué se pinta. Es comodidad,
   no seguridad.
2. **Backend** — `@Roles(...)` filtra por rol de forma gruesa. Opt-in: sólo actúa
   donde está el decorador.
3. **Base de datos** — `internal.assert_permiso()` e `internal.assert_alcance()`
   deciden de verdad. Aunque alguien fuerce una petición, la operación se
   rechaza aquí.

La matriz del Anexo B se siembra en `89_seeds.sql`. Es una **base funcional**,
no la política de seguridad final de cada organización: se puede reasignar desde
la pantalla de Roles, y cada cambio queda en la auditoría.

## Poda por permisos

`app.fn_ot_obtener()` recorta el árbol antes de devolverlo:

- Sin `costos:ver` → se quitan `costos` y `cotizaciones`.
- Sin `administrativo:ver` → se quita `administrativo`, se anulan `empresa_ruc` y
  `cecos`, y se filtran los mensajes internos.

Es el criterio QA-18, y se aplica en la base porque el frontend no es un lugar
donde esconder datos.
