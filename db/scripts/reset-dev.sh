#!/usr/bin/env bash
# =============================================================================
# Borra los schemas de MIP y los reconstruye desde cero. SÓLO desarrollo.
#
# Exige ALLOW_RESET=yes de forma explícita: es demasiado fácil ejecutar esto
# apuntando sin querer a una base que importa.
# =============================================================================
set -euo pipefail

if [[ "${ALLOW_RESET:-no}" != "yes" ]]; then
  echo "✗ Protección activa. Para reconstruir la base ejecute:"
  echo "    ALLOW_RESET=yes bash db/scripts/reset-dev.sh"
  exit 1
fi

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5436}"
DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-mip_dev}"

export PGPASSWORD="$DB_PASSWORD"
echo "▸ Eliminando schemas de $DB_NAME"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 --quiet <<'SQL'
DROP SCHEMA IF EXISTS app, core, internal, audit CASCADE;
-- 90_grants concede USAGE sobre public al rol de aplicación; sin revocarlo, el
-- DROP ROLE falla por dependencia de privilegios.
REVOKE ALL ON SCHEMA public FROM mip_app_user;
DROP OWNED BY mip_app_user;
DROP ROLE IF EXISTS mip_app_user;
SQL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/apply-migrations.sh"
