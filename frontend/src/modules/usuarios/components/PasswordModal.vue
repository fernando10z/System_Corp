<template>
  <!--
    Restablecer la contraseña de OTRA persona. No pide la anterior —quien la
    olvidó no la sabe— y por eso el backend lo audita como acción de
    administración, distinta de que alguien cambie la suya.
  -->
  <Modal
    :abierto="abierto"
    :titulo="`Restablecer la contraseña de ${usuario?.nombre ?? ''}`"
    subtitulo="Entréguesela por un canal distinto al correo. El bloqueo por intentos fallidos, si lo hubiera, se levanta."
    persistente
    @cerrar="$emit('cerrar')"
  >
    <form id="form-password" class="col" style="gap: 14px" @submit.prevent="guardar">
      <Campo label="Contraseña nueva" requerido :error="error" ayuda="Al menos 10 caracteres.">
        <div class="fila" style="gap: 8px">
          <input
            v-model="clave"
            :type="ver ? 'text' : 'password'"
            class="input"
            :class="{ error }"
            autocomplete="new-password"
            placeholder="mínimo 10 caracteres"
          />
          <button type="button" class="btn icono" :title="ver ? 'Ocultar' : 'Mostrar'" @click="ver = !ver">
            <EyeOff v-if="ver" :size="15" />
            <Eye v-else :size="15" />
          </button>
          <button type="button" class="btn" title="Generar una contraseña" @click="generar">
            <Dices :size="15" /> Generar
          </button>
        </div>
      </Campo>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button class="btn primary" form="form-password" type="submit" :disabled="enviando || clave.length < 10">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Guardando…" : "Restablecer" }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, ref, watch } from "vue";
import { Dices, Eye, EyeOff, TriangleAlert } from "lucide-vue-next";
import Modal from "../../../shared/components/ui/Modal.vue";
import Campo from "../../../shared/components/ui/Campo.vue";
import { usuariosApi } from "../../shared/catalogos.api.js";
import { notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  usuario: { type: Object, default: null },
});
const emit = defineEmits(["cerrar", "hecho"]);

const clave = ref("");
const ver = ref(false);
const tocado = ref(false);
const enviando = ref(false);
const errorGeneral = ref("");

const error = computed(() =>
  tocado.value && clave.value.length < 10 ? "Necesita al menos 10 caracteres." : "",
);

/** Legible al dictarla por teléfono: sin I/l ni O/0 que se confundan. */
function generar() {
  const abc = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
  const bytes = crypto.getRandomValues(new Uint32Array(14));
  clave.value = Array.from(bytes, (n) => abc[n % abc.length]).join("");
  ver.value = true;
}

watch(
  () => props.abierto,
  (v) => {
    if (!v) return;
    clave.value = "";
    ver.value = false;
    tocado.value = false;
    errorGeneral.value = "";
  },
);

async function guardar() {
  tocado.value = true;
  if (clave.value.length < 10) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    await usuariosApi.restablecerPassword(props.usuario.id, clave.value);
    await notify.exito("Contraseña restablecida", "Pídale que la cambie al entrar.");
    emit("hecho");
  } catch (e) {
    errorGeneral.value = e.message ?? "No se pudo restablecer la contraseña.";
  } finally {
    enviando.value = false;
  }
}
</script>
