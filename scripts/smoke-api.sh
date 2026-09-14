#!/usr/bin/env bash
# =============================================================================
# smoke-api.sh · Recorre el ciclo completo POR HTTP, con un usuario por rol.
#
# Complementa a db/scripts/smoke.sh: aquél prueba los stored procedures; éste
# prueba que el sobre {ok,data,meta}, la autenticación, los roles y la poda por
# permisos funcionan de extremo a extremo.
#
# Requiere la API levantada y la base sembrada.
#   Uso: bash scripts/smoke-api.sh
# =============================================================================
set -euo pipefail
API="${API:-http://localhost:3200/api}"
PASS="${PASS:-ClaveSegura2026}"

token() {
  curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
    -d "{\"email\":\"$1\",\"password\":\"$2\"}" |
    python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit('login falló: '+str(d.get('error'))) if not d.get('ok') else print(d['data']['accessToken'])"
}
jq_() { python3 -c "import json,sys; d=json.load(sys.stdin); print(eval(sys.argv[1]))" "$1"; }

echo "▸ autenticando los cuatro roles"
T_SOL=$(token solicitante@demo.local "$PASS")
T_COO=$(token coord@demo.local "$PASS")
T_TEC=$(token tecnico@demo.local "$PASS")
T_ABA=$(token abasto@demo.local "$PASS")
echo "  ✓ solicitante, coordinador, técnico y abastecimiento"

AREA=$(curl -s -H "Authorization: Bearer $T_COO" "$API/organizacion/areas" | jq_ "d['data'][0]['id']")

echo "▸ el solicitante reporta una necesidad"
SOL=$(curl -s -X POST "$API/solicitudes" -H "Authorization: Bearer $T_SOL" -H 'Content-Type: application/json' \
  -d "{\"titulo\":\"Ruido anormal en compresor 2\",
       \"descripcion\":\"El compresor 2 hace un ruido metalico intermitente desde el turno noche.\",
       \"lugar\":\"Sala de compresores, nivel 1\",
       \"areaId\":\"$AREA\",\"prioridadPercibida\":\"alta\"}")
SOL_ID=$(echo "$SOL" | jq_ "d['data']['id']")
echo "  ✓ $(echo "$SOL" | jq_ "d['data']['numero']") creada"

echo "▸ el coordinador la revisa y la convierte en OT"
curl -s -X POST "$API/solicitudes/$SOL_ID/tomar-revision" -H "Authorization: Bearer $T_COO" > /dev/null
ORG=$(curl -s -H "Authorization: Bearer $T_COO" "$API/organizacion/arbol")
SUC=$(echo "$ORG" | jq_ "d['data'][0]['id']")
EMP=$(echo "$ORG" | jq_ "d['data'][0]['empresas'][0]['id']")
TM=$(curl -s -H "Authorization: Bearer $T_COO" "$API/catalogos?tipo=tipo_mantenimiento" | jq_ "d['data']['tipo_mantenimiento'][0]['id']")
COO_ID=$(curl -s -H "Authorization: Bearer $T_COO" "$API/auth/perfil" | jq_ "d['data']['id']")
TEC_ID=$(curl -s -H "Authorization: Bearer $T_TEC" "$API/auth/perfil" | jq_ "d['data']['id']")

OT=$(curl -s -X POST "$API/ot" -H "Authorization: Bearer $T_COO" -H 'Content-Type: application/json' \
  -d "{\"solicitudId\":\"$SOL_ID\",\"sucursalId\":\"$SUC\",\"empresaRucId\":\"$EMP\",\"areaId\":\"$AREA\",
       \"tipoMantenimientoId\":\"$TM\",\"prioridadTecnica\":\"alta\",\"coordinadorId\":\"$COO_ID\"}")
OT_ID=$(echo "$OT" | jq_ "d['data']['id']")
echo "  ✓ $(echo "$OT" | jq_ "d['data']['numero_ot']") creada"

echo "▸ el solicitante NO puede crear OT (Anexo B)"
R=$(curl -s -X POST "$API/ot" -H "Authorization: Bearer $T_SOL" -H 'Content-Type: application/json' -d '{}')
echo "$R" | grep -q '"ok":false' && echo "  ✓ rechazado: $(echo "$R" | jq_ "d['error']['code']")" || { echo "  ✗ FALLO"; exit 1; }

echo "▸ diagnóstico y cotización"
curl -s -X PATCH "$API/ot/$OT_ID/estado" -H "Authorization: Bearer $T_COO" -H 'Content-Type: application/json' \
  -d '{"estado":"en_diagnostico","motivo":"Contexto confirmado"}' > /dev/null
curl -s -X POST "$API/ot/$OT_ID/diagnosticos" -H "Authorization: Bearer $T_TEC" -H 'Content-Type: application/json' \
  -d '{"diagnostico":"Rodamiento de biela con juego axial excesivo.",
       "causaProbable":"Desgaste por horas de servicio sin lubricacion adecuada.",
       "alcance":"Reemplazo de rodamiento y revision del sistema de lubricacion.",
       "trabajoARealizar":"Desmontar cabezal, reemplazar rodamiento, purgar y recargar lubricante."}' > /dev/null
