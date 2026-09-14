#!/usr/bin/env bash
# =============================================================================
# Aplica todas las migraciones en orden alfanumérico.
#
# Cada archivo es idempotente (CREATE ... IF NOT EXISTS, CREATE OR REPLACE,
# ON CONFLICT DO NOTHING), así que correr esto dos veces seguidas debe terminar
# sin un solo error. Si falla, falla en el primer problema: ON_ERROR_STOP=1.
#
# A diferencia del proyecto hermano, aquí el orden alfanumérico ES el orden
# correcto: las semillas van en 89_seeds.sql, antes de 90_grants.sql, para que
# se creen como owner y no haga falta una excepción al orden.
# =============================================================================
set -euo pipefail

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5436}"
DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-mip_dev}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/../migrations"

export PGPASSWORD="$DB_PASSWORD"
PSQL=(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"
      -v ON_ERROR_STOP=1 --quiet --no-psqlrc)

echo "▸ Aplicando migraciones sobre $DB_NAME@$DB_HOST:$DB_PORT"
for f in "$MIGRATIONS_DIR"/*.sql; do
  echo "  · $(basename "$f")"
  "${PSQL[@]}" -f "$f" > /dev/null
done
echo "✓ Migraciones aplicadas"
