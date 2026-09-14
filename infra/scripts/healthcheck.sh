#!/usr/bin/env bash
# Comprueba la API y avisa de las señales de dominio que conviene vigilar.
set -euo pipefail
API="${API:-http://localhost:3200/api}"

RES=$(curl -fsS -m 5 "$API/health") || { echo "✗ La API no responde"; exit 1; }
echo "$RES" | python3 -c "
import json,sys
d=json.load(sys.stdin)['data']
s=d['servicios']
print(f\"  estado: {d['estado']}\")
for k,v in s.items(): print(f\"  {'✓' if v else '✗'} {k}\")
# Sólo la base es crítica: el resto degrada funcionalidad concreta.
sys.exit(0 if s['base_datos'] else 1)
"
