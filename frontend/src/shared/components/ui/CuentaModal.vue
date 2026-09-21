<template>
  <!--
    La cuenta propia: ver quién se es y cambiar la contraseña. Es distinto de
    administrar usuarios —eso vive en Configuración y exige permiso—; esto lo
    tiene cualquiera sobre sí mismo.
  -->
  <Modal
    :abierto="abierto"
    titulo="Mi cuenta"
    subtitulo="Sus datos y su contraseña. Para cambiar el correo o el cargo, pídaselo a un administrador."
    @cerrar="$emit('cerrar')"
  >
    <div class="col" style="gap: 18px">
      <div class="cuenta-cab">
        <div class="avatar-sm lg">{{ usuario?.iniciales ?? "··" }}</div>
        <div class="crecer" style="min-width: 0">
          <div style="font-size: 15px; font-weight: 600">{{ usuario?.nombre }}</div>
          <div class="mono mas-muted truncar" style="font-size: 12px">{{ usuario?.email }}</div>
          <div class="fila fila-wrap" style="gap: 5px; margin-top: 7px">
            <span v-for="r in estado.roles" :key="r" class="tag">{{ etiqueta(r) }}</span>
            <span v-if="usuario?.cargo" class="tag">{{ usuario.cargo }}</span>
          </div>
        </div>
      </div>

      <div class="separador" />

      <form id="form-cuenta" class="col" style="gap: 14px" @submit.prevent="guardar">
        <div class="eyebrow">Cambiar la contraseña</div>

        <Campo label="Contraseña actual" requerido :error="err.actual">
          <input v-model="d.actual" type="password" class="input" :class="{ error: err.actual }" autocomplete="current-password" />
        </Campo>

        <Campo
          label="Contraseña nueva"
          requerido
          :error="err.nueva"
          ayuda="Al menos 10 caracteres. No la reutilice de otro sistema."
        >
          <input v-model="d.nueva" type="password" class="input" :class="{ error: err.nueva }" autocomplete="new-password" />
        </Campo>

        <Campo label="Repita la contraseña nueva" requerido :error="err.repetir">
          <input v-model="d.repetir" type="password" class="input" :class="{ error: err.repetir }" autocomplete="new-password" />
        </Campo>

        <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
        <p v-if="hecho" class="aviso ok"><Check :size="15" /> Contraseña actualizada.</p>
      </form>
    </div>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cerrar</button>
      <button class="btn primary" form="form-cuenta" type="submit" :disabled="enviando || !valido">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Guardando…" : "Cambiar contraseña" }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { Check, TriangleAlert } from "lucide-vue-next";
import Modal from "./Modal.vue";
import Campo from "./Campo.vue";
import { useAuth } from "../../composables/useAuth.js";
import { apiFetch } from "../../api/client.js";
import { etiqueta } from "../../utils/formato.js";

const props = defineProps({ abierto: { type: Boolean, required: true } });
defineEmits(["cerrar"]);

const { usuario, estado } = useAuth();

const d = reactive({ actual: "", nueva: "", repetir: "" });
const tocado = ref(false);
const enviando = ref(false);
const errorGeneral = ref("");
const hecho = ref(false);

const err = computed(() => ({
  actual: tocado.value && !d.actual ? "Escriba su contraseña actual." : "",
  nueva: tocado.value && d.nueva.length < 10 ? "Al menos 10 caracteres." : "",
  repetir: tocado.value && d.repetir !== d.nueva ? "No coincide con la nueva." : "",
}));

const valido = computed(() => !!d.actual && d.nueva.length >= 10 && d.repetir === d.nueva);

watch(
  () => props.abierto,
  (v) => {
    if (!v) return;
    Object.assign(d, { actual: "", nueva: "", repetir: "" });
    tocado.value = false;
    errorGeneral.value = "";
    hecho.value = false;
  },
);

async function guardar() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  hecho.value = false;
  try {
    await apiFetch("/auth/cambiar-password", {
      method: "POST",
      body: { passwordActual: d.actual, passwordNueva: d.nueva },
    });
    hecho.value = true;
    Object.assign(d, { actual: "", nueva: "", repetir: "" });
    tocado.value = false;
  } catch (e) {
    errorGeneral.value = e.message ?? "No se pudo cambiar la contraseña.";
  } finally {
    enviando.value = false;
  }
}
</script>

<style scoped>
.cuenta-cab { display: flex; align-items: flex-start; gap: 14px; }
.separador { height: 1px; background: var(--line-soft); }
</style>
