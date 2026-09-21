#!/usr/bin/env bash
# =============================================================================
# Levanta MIP a partir del volcado, sin aplicar migraciones ni sembrar nada.
#
# Es el camino corto para usar el sistema en otra máquina: deja la base con el
# esquema completo, los stored procedures y el juego de datos de demostración.
#
#   bash db/scripts/restaurar-dump.sh
#
# El camino largo —migraciones desde cero y siembra por la API— sigue siendo el
# de siempre y es el que vale para un entorno real:
#
#   bash db/scripts/apply-migrations.sh && bash scripts/preparar-demo.sh
#
# Funciona con la base en Docker (por defecto) o contra un PostgreSQL normal:
#
#   DB_CONTAINER=""  DB_HOST=mi-servidor  bash db/scripts/restaurar-dump.sh
#
# ⚠  BORRA la base de destino. Nunca contra datos reales.
# =============================================================================
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DUMP="$RAIZ/db/dump/mip_demo.sql"
GRANTS="$RAIZ/db/migrations/90_grants.sql"

DB_CONTAINER="${DB_CONTAINER-mip_postgres_dev}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5436}"
DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-mip_dev}"

[ -f "$DUMP" ] || { echo "✗ No se encuentra $DUMP"; exit 1; }

# Con contenedor se entra por docker exec; sin él, con el psql de la máquina.
if [ -n "$DB_CONTAINER" ] && docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${DB_CONTAINER}$"; then
  psql_admin() { docker exec -i -e PGPASSWORD="$DB_PASSWORD" "$DB_CONTAINER" psql -U "$DB_USER" -d postgres --no-psqlrc "$@"; }
  psql_mip()   { docker exec -i -e PGPASSWORD="$DB_PASSWORD" "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" --no-psqlrc "$@"; }
  echo "▸ Restaurando en el contenedor $DB_CONTAINER"
else
  command -v psql >/dev/null || { echo "✗ No hay contenedor $DB_CONTAINER ni psql instalado."; exit 1; }
  export PGPASSWORD="$DB_PASSWORD"
  psql_admin() { psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres --no-psqlrc "$@"; }
  psql_mip()   { psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" --no-psqlrc "$@"; }
  echo "▸ Restaurando en $DB_HOST:$DB_PORT"
fi

echo "▸ Preparando la base $DB_NAME"
# Se corta cualquier sesión abierta: con el backend arriba, DROP DATABASE falla.
psql_admin -v ON_ERROR_STOP=1 -q -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" > /dev/null
psql_admin -v ON_ERROR_STOP=1 -q -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql_admin -v ON_ERROR_STOP=1 -q -c "CREATE DATABASE $DB_NAME;"

echo "▸ Cargando el volcado"
psql_mip -v ON_ERROR_STOP=1 -q < "$DUMP" > /dev/null

# El volcado se genera sin permisos para que restaure bajo cualquier usuario;
# el rol de la API y sus GRANT se aplican aquí.
echo "▸ Aplicando los permisos de la aplicación"
psql_mip -v ON_ERROR_STOP=1 -q < "$GRANTS" > /dev/null

echo "▸ Comprobando"
psql_mip -t -c "SELECT '  órdenes de trabajo: ' || count(*) FROM core.orden_trabajo WHERE deleted_at IS NULL;"
psql_mip -t -c "SELECT '  solicitudes: '        || count(*) FROM core.solicitud_trabajo;"
psql_mip -t -c "SELECT '  usuarios: '           || count(*) FROM core.usuario WHERE estado = 'activo';"
psql_mip -t -c "SELECT '  stored procedures: '  || count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'app';"

echo
echo "✓ Base restaurada. Arranque el backend y entre en http://localhost:5174"
