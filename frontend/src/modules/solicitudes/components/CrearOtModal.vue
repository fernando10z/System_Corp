<template>
  <!--
    Aceptar una solicitud es lo ÚNICO que crea una OT, y para crearla hacen
    falta los datos técnicos mínimos que el solicitante no tenía por qué conocer
    (cap. 24.4). Antes esto era un formulario incrustado como HTML dentro de un
    diálogo: no validaba bien, no recordaba lo escrito y la empresa no se
    filtraba por sucursal. Ahora es un formulario de verdad.
  -->
  <Modal
    :abierto="abierto"
    ancho="ancho"
    persistente
    titulo="Aceptar y crear la orden de trabajo"
    :subtitulo="`A partir de ${solicitud?.numero ?? 'la solicitud'} · ${solicitud?.titulo ?? ''}`"
    @cerrar="$emit('cerrar')"
  >
    <Cargando v-if="cargando" texto="Cargando la organización…" />

    <form v-else id="form-crear-ot" class="col" style="gap: 16px" @submit.prevent="crear">
      <div class="form-grid">
        <Campo label="Sucursal" requerido>
          <SelectMenu v-model="d.sucursalId" :opciones="opcSucursales" placeholder="Elija la sucursal" />
        </Campo>

        <Campo
          label="Empresa / RUC"
          requerido
          :ayuda="d.sucursalId ? '' : 'Elija primero la sucursal.'"
        >
          <!-- Las empresas se acotan a la sucursal elegida: ofrecer todas
               invita a cruzar razones sociales que no se tocan entre sí. -->
          <SelectMenu
            v-model="d.empresaRucId"
            :opciones="opcEmpresas"
            :deshabilitado="!d.sucursalId"
            placeholder="Elija la empresa"
          />
        </Campo>

        <Campo label="Tipo de mantenimiento" requerido>
          <SelectMenu v-model="d.tipoMantenimientoId" :opciones="opcTipos" placeholder="Elija el tipo" />
        </Campo>

        <Campo
          label="Prioridad técnica"
          requerido
          ayuda="La percepción del solicitante no cambia: son dos cosas distintas."
        >
          <SelectMenu v-model="d.prioridadTecnica" :opciones="OPC_PRIORIDAD" />
        </Campo>
      </div>

      <Campo label="Coordinador responsable" requerido>
        <SelectMenu v-model="d.coordinadorId" :opciones="opcCoordinadores" placeholder="Elija el responsable" />
      </Campo>

      <div class="separador" />

      <label class="check-linea">
        <input type="checkbox" v-model="d.esEmergencia" />
        <span>
          <b style="color: var(--ink)">Clasificar como emergencia</b>
          <span style="display: block; color: var(--ink-3); margin-top: 2px">
            Podrá iniciarse sin cotización, pero la regularización quedará pendiente hasta que se resuelva.
          </span>
        </span>
      </label>

      <!-- La emergencia es una excepción y toda excepción se justifica. -->
      <Campo
        v-if="d.esEmergencia"
        label="Justificación de la emergencia"
        requerido
        :error="errorJustificacion"
        ayuda="Quedará visible en la ficha de la OT y en el histórico de costos."
      >
        <textarea
          v-model.trim="d.emergenciaJustificacion"
          class="textarea"
          :class="{ error: !!errorJustificacion }"
          placeholder="Ej. la línea 2 está parada y no hay equipo de respaldo"
        />
      </Campo>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <span class="izq muted" style="font-size: 12px">La solicitud original se conserva intacta.</span>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button class="btn primary" form="form-crear-ot" type="submit" :disabled="enviando || !valido">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Creando…" : "Crear la OT" }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { TriangleAlert } from "lucide-vue-next";
import Modal from "../../../shared/components/ui/Modal.vue";
import Campo from "../../../shared/components/ui/Campo.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import { catalogosApi, organizacionApi, usuariosApi } from "../../shared/catalogos.api.js";
import { otApi } from "../../ot/api/ot.api.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  solicitud: { type: Object, default: null },
});
const emit = defineEmits(["cerrar", "creada"]);

