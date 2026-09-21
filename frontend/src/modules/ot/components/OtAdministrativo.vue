<template>
  <div class="pila">
    <!--
      Aviso permanente y deliberado: no hay conector SAP. El cap. 22.4 deja
      pendientes los campos de SOLPED y el mecanismo de integración, y el cap. 38
      prohíbe resolver un pendiente con un supuesto de desarrollador. Decirlo es
      más honesto que una interfaz que aparente enviar algo.
    -->
    <div class="aviso info">
      <Info :size="15" />
      <div>
        <b>El envío a SAP todavía no está integrado.</b>
        El flujo funciona en modo manual: se prepara la SOLPED, se marca lista y se registra el número que devuelva
        Compras. MIP nunca modifica un documento SAP ya creado.
      </div>
    </div>

    <!-- Resumen: dónde está el seguimiento y cuánto se ha liberado. -->
    <div class="stat-row tres">
      <Stat
        label="Estado administrativo"
        :valor="etiqueta(a?.estado_consolidado)"
        pequeno
        :tono="tonoAdmin(a?.estado_consolidado) === 'ok' ? '' : 'espera'"
        :icono="Truck"
        :color="tonoAdmin(a?.estado_consolidado) === 'ok' ? '' : 'amber'"
        :meta="a?.revisado_por ? `Revisado por ${a.revisado_por}` : 'Corre en paralelo al estado técnico'"
      />
      <Stat
        label="Monto liberado"
        :valor="monto(a?.monto_liberado_total, a?.moneda)"
        pequeno
        :icono="Coins"
        meta="No equivale al costo final de la OT"
      />
      <Stat
        label="Documentos"
        :valor="`${(a?.solped ?? []).length} · ${(a?.oc ?? []).length}`"
        pequeno
        :icono="FileStack"
        meta="SOLPED · órdenes de compra"
      />
    </div>

    <div v-if="a?.observacion" class="card">
      <div class="card-cuerpo">
        <div class="sello-motivo" style="margin: 0"><b>Observación del cierre</b>{{ a.observacion }}</div>
      </div>
    </div>

    <!-- ── SOLPED ───────────────────────────────────────────────────── -->
    <section class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile blue"><FileText :size="14" /></span>
          SOLPED
          <span class="head-meta">{{ (a?.solped ?? []).length }}</span>
        </span>
        <button v-if="puede('administrativo:solped')" class="btn sm" @click="prepararSolped">
          <Plus :size="13" /> Preparar SOLPED
        </button>
      </div>

      <div class="card-cuerpo">
        <p v-if="!(a?.solped ?? []).length" class="muted" style="margin: 0; font-size: 12.5px">
          Sin SOLPED. La OT puede cerrarse igualmente dejando constancia del pendiente.
        </p>

        <article
          v-for="s in a?.solped ?? []"
          :key="s.id"
          class="version"
          :class="s.vigente && !s.anulada ? 'vigente' : 'reemplazada'"
        >
          <div class="version-cab">
            <span class="version-n">v{{ s.version }}</span>
            <span class="tag" :class="s.estado_integracion === 'creada_en_sap' ? 'ok' : 'espera'">
              {{ etiqueta(s.estado_integracion) }}
            </span>
            <span v-if="s.anulada" class="tag emergencia">Anulada</span>
            <span class="crecer" />
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
              <div class="def-v mono" :style="s.numero_sap ? 'font-weight:700' : 'color:var(--amber-ink)'">
                {{ s.numero_sap ?? "pendiente" }}
              </div>
            </div>
            <div><div class="def-k">Monto</div><div class="def-v mono">{{ monto(s.monto, s.moneda) }}</div></div>
            <div v-if="s.referencia_externa">
              <div class="def-k">Referencia externa</div>
              <div class="def-v mono" style="font-size: 11.5px">{{ s.referencia_externa }}</div>
            </div>
          </div>

          <div v-if="s.motivo_anulacion" class="sello-motivo peligro">
            <b>Motivo de la anulación</b>{{ s.motivo_anulacion }}
          </div>
        </article>
      </div>
    </section>

    <!-- ── órdenes de compra ────────────────────────────────────────── -->
    <section class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile violet"><ShoppingCart :size="14" /></span>
          Órdenes de compra
          <span class="head-meta">{{ (a?.oc ?? []).length }}</span>
        </span>
        <button v-if="puede('administrativo:oc')" class="btn sm" @click="abrirModal('oc')">
          <Plus :size="13" /> Registrar OC
        </button>
      </div>

      <div v-if="!(a?.oc ?? []).length" class="card-cuerpo">
        <p class="muted" style="margin: 0; font-size: 12.5px">
          Sin OC registrada. Registrarla después del cierre no reabre la OT.
        </p>
      </div>
      <div v-else class="tabla-wrap">
        <table>
          <thead>
            <tr><th>N.º OC</th><th>Fecha</th><th class="num">Monto</th><th>Registrada por</th></tr>
          </thead>
          <tbody>
            <tr v-for="o in a.oc" :key="o.id">
              <td class="mono" style="font-weight: 600; color: var(--ink)">{{ o.numero }}</td>
              <td class="mono muted">{{ fecha(o.fecha) }}</td>
              <td class="num mono">{{ monto(o.monto, o.moneda) }}</td>
              <td class="muted">{{ o.registrada_por }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ── liberación ───────────────────────────────────────────────── -->
    <section class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile"><PackageCheck :size="14" /></span>
          Liberación
          <span class="head-meta">{{ (a?.liberaciones ?? []).length }}</span>
        </span>
        <button v-if="puede('administrativo:liberacion')" class="btn sm" @click="abrirModal('liberacion')">
          <Plus :size="13" /> Registrar liberación
        </button>
      </div>

      <div v-if="!(a?.liberaciones ?? []).length" class="card-cuerpo">
        <p class="muted" style="margin: 0; font-size: 12.5px">
          Sin liberaciones. El monto liberado no equivale al costo final de la OT.
        </p>
      </div>
      <div v-else class="tabla-wrap">
        <table>
          <thead>
            <tr><th>Estado</th><th class="num">Anterior</th><th class="num">Nuevo</th><th>Actor</th><th>Fecha</th></tr>
          </thead>
          <tbody>
            <tr v-for="l in a.liberaciones" :key="l.id">
              <td>
                <span v-if="l.estado_anterior" class="mas-muted">{{ etiqueta(l.estado_anterior) }} → </span>
                <b style="color: var(--ink)">{{ etiqueta(l.estado_nuevo) }}</b>
              </td>
              <td class="num mono mas-muted">{{ l.monto_anterior !== null ? monto(l.monto_anterior, l.moneda) : "—" }}</td>
              <td class="num mono">{{ monto(l.monto_nuevo, l.moneda) }}</td>
              <td class="muted">{{ l.actor }}</td>
              <td class="mono muted nowrap">{{ fechaHora(l.fecha) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <AdminRegistroModal
      :abierto="!!modal"
      :ot-id="otId"
      :tipo="modal || 'oc'"
      :moneda="a?.moneda ?? 'PEN'"
      @cerrar="modal = null"
      @guardado="alGuardar"
    />
  </div>
</template>

<script setup>
import { computed, ref } from "vue";
import { Coins, FileStack, FileText, Info, PackageCheck, Plus, ShoppingCart, Truck } from "lucide-vue-next";
import Stat from "../../../shared/components/ui/Stat.vue";
import AdminRegistroModal from "./AdminRegistroModal.vue";
import { otApi } from "../api/ot.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";
import { etiqueta, fecha, fechaHora, monto, tonoAdmin } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true }, otId: { type: String, required: true } });
const emit = defineEmits(["cambio"]);
const { puede } = useAuth();

const a = computed(() => props.t.administrativo);
const modal = ref(null);

function abrirModal(tipo) {
  modal.value = tipo;
}
function alGuardar() {
  modal.value = null;
  emit("cambio");
}

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
    placeholder: "0010045678",
    confirmar: "Registrar",
    area: false,
    minimo: 3,
  });
  if (n) await hacer(() => otApi.solpedNumeroSap(s.id, { numeroSap: n }), "Número SAP registrado");
}

async function anular(s) {
  const m = await notify.pedirTexto("Anular la SOLPED", {
    texto: "Es una anulación lógica: el registro se conserva con su motivo y permite crear una SOLPED nueva.",
    confirmar: "Anular",
    minimo: 10,
  });
  if (m) await hacer(() => otApi.solpedAnular(s.id, m), "SOLPED anulada");
}
</script>
