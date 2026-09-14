#!/usr/bin/env bash
# =============================================================================
# Restaura un respaldo. SOBRESCRIBE la base de destino, así que pide
# confirmación escribiendo el nombre de la base.
# =============================================================================
set -euo pipefail

ARCHIVO="${1:-}"
if [[ -z "$ARCHIVO" || ! -f "$ARCHIVO" ]]; then
  echo "Uso: bash db/scripts/restore.sh <archivo.dump>"
  exit 1
fi

DB_HOST="${DB_HOST:-localhost}"; DB_PORT="${DB_PORT:-5436}"
DB_USER="${DB_USER:-postgres}"; DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-mip_dev}"

echo "Se va a restaurar sobre '$DB_NAME'. Los datos actuales se pierden."
read -r -p "Escriba el nombre de la base para confirmar: " CONFIRMA
[[ "$CONFIRMA" == "$DB_NAME" ]] || { echo "✗ Cancelado."; exit 1; }

export PGPASSWORD="$DB_PASSWORD"
pg_restore -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
  --clean --if-exists --no-owner --no-privileges "$ARCHIVO"
echo "✓ Restaurado. Ejecute db/scripts/apply-migrations.sh por si el respaldo es anterior a alguna migración."
