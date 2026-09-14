# Infraestructura

- `docker/` — compose de desarrollo (postgres 5436, redis 6383, minio 9110/9111)
  con puertos desplazados para convivir con otros proyectos.
- `nginx/` — vhosts de API y aplicación, con TLS y cabeceras de seguridad.
- `pm2/` — topología de producción: `mip-api` y `mip-web`.
- `scripts/` — despliegue y comprobación de salud.

Dos ajustes que suelen olvidarse y dan problemas difíciles de diagnosticar:

1. `client_max_body_size` de nginx debe ir alineado con `BODY_LIMIT_BYTES` del
   backend. Si nginx corta antes, el usuario ve un 413 sin explicación.
2. `index.html` no debe cachearse. Si se cachea, tras un despliegue los usuarios
   siguen pidiendo los assets antiguos, que ya no existen.
