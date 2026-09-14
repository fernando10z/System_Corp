#!/usr/bin/env bash
# =============================================================================
# Despliegue. Las migraciones van ANTES que el código: son aditivas e
# idempotentes, así que la versión anterior del backend sigue funcionando
# contra el esquema nuevo mientras dura el despliegue.
# =============================================================================
set -euo pipefail
ROOT="${MIP_ROOT:-/srv/mip/repo/System_Corp}"
cd "$ROOT"

echo "▸ Código"
git pull --ff-only

echo "▸ Migraciones"
bash db/scripts/apply-migrations.sh

echo "▸ Backend"
(cd backend && npm ci --omit=dev=false && npm run build)

echo "▸ Frontend"
(cd frontend && npm ci && npm run build)

echo "▸ Recarga"
pm2 reload infra/pm2/ecosystem.config.js

sleep 3
bash infra/scripts/healthcheck.sh
echo "✓ Desplegado"
