<template>
  <!--
    Sucursal, empresa y área comparten forma (código + nombre), pero el área
    además pertenece SIEMPRE a una empresa/RUC. Antes eso se pedía en dos
    diálogos encadenados; aquí se ve la dependencia completa de una vez.
  -->
  <Modal :abierto="abierto" persistente :titulo="titulo" :subtitulo="subtitulo" @cerrar="$emit('cerrar')">
    <form id="form-org" class="col" style="gap: 16px" @submit.prevent="guardar">
      <Campo
        v-if="tipo === 'area'"
        label="Empresa / RUC a la que pertenece"
        requerido
        ayuda="Un área pertenece a una sola razón social: el mismo nombre bajo otra RUC es otra área."
      >
        <SelectMenu v-model="d.empresaRucId" :opciones="opcEmpresas" placeholder="Elija la empresa" />
      </Campo>

      <div v-if="tipo === 'empresa'" class="form-grid">
        <Campo label="RUC" requerido :error="errorRuc">
          <input
            v-model.trim="d.ruc" class="input mono" maxlength="11" inputmode="numeric"
            :class="{ error: tocado && !rucValido }" placeholder="20100000001"
          />
        </Campo>
        <Campo label="Razón social" requerido :error="tocado && !d.nombre ? 'Obligatorio.' : ''">
          <input v-model.trim="d.nombre" class="input" :class="{ error: tocado && !d.nombre }" placeholder="EMPRESA S.A.C." />
        </Campo>
      </div>

      <div v-else class="form-grid">
        <Campo label="Código" requerido :error="tocado && !d.codigo ? 'Obligatorio.' : ''" ayuda="Corto y estable.">
          <input
            v-model.trim="d.codigo" class="input mono"
            :class="{ error: tocado && !d.codigo }"
            :placeholder="tipo === 'sucursal' ? 'PLANTA-02' : 'MANTTO'"
          />
        </Campo>
        <Campo label="Nombre" requerido :error="tocado && !d.nombre ? 'Obligatorio.' : ''">
          <input
            v-model.trim="d.nombre" class="input"
            :class="{ error: tocado && !d.nombre }"
            :placeholder="tipo === 'sucursal' ? 'Planta norte' : 'Mantenimiento'"
          />
        </Campo>
      </div>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button class="btn primary" form="form-org" type="submit" :disabled="enviando || !valido">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Creando…" : "Crear" }}
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
import { organizacionApi } from "../../shared/catalogos.api.js";
import { notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  /** "sucursal" | "empresa" | "area" */
  tipo: { type: String, default: "sucursal" },
  /** El árbol ya cargado por la página: no hace falta volver a pedirlo. */
  arbol: { type: Array, default: () => [] },
});
const emit = defineEmits(["cerrar", "guardado"]);

const TITULOS = {
  sucursal: ["Nueva sucursal", "El primer nivel de la organización: una planta, un local, una sede."],
  empresa: ["Nueva empresa", "La razón social con la que se factura. Asóciela luego a una sucursal para poder usarla."],
  area: ["Nueva área", "El tercer nivel, donde nacen las solicitudes."],
};

const titulo = computed(() => TITULOS[props.tipo]?.[0] ?? "Nuevo registro");
const subtitulo = computed(() => TITULOS[props.tipo]?.[1] ?? "");

const vacio = () => ({ codigo: "", nombre: "", ruc: "", empresaRucId: "" });
const d = reactive(vacio());
const enviando = ref(false);
const tocado = ref(false);
const errorGeneral = ref("");

const opcEmpresas = computed(() =>
  props.arbol.flatMap((s) =>
    (s.empresas ?? []).map((e) => ({ value: e.id, label: e.razon_social, hint: `${e.ruc} · ${s.nombre}` })),
  ),
);

/**
 * RUC peruano: 11 dígitos con dígito verificador de módulo 11. Se valida aquí
 * con la MISMA regla que internal.validar_ruc en la base — no para sustituirla,
 * sino para que un dígito mal tecleado se vea al momento y no tras un viaje al
 * servidor. Quien manda sigue siendo la base.
 */
function rucBienFormado(ruc) {
  if (!/^\d{11}$/.test(ruc)) return false;
  if (!["10", "15", "16", "17", "20"].includes(ruc.slice(0, 2))) return false;
  const pesos = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2];
  const suma = pesos.reduce((a, p, i) => a + Number(ruc[i]) * p, 0);
  let dv = 11 - (suma % 11);
  if (dv === 10) dv = 0;
  else if (dv === 11) dv = 1;
  return dv === Number(ruc[10]);
}

const rucValido = computed(() => rucBienFormado(d.ruc));

const errorRuc = computed(() => {
  if (!tocado.value || props.tipo !== "empresa") return "";
  if (!/^\d{11}$/.test(d.ruc)) return "Son 11 dígitos, sin guiones ni espacios.";
  if (!rucValido.value) return "El dígito verificador no cuadra: revise el número.";
  return "";
});

const valido = computed(() => {
  if (props.tipo === "empresa") return rucValido.value && !!d.nombre;
  if (props.tipo === "area") return !!d.empresaRucId && !!d.codigo && !!d.nombre;
  return !!d.codigo && !!d.nombre;
});

watch(
  () => props.abierto,
  (v) => {
    if (!v) return;
    Object.assign(d, vacio());
    tocado.value = false;
    errorGeneral.value = "";
    if (props.tipo === "area" && opcEmpresas.value.length === 1) d.empresaRucId = opcEmpresas.value[0].value;
  },
);

async function guardar() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    if (props.tipo === "sucursal") {
      await organizacionApi.crearSucursal({ codigo: d.codigo, nombre: d.nombre });
      await notify.exito("Sucursal creada");
    } else if (props.tipo === "empresa") {
      await organizacionApi.crearEmpresa({ ruc: d.ruc, razonSocial: d.nombre });
      await notify.exito("Empresa creada", "Asóciela a una sucursal para poder usarla.");
    } else {
      await organizacionApi.crearArea({ empresaRucId: d.empresaRucId, codigo: d.codigo, nombre: d.nombre });
      await notify.exito("Área creada");
    }
    emit("guardado");
  } catch (e) {
    errorGeneral.value = e.message ?? "No se pudo crear.";
  } finally {
    enviando.value = false;
  }
}
</script>
