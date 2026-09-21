#!/usr/bin/env bash
# =============================================================================
# Suite de regresión de MIP.
#
# Recorre TODOS los flujos del producto contra la API real y después pasa la
# revisión de seguridad. Está pensada para que el área de sistemas del cliente
# la ejecute por su cuenta antes de aprobar un despliegue: no hace falta leerse
# el código para saber si algo se rompió.
#
#   bash scripts/pruebas.sh
#
# Requiere la pila levantada:
#   docker compose -f infra/docker/docker-compose.dev.yml up -d
#   bash db/scripts/apply-migrations.sh
#   cd backend && npm run start:dev
# =============================================================================
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API="${API_BASE_URL:-http://localhost:3200/api}"
CONTENEDOR_DB="${DB_CONTAINER:-mip_postgres_dev}"
fallos=0

echo "▸ Comprobando que la API responde en $API"
if ! curl -sf -o /dev/null "$API/health"; then
  echo "✗ La API no responde. Levante el backend antes de pasar la suite."
  exit 1
fi

echo
echo "═══ 1/5 · flujos funcionales ═══"
API_BASE_URL="$API" node "$RAIZ/scripts/pruebas-flujos.mjs" || fallos=$((fallos+1))

echo
echo "═══ 2/5 · criterios de aceptación del documento (QA-01..QA-30) ═══"
API_BASE_URL="$API" node "$RAIZ/scripts/pruebas-qa.mjs" || fallos=$((fallos+1))

echo
echo "═══ 3/5 · revisión de seguridad ═══"
API_BASE_URL="$API" node "$RAIZ/scripts/pruebas-seguridad.mjs" || fallos=$((fallos+1))

echo
echo "═══ 4/5 · importación de cotización desde PDF ═══"
API_BASE_URL="$API" node "$RAIZ/scripts/pruebas-cotizacion-pdf.mjs" || fallos=$((fallos+1))

echo
echo "═══ 5/5 · bloqueo de credenciales (en la base) ═══"
if docker ps --format '{{.Names}}' | grep -q "^${CONTENEDOR_DB}$"; then
  docker exec -i -e PGPASSWORD="${DB_PASSWORD:-postgres}" "$CONTENEDOR_DB" \
    psql -U "${DB_USER:-postgres}" -d "${DB_NAME:-mip_dev}" --no-psqlrc -f - \
    < "$RAIZ/db/scripts/smoke-bloqueo-credenciales.sql" || fallos=$((fallos+1))
else
  echo "~ contenedor $CONTENEDOR_DB no encontrado; se omite"
fi

echo
if [ "$fallos" -eq 0 ]; then
  echo "✓ Suite completa sin hallazgos."
else
  echo "✗ $fallos bloque(s) con hallazgos. Revise la salida de arriba."
fi
exit "$fallos"
