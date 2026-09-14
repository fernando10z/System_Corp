<template>
  <div class="pila">
    <!--
      Aviso permanente y deliberado: no hay conector SAP. El cap. 22.4 deja
      pendientes los campos de SOLPED y el mecanismo de integración, y el cap. 38
      prohíbe resolver un pendiente con un supuesto de desarrollador. Decirlo es
      más honesto que una interfaz que aparente enviar algo.
    -->
    <div class="aviso-sap">
      <Info :size="15" />
      <div>
        <b>El envío a SAP todavía no está integrado.</b>
        El flujo funciona en modo manual: se prepara la SOLPED, se marca lista y se registra el número que devuelva
        Compras. MIP nunca modifica un documento SAP ya creado.
      </div>
    </div>

    <section class="card">
      <div class="card-head">
        <span class="card-titulo">Estado administrativo</span>
        <span class="tag" :class="a?.estado_consolidado === 'administracion_completa' ? 'ok' : 'espera'">
          {{ etiqueta(a?.estado_consolidado) }}
        </span>
      </div>
      <div class="card-cuerpo defs">
        <div>
          <div class="def-k">Monto liberado</div>
          <div class="def-v mono">{{ monto(a?.monto_liberado_total, a?.moneda) }}</div>
        </div>
        <div v-if="a?.revisado_por">
          <div class="def-k">Revisado por</div>
          <div class="def-v">{{ a.revisado_por }} · {{ fechaHora(a.revisado_at) }}</div>
        </div>
      </div>
      <div v-if="a?.observacion" class="card-cuerpo" style="border-top: 1px solid var(--line-soft)">
        <div class="sello-motivo"><b>Observación</b>{{ a.observacion }}</div>
      </div>
    </section>

    <section class="card">
      <div class="card-head">
        <span class="card-titulo">SOLPED</span>
        <button v-if="puede('administrativo:solped')" class="btn sm" @click="prepararSolped">
          <Plus :size="13" /> Preparar SOLPED
        </button>
      </div>
      <div class="card-cuerpo">
        <div v-if="!(a?.solped ?? []).length" class="muted" style="font-size: 12.5px">
          Sin SOLPED. La OT puede cerrarse igualmente dejando constancia del pendiente.
        </div>
        <div v-for="s in a?.solped ?? []" :key="s.id" class="version" :class="s.vigente ? 'vigente' : 'reemplazada'">
          <div class="version-cab">
            <span class="version-n">v{{ s.version }}</span>
            <span class="tag" :class="s.estado_integracion === 'creada_en_sap' ? 'ok' : 'espera'">
              {{ etiqueta(s.estado_integracion) }}
            </span>
            <span v-if="s.anulada" class="tag">Anulada</span>
            <span class="crecer"></span>
            <template v-if="s.vigente && !s.anulada && puede('administrativo:solped')">
              <button v-if="s.estado_integracion === 'borrador'" class="btn sm" @click="marcarLista(s)">
                Marcar lista
              </button>
              <button v-if="!s.numero_sap" class="btn sm primary" @click="registrarSap(s)">Registrar N.º SAP</button>
              <button class="btn sm peligro" @click="anular(s)">Anular</button>
            </template>
          </div>
          <div class="defs">
            <div><div class="def-k">N.º interno</div><div class="def-v mono">{{ s.numero_interno ?? "—" }}</div></div>
            <div>
              <div class="def-k">N.º SAP</div>
              <div class="def-v mono" style="font-weight: 600">{{ s.numero_sap ?? "pendiente" }}</div>
            </div>
            <div><div class="def-k">Monto</div><div class="def-v mono">{{ monto(s.monto, s.moneda) }}</div></div>
            <div><div class="def-k">Referencia externa</div><div class="def-v mono" style="font-size:11px">{{ s.referencia_externa }}</div></div>
          </div>
          <div v-if="s.motivo_anulacion" class="sello-motivo" style="margin-top: 9px">
            <b>Motivo de la anulación</b>{{ s.motivo_anulacion }}
          </div>
        </div>
      </div>
    </section>

    <section class="card">
      <div class="card-head">
        <span class="card-titulo">Órdenes de compra</span>
        <button v-if="puede('administrativo:oc')" class="btn sm" @click="registrarOc">
          <Plus :size="13" /> Registrar OC
        </button>
      </div>
      <div class="card-cuerpo">
        <p class="muted" style="margin: 0 0 9px; font-size: 12px">
          Registrar la OC después del cierre no reabre la OT.
        </p>
        <div v-if="!(a?.oc ?? []).length" class="muted" style="font-size: 12.5px">Sin OC registrada.</div>
        <table v-else class="stbl">
          <thead><tr><th>N.º OC</th><th>Fecha</th><th class="der">Monto</th><th>Registrada por</th></tr></thead>
          <tbody>
            <tr v-for="o in a.oc" :key="o.id">
              <td class="mono" style="font-weight: 600">{{ o.numero }}</td>
              <td class="mono muted">{{ fecha(o.fecha) }}</td>
              <td class="der mono">{{ monto(o.monto, o.moneda) }}</td>
              <td class="muted">{{ o.registrada_por }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section class="card">
      <div class="card-head">
        <span class="card-titulo">Liberación</span>
        <button v-if="puede('administrativo:liberacion')" class="btn sm" @click="registrarLiberacion">
          <Plus :size="13" /> Registrar liberación
        </button>
      </div>
      <div class="card-cuerpo">
        <p class="muted" style="margin: 0 0 9px; font-size: 12px">
          El monto liberado no equivale al costo final de la OT.
        </p>
        <div v-if="!(a?.liberaciones ?? []).length" class="muted" style="font-size: 12.5px">Sin liberaciones.</div>
        <table v-else class="stbl">
          <thead><tr><th>Estado</th><th class="der">Anterior</th><th class="der">Nuevo</th><th>Actor</th><th>Fecha</th></tr></thead>
          <tbody>
            <tr v-for="l in a.liberaciones" :key="l.id">
              <td>
                <span class="muted">{{ l.estado_anterior ? etiqueta(l.estado_anterior) + " → " : "" }}</span>
                <b>{{ etiqueta(l.estado_nuevo) }}</b>
              </td>
              <td class="der mono muted">{{ l.monto_anterior !== null ? monto(l.monto_anterior, l.moneda) : "—" }}</td>
              <td class="der mono">{{ monto(l.monto_nuevo, l.moneda) }}</td>
              <td class="muted">{{ l.actor }}</td>
              <td class="mono muted">{{ fechaHora(l.fecha) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { Info, Plus } from "lucide-vue-next";
import { otApi } from "../api/ot.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";
import { etiqueta, fecha, fechaHora, monto } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true }, otId: { type: String, required: true } });
const emit = defineEmits(["cambio"]);
const { puede } = useAuth();