const OPC_PRIORIDAD = [
  { value: "critica", label: "Crítica", dot: "var(--red)" },
  { value: "alta", label: "Alta", dot: "var(--amber)" },
  { value: "media", label: "Media", dot: "var(--blue)" },
  { value: "baja", label: "Baja", dot: "var(--ink-4)" },
];

const d = reactive({
  sucursalId: "",
  empresaRucId: "",
  tipoMantenimientoId: "",
  prioridadTecnica: "media",
  coordinadorId: "",
  esEmergencia: false,
  emergenciaJustificacion: "",
});

const arbol = ref([]);
const tipos = ref([]);
const coordinadores = ref([]);
const cargando = ref(false);
const enviando = ref(false);
const errorGeneral = ref("");
const tocado = ref(false);

const opcSucursales = computed(() => arbol.value.map((s) => ({ value: s.id, label: s.nombre, hint: s.codigo })));

const opcEmpresas = computed(() => {
  const suc = arbol.value.find((s) => s.id === d.sucursalId);
  return (suc?.empresas ?? []).map((e) => ({ value: e.id, label: e.razon_social, hint: e.ruc }));
});

const opcTipos = computed(() => tipos.value.map((t) => ({ value: t.id, label: t.nombre })));
const opcCoordinadores = computed(() =>
  coordinadores.value.map((u) => ({ value: u.id, label: u.nombre, hint: u.cargo ?? "" })),
);

const errorJustificacion = computed(() => {
  if (!tocado.value || !d.esEmergencia) return "";
  return d.emergenciaJustificacion.length < 10 ? "La emergencia exige al menos 10 caracteres." : "";
});

const valido = computed(
  () =>
    !!d.sucursalId &&
    !!d.empresaRucId &&
    !!d.tipoMantenimientoId &&
    !!d.coordinadorId &&
    (!d.esEmergencia || d.emergenciaJustificacion.length >= 10),
);

// Cambiar de sucursal invalida la empresa elegida: si no se limpiara, se
// enviaría una empresa que no pertenece a esa sucursal.
watch(() => d.sucursalId, () => { d.empresaRucId = ""; });

watch(
  () => props.abierto,
  async (v) => {
    if (!v) return;
    errorGeneral.value = "";
    tocado.value = false;
    cargando.value = true;
    try {
      // `asignables` en lugar del listado de usuarios: el coordinador —que es
      // quien más usa esta pantalla— no tiene `usuarios:listar`, y pedirlo
      // hacía fallar "Aceptar y crear OT" con un permiso denegado.
      const [o, c, u] = await Promise.all([
        organizacionApi.arbol(),
        catalogosApi.todos("tipo_mantenimiento"),
        usuariosApi.asignables(),
      ]);
      arbol.value = o.data ?? [];
      tipos.value = c.data?.tipo_mantenimiento ?? [];
      coordinadores.value = u.data ?? [];

      // Con una sola opción no se hace elegir: se preselecciona.
      if (arbol.value.length === 1) d.sucursalId = arbol.value[0].id;
      if (tipos.value.length === 1) d.tipoMantenimientoId = tipos.value[0].id;
    } catch (e) {
      await mostrarError(e, "No se pudieron cargar los datos para crear la OT");
      emit("cerrar");
    } finally {
      cargando.value = false;
    }
  },
);

async function crear() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    const r = await otApi.crear({
      solicitudId: props.solicitud.id,
      areaId: props.solicitud.area?.id,
      sucursalId: d.sucursalId,
      empresaRucId: d.empresaRucId,
      tipoMantenimientoId: d.tipoMantenimientoId,
      prioridadTecnica: d.prioridadTecnica,
      coordinadorId: d.coordinadorId,
      esEmergencia: d.esEmergencia,
      emergenciaJustificacion: d.esEmergencia ? d.emergenciaJustificacion : undefined,
    });
    await notify.exito("Orden de trabajo creada", r.data.numero_ot);
    emit("creada", r.data);
  } catch (e) {
    // El error se muestra DENTRO del modal: cerrarlo perdería lo ya elegido.
    errorGeneral.value = e.message ?? "No se pudo crear la OT.";
  } finally {
    enviando.value = false;
  }
}
</script>

<style scoped>
.separador { height: 1px; background: var(--line-soft); }
</style>
