<template>
  <!--
    Registrar una OC o una liberación pide dos o tres datos relacionados entre
    sí (número + fecha + importe, o estado + importe). Pedirlos en diálogos
    encadenados obligaba a validar el importe DESPUÉS de haber elegido el
    estado, y un número mal escrito costaba repetir todo el flujo.
  -->
  <Modal
    :abierto="abierto"
    persistente
    :titulo="esOc ? 'Registrar la orden de compra' : 'Registrar la liberación'"
    :subtitulo="
      esOc
        ? 'Tal como la emitió Compras. Registrarla después del cierre no reabre la OT.'
        : 'El monto liberado es el acumulado hasta ahora, y no equivale al costo final de la OT.'
    "
    @cerrar="$emit('cerrar')"
  >
    <form id="form-admin" class="col" style="gap: 16px" @submit.prevent="guardar">
      <template v-if="esOc">
        <Campo label="Número de OC" requerido :error="tocado && d.numeroOc.length < 3 ? 'Escriba el número completo.' : ''">
          <input
            v-model.trim="d.numeroOc" class="input mono"
            :class="{ error: tocado && d.numeroOc.length < 3 }" placeholder="4500123456"
          />
        </Campo>

        <div class="form-grid">
          <Campo label="Fecha de emisión">
            <input v-model="d.fecha" type="date" class="input" />
          </Campo>
          <Campo label="Monto" ayuda="Opcional si aún no está cerrado.">
            <input v-model="d.monto" type="number" step="0.01" min="0" class="input mono" placeholder="0.00" />
          </Campo>
        </div>

        <Campo label="Moneda">
          <SelectMenu v-model="d.moneda" :opciones="OPC_MONEDA" />
        </Campo>
      </template>

      <template v-else>
        <Campo label="Estado de la liberación" requerido>
          <SelectMenu v-model="d.estado" :opciones="OPC_LIBERACION" />
        </Campo>

        <div class="form-grid">
          <Campo
            label="Monto liberado acumulado"
            requerido
            :error="tocado && !montoValido ? 'Escriba un número igual o mayor que cero.' : ''"
          >
            <input
              v-model="d.monto" type="number" step="0.01" min="0" class="input mono"
              :class="{ error: tocado && !montoValido }" placeholder="0.00"
            />
          </Campo>
          <Campo label="Moneda">
            <SelectMenu v-model="d.moneda" :opciones="OPC_MONEDA" />
          </Campo>
        </div>

        <div v-if="d.estado === 'total'" class="aviso ok">
          <Check :size="15" />
          <div>Marcar la liberación como total cierra el seguimiento administrativo de esta OT.</div>
        </div>
      </template>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button class="btn primary" form="form-admin" type="submit" :disabled="enviando || !valido">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Registrando…" : "Registrar" }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { Check, TriangleAlert } from "lucide-vue-next";
import Modal from "../../../shared/components/ui/Modal.vue";
import Campo from "../../../shared/components/ui/Campo.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import { otApi } from "../api/ot.api.js";
import { notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  otId: { type: String, required: true },
  /** "oc" | "liberacion" */
  tipo: { type: String, default: "oc" },
  moneda: { type: String, default: "PEN" },
});
const emit = defineEmits(["cerrar", "guardado"]);

const OPC_MONEDA = [
  { value: "PEN", label: "Soles", hint: "PEN" },
  { value: "USD", label: "Dólares", hint: "USD" },
  { value: "EUR", label: "Euros", hint: "EUR" },
];
const OPC_LIBERACION = [
  { value: "pendiente", label: "Pendiente", dot: "var(--amber)" },
  { value: "parcial", label: "Parcial", dot: "var(--blue)" },
  { value: "total", label: "Total", dot: "var(--emerald)" },
];

const esOc = computed(() => props.tipo === "oc");

const vacio = () => ({
  numeroOc: "",
  fecha: new Date().toISOString().slice(0, 10),
  monto: "",
  moneda: props.moneda || "PEN",
  estado: "parcial",
});

const d = reactive(vacio());
const enviando = ref(false);
const tocado = ref(false);
const errorGeneral = ref("");

const montoValido = computed(() => d.monto !== "" && Number(d.monto) >= 0 && !Number.isNaN(Number(d.monto)));
const valido = computed(() => (esOc.value ? d.numeroOc.length >= 3 : !!d.estado && montoValido.value));

watch(
  () => props.abierto,
  (v) => {
    if (!v) return;
    Object.assign(d, vacio());
    tocado.value = false;
    errorGeneral.value = "";
  },
);

async function guardar() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    if (esOc.value) {
      await otApi.registrarOc(props.otId, {
        numeroOc: d.numeroOc,
        fecha: d.fecha || undefined,
        monto: d.monto !== "" ? Number(d.monto) : undefined,
        moneda: d.moneda,
      });
      await notify.exito("Orden de compra registrada");
    } else {
      await otApi.registrarLiberacion(props.otId, {
        estado: d.estado,
        monto: Number(d.monto),
        moneda: d.moneda,
      });
      await notify.exito("Liberación registrada");
    }
    emit("guardado");
  } catch (e) {
    errorGeneral.value = e.message ?? "No se pudo registrar.";
  } finally {
    enviando.value = false;
  }
}
</script>
