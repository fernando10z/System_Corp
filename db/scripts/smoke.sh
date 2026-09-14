#!/usr/bin/env bash
# Ejecuta el smoke del ciclo completo y muestra el árbol de trazabilidad resultante.
set -euo pipefail
DB_HOST="${DB_HOST:-localhost}"; DB_PORT="${DB_PORT:-5436}"
DB_USER="${DB_USER:-postgres}"; DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-mip_dev}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PGPASSWORD="$DB_PASSWORD"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 --no-psqlrc -f "$DIR/smoke-trazabilidad.sql"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 --no-psqlrc -f "$DIR/smoke-verificar.sql"
