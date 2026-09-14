#!/usr/bin/env bash
# =============================================================================
# Respaldo completo en formato comprimido (-Fc), que permite restaurar
# selectivamente.
#
# OJO: esto NO respalda los adjuntos. Los bytes viven en MinIO/S3 y la base sólo
# guarda la storage_key. Ver docs/operations/backup-restore.md.
# =============================================================================
set -euo pipefail

DB_HOST="${DB_HOST:-localhost}"; DB_PORT="${DB_PORT:-5436}"
DB_USER="${DB_USER:-postgres}"; DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-mip_dev}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups"
mkdir -p "$DIR"
ARCHIVO="$DIR/mip-$(date +%Y%m%d-%H%M%S).dump"

export PGPASSWORD="$DB_PASSWORD"
echo "▸ Respaldando $DB_NAME → $ARCHIVO"
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -Fc -f "$ARCHIVO"
echo "✓ $(du -h "$ARCHIVO" | cut -f1)"
echo "  Recuerde respaldar también el bucket de adjuntos."
