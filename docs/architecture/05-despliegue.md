# Despliegue

## Desarrollo

`infra/docker/docker-compose.dev.yml` levanta postgres 16, redis 7 y minio.
Los puertos están desplazados a propósito (5436, 6383, 9110/9111) para poder
tener otros proyectos corriendo a la vez.

El backend escucha en 3200 y el frontend en 5180, por el mismo motivo.

## Producción

`infra/pm2/ecosystem.config.js` define dos procesos: la API compilada y el
frontend estático servido por `serve`. Delante va nginx
(`infra/nginx/sites-available/`) con TLS y las cabeceras de seguridad.

### Secuencia de despliegue

```bash
git pull
bash db/scripts/apply-migrations.sh   # idempotente: seguro de re-ejecutar
cd backend  && npm ci && npm run build
cd frontend && npm ci && npm run build
pm2 reload infra/pm2/ecosystem.config.js
curl -fsS https://api.<dominio>/api/health
```

Las migraciones van **antes** que el código: son aditivas e idempotentes, así que
la versión anterior del backend sigue funcionando contra el esquema nuevo
mientras dura el despliegue.

## Lo que hay que cambiar antes de producción

- `mip_app_user` tiene la contraseña `cambiar_en_deploy` en `90_grants.sql`.
- El super admin sembrado usa `CambiarEnDeploy2026`.
- `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET` y `COOKIE_SECRET` — generar con
  `openssl rand -base64 48`. La validación de arranque exige 32 y 16 caracteres,
  pero no comprueba que no sean el valor de ejemplo.
- `DATABASE_URL` debe apuntar a `mip_app_user`, **no** al superusuario: si apunta
  al superusuario se salta el modelo de seguridad completo del proyecto.
- `LOG_PRETTY=false` — en producción el JSON crudo es lo que consumen los
  agregadores.

## Adjuntos sin MinIO (`STORAGE_DRIVER=fs`)

El almacén es un puerto (`AlmacenArchivos`) con dos adaptadores. Por defecto es
`minio` (cualquier S3). En un servidor de un solo nodo se puede usar `fs`:

```bash
STORAGE_DRIVER=fs
STORAGE_FS_ROOT=/ruta/absoluta/adjuntos       # entra en el backup de esa carpeta
STORAGE_URL_SECRET=$(openssl rand -base64 48)  # firma HMAC de los enlaces
STORAGE_FS_URL_BASE=https://<dominio>/api      # cómo llega el navegador a la API
```

La descarga sigue el mismo contrato que con S3: `GET /adjuntos/:id/descarga`
comprueba tenant y alcance en la base y devuelve un enlace temporal
(`STORAGE_URL_TTL_MIN`) a `GET /archivos?t=…`, que verifica la firma antes de
leer el disco. Sólo PDF, imágenes, video y texto plano se muestran en línea; el
resto se fuerza a descarga.