const a = computed(() => props.t.administrativo);

async function hacer(fn, exito) {
  try {
    const r = await fn();
    await notify.exito(exito, r?.data?.nota ?? "");
    emit("cambio");
  } catch (e) {
    await mostrarError(e);
  }
}

async function prepararSolped() {
  const ok = await notify.confirmar(
    "Preparar la SOLPED",
    "Se crea el registro interno con los datos de la cotización vigente. No se envía nada a SAP.",
    { confirmar: "Preparar" },
  );
  if (ok) await hacer(() => otApi.prepararSolped(props.otId, {}), "SOLPED preparada");
}

async function marcarLista(s) {
  await hacer(() => otApi.solpedLista(s.id), "SOLPED marcada como lista");
}

async function registrarSap(s) {
  const n = await notify.pedirTexto("Número SAP de la SOLPED", {
    texto: "Escríbalo tal como lo informó Compras. Cualquier corrección posterior queda auditada.",
    placeholder: "0010045678", confirmar: "Registrar", area: false, minimo: 3,
  });
  if (n) await hacer(() => otApi.solpedNumeroSap(s.id, { numeroSap: n }), "Número SAP registrado");
}

async function anular(s) {
  const m = await notify.pedirTexto("Anular la SOLPED", {
    texto: "Es una anulación lógica: el registro se conserva con su motivo y permite crear una SOLPED nueva.",
    confirmar: "Anular", minimo: 10,
  });
  if (m) await hacer(() => otApi.solpedAnular(s.id, m), "SOLPED anulada");
}

async function registrarOc() {
  const n = await notify.pedirTexto("Número de la orden de compra", {
    texto: "Tal como lo emitió Compras.", placeholder: "4500123456",
    confirmar: "Registrar", area: false, minimo: 3,
  });
  if (n) await hacer(() => otApi.registrarOc(props.otId, { numeroOc: n }), "Orden de compra registrada");
}

async function registrarLiberacion() {
  const estado = await notify.elegir(
    "Estado de la liberación",
    { pendiente: "Pendiente", parcial: "Parcial", total: "Total" },
    { confirmar: "Siguiente" },
  );
  if (!estado) return;

  const m = await notify.pedirTexto("Monto liberado", {
    texto: "El monto acumulado liberado hasta ahora.", placeholder: "1500.00",
    confirmar: "Registrar", area: false,
  });
  if (m === null) return;

  const valor = Number(String(m).replace(",", "."));
  if (Number.isNaN(valor) || valor < 0) {
    return notify.error("El monto no es válido", "Escriba un número igual o mayor que cero.");
  }
  await hacer(
    () => otApi.registrarLiberacion(props.otId, { estado, monto: valor }),
    "Liberación registrada",
  );
}
</script>

<style scoped>
.aviso-sap {
  display: flex; gap: 10px; align-items: flex-start;
  padding: 11px 13px;
  border: 1px dashed var(--primary-line);
  background: var(--primary-soft);
  border-radius: var(--radio);
  font-size: 12.5px;
  color: var(--ink-2);
}
.aviso-sap svg { flex: none; margin-top: 1px; color: var(--primary); }
.aviso-sap b { display: block; color: var(--ink); }
</style>
