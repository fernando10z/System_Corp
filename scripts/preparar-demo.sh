#!/usr/bin/env bash
# =============================================================================
# El ciclo completo: probar, limpiar y dejar el sistema con datos de muestra.
#
#   1 · pasa la suite entera (flujos, los 30 criterios del documento, seguridad)
#   2 · borra TODO lo transaccional, incluido lo que dejaron las pruebas
#   3 · siembra un juego de demostración llamando a la API, no insertando filas
#   4 · reparte las fechas en el tiempo para que no parezca recién creado
#   5 · archiva el PDF de cada cotización, ya con su fecha definitiva
#   6 · comprueba que el árbol de trazabilidad quedó íntegro
#
# Al terminar, el sistema está poblado y verificado. Es lo que se ejecuta antes
# de enseñárselo a alguien.
#
#   bash scripts/preparar-demo.sh
#
# ⚠  Nunca contra datos reales: el paso 2 borra.
# =============================================================================
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API="${API_BASE_URL:-http://localhost:3200/api}"
DB="${DB_CONTAINER:-mip_postgres_dev}"
psql_mip() { docker exec -i -e PGPASSWORD="${DB_PASSWORD:-postgres}" "$DB" psql -U "${DB_USER:-postgres}" -d "${DB_NAME:-mip_dev}" --no-psqlrc "$@"; }

# El login tiene un tope por IP; la suite lo consume. Se espera a que se libere
# en vez de fallar con un 429 que no dice nada del producto.
esperar_login() {
  for _ in $(seq 1 40); do
    curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
      -d '{"email":"admin@mip.local","password":"'"${CLAVE_ADMIN:-CambiarEnDeploy2026}"'"}' | grep -q accessToken && return 0
    sleep 5
  done
  echo "✗ el login no se liberó"; return 1
}

curl -sf -o /dev/null "$API/health" || { echo "✗ La API no responde en $API"; exit 1; }

echo "═══ 1/6 · suite completa ═══"
bash "$RAIZ/scripts/pruebas.sh" || { echo "✗ La suite falló. No se siembra nada sobre un sistema que no pasa sus pruebas."; exit 1; }

echo
echo "═══ 2/6 · limpieza de lo transaccional ═══"
psql_mip -v ON_ERROR_STOP=1 -c "SET mip.confirmo_borrado = 'si';" -f - < "$RAIZ/db/scripts/limpiar-transaccional.sql" | tail -3

echo
echo "═══ 3/6 · datos de demostración ═══"
esperar_login
node "$RAIZ/scripts/datos-demo.mjs"

echo
echo "═══ 4/6 · repartir las fechas ═══"
psql_mip -v ON_ERROR_STOP=1 -c "SET mip.confirmo_fechas_demo = 'si';" -f - < "$RAIZ/db/scripts/fechas-demo.sql" | tail -3

echo
echo "═══ 5/6 · PDF de las cotizaciones ═══"
esperar_login
node "$RAIZ/scripts/adjuntar-pdfs-demo.mjs"

echo
echo "═══ 6/6 · integridad del árbol ═══"
esperar_login
node - <<'JS'
const BASE = process.env.API_BASE_URL ?? "http://localhost:3200/api";
const t = (await (await fetch(`${BASE}/auth/login`, { method: "POST", headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email: "admin@mip.local", password: process.env.CLAVE_ADMIN ?? "CambiarEnDeploy2026" }) })).json()).data.accessToken;
const h = { Authorization: `Bearer ${t}` };
// Abrir cada ficha fuerza el refresco perezoso del árbol tras mover las fechas.
const ots = (await (await fetch(`${BASE}/ot?page=1&pageSize=100`, { headers: h })).json()).data ?? [];
for (const o of ots) await fetch(`${BASE}/ot/${o.id}`, { headers: h });
const v = (await (await fetch(`${BASE}/ot/verificar-trazabilidad`, { headers: h })).json()).data;
console.log(`  revisadas ${v.revisadas} · desviadas ${v.desviadas.length} · sucias ${v.sucias_pendientes}`);
if (!v.integridad_ok) { console.log("  ✗ el árbol quedó desviado"); process.exit(1); }
console.log("  ✓ árbol de trazabilidad íntegro");
JS
echo
echo "✓ Sistema probado, limpio y poblado. Entre en http://localhost:5174"