curl -s -X PATCH "$API/ot/$OT_ID/estado" -H "Authorization: Bearer $T_COO" -H 'Content-Type: application/json' \
  -d '{"estado":"en_cotizacion"}' > /dev/null
curl -s -X POST "$API/ot/$OT_ID/cotizaciones" -H "Authorization: Bearer $T_ABA" -H 'Content-Type: application/json' \
  -d '{"proveedorNombre":"Compresores del Sur S.A.C.","numeroCotizacion":"CS-4471","monto":3400,"moneda":"PEN","plazoOfrecidoDias":6}' > /dev/null
echo "  ✓ diagnóstico y cotización registrados"

echo "▸ ejecución y cierre"
curl -s -X POST "$API/ot/$OT_ID/iniciar" -H "Authorization: Bearer $T_COO" -H 'Content-Type: application/json' \
  -d "{\"responsableId\":\"$TEC_ID\"}" > /dev/null
curl -s -X POST "$API/ot/$OT_ID/avances" -H "Authorization: Bearer $T_TEC" -H 'Content-Type: application/json' \
  -d '{"descripcion":"Cabezal desmontado, rodamiento retirado.","porcentaje":50}' > /dev/null
curl -s -X POST "$API/ot/$OT_ID/trabajo-realizado" -H "Authorization: Bearer $T_TEC" -H 'Content-Type: application/json' \
  -d '{"descripcion":"Rodamiento reemplazado, lubricacion purgada y recargada, prueba sin ruido."}' > /dev/null
curl -s -X POST "$API/ot/$OT_ID/revisar" -H "Authorization: Bearer $T_COO" -H 'Content-Type: application/json' \
  -d '{"resultado":"aprobado","observacion":"Conforme."}' > /dev/null

echo "▸ cerrar SIN confirmar el pendiente administrativo debe fallar (QA-19)"
R=$(curl -s -X POST "$API/ot/$OT_ID/cerrar" -H "Authorization: Bearer $T_COO" -H 'Content-Type: application/json' -d '{}')
echo "$R" | grep -q '"requiere_confirmacion": *true' && echo "  ✓ bloqueado y devuelve el estado administrativo" || { echo "  ✗ FALLO: $R"; exit 1; }

R=$(curl -s -X POST "$API/ot/$OT_ID/cerrar" -H "Authorization: Bearer $T_COO" -H 'Content-Type: application/json' \
  -d '{"adminRevisado":true,"observacionPendiente":"Sin SOLPED todavia; Compras la gestiona esta semana."}')
echo "  ✓ cerrada · $(echo "$R" | jq_ "d['data']['indicador']")"

echo "▸ poda por permisos: el solicitante no ve costos ni administrativo (QA-18)"
VISTA_SOL=$(curl -s -H "Authorization: Bearer $T_SOL" "$API/ot/$OT_ID")
python3 - "$VISTA_SOL" <<'PY'
import json, sys
d = json.loads(sys.argv[1])["data"]
prohibidas = [k for k in ("costos", "cotizaciones", "administrativo") if k in d]
if prohibidas:
    sys.exit(f"  ✗ FALLO: el solicitante ve {prohibidas}")
if (d.get("organizacion") or {}).get("empresa_ruc") is not None:
    sys.exit("  ✗ FALLO: el solicitante ve el RUC")
print("  ✓ sin costos, sin cotizaciones, sin administrativo, sin RUC")
PY

VISTA_COO=$(curl -s -H "Authorization: Bearer $T_COO" "$API/ot/$OT_ID")
python3 - "$VISTA_COO" <<'PY'
import json, sys
d = json.loads(sys.argv[1])["data"]
faltan = [k for k in ("costos", "cotizaciones", "administrativo") if k not in d]
if faltan:
    sys.exit(f"  ✗ FALLO: al coordinador le faltan {faltan}")
print("  ✓ el coordinador sí ve costos, cotizaciones y administrativo")
PY

echo "▸ integridad del motor de trazabilidad"
# Con el administrador: verificar-trazabilidad exige `auditoria:ver`, que el
# Anexo B reserva al rol administrador. Que el coordinador NO pueda es correcto.
T_ADM=$(token "${ADMIN_EMAIL:-admin@mip.local}" "${ADMIN_PASS:-CambiarEnDeploy2026}")
curl -s -H "Authorization: Bearer $T_ADM" "$API/ot/verificar-trazabilidad" | python3 -c "
import json,sys; d=json.load(sys.stdin)['data']
print(f\"  {'✓' if d['integridad_ok'] else '✗'} revisadas {d['revisadas']} · desviadas {len(d['desviadas'])} · sucias {d['sucias_pendientes']}\")
sys.exit(0 if d['integridad_ok'] else 1)"

echo ""
echo "══ ciclo HTTP completo sin errores ══"
