<template>
  <div>
    <Cargando v-if="cargando" />
    <template v-else>
      <div v-if="soloLectura" class="aviso-lectura">
        La conversación quedó en solo lectura al cerrar la OT. Se reactiva si se reabre.
      </div>

      <section class="card">
        <div class="card-cuerpo">
          <div v-if="!linea.length" class="muted" style="font-size: 12.5px">
            Todavía no hay mensajes. Aquí conversan el solicitante y el coordinador.
          </div>

          <!--
            Mensajes humanos y eventos de sistema comparten la línea de tiempo,
            pero se distinguen por tipo (cap. 13). Mezclarlos sin diferenciar
            haría creer que el sistema "dijo" algo que en realidad hizo.
          -->
          <div v-for="m in linea" :key="m.id" class="msg" :class="clase(m)">
            <div class="msg-avatar">
              <Settings2 v-if="m.clase === 'evento'" :size="13" />
              <template v-else>{{ iniciales(m.autor) }}</template>
            </div>
            <div class="msg-cuerpo">
              <div class="msg-cab">
                <span class="msg-autor">{{ m.autor ?? "Sistema" }}</span>
                <span class="msg-hora">{{ fechaHora(m.fecha) }}</span>
                <span v-if="m.visibilidad === 'interna'" class="tag espera">Nota interna</span>
                <span v-if="m.estado === 'editado'" class="muted" style="font-size: 10.5px">editado</span>
              </div>
              <div class="msg-texto">
                <template v-if="m.clase === 'evento'">{{ nombreEvento(m.evento) }}{{ m.motivo ? " · " + m.motivo : "" }}</template>
                <template v-else-if="m.estado === 'retirado'">Mensaje retirado</template>
                <template v-else>{{ m.cuerpo }}</template>
              </div>
            </div>
          </div>
        </div>

        <div v-if="!soloLectura && puede('conversacion:escribir')" class="card-cuerpo" style="border-top: 1px solid var(--line-soft)">
          <textarea
            v-model.trim="borrador" class="textarea"
            placeholder="Escriba un mensaje. Un mensaje no sustituye un avance, un diagnóstico ni una incidencia."
          ></textarea>
          <div class="fila fila-sep" style="margin-top: 9px">
            <label v-if="puedeInterna" class="fila" style="gap: 6px; font-size: 12.5px; cursor: pointer">
              <input type="checkbox" v-model="interna" />
              Nota interna · el solicitante no la verá
            </label>
            <span v-else></span>
            <button class="btn primary" :disabled="!borrador || enviando" @click="publicar">
              {{ enviando ? "Enviando…" : "Enviar" }}
            </button>
          </div>
        </div>
      </section>
    </template>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { Settings2 } from "lucide-vue-next";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import { otApi } from "../api/ot.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";
import { fechaHora, iniciales, nombreEvento } from "../../../shared/utils/formato.js";

const props = defineProps({
  otId: { type: String, required: true },
  soloLectura: { type: Boolean, default: false },
});
const { puede } = useAuth();

const linea = ref([]);
const cargando = ref(true);
const borrador = ref("");
const interna = ref(false);
const enviando = ref(false);

const puedeInterna = computed(() => puede("administrativo:ver") || puede("ot:cerrar"));

function clase(m) {
  if (m.clase === "evento") return "sistema";
  if (m.estado === "retirado") return "retirado";
  if (m.visibilidad === "interna") return "interna";
  return "";
}

async function cargar() {
  cargando.value = true;
  try {
    linea.value = (await otApi.conversacion(props.otId)).data ?? [];
  } catch (e) {
    await mostrarError(e, "No se pudo cargar la conversación");
  } finally {
    cargando.value = false;
  }
}

async function publicar() {
  enviando.value = true;
  try {
    await otApi.publicarMensaje(props.otId, {
      cuerpo: borrador.value,
      visibilidad: interna.value ? "interna" : "canal",
    });
    borrador.value = "";
    interna.value = false;
    await cargar();
  } catch (e) {
    await mostrarError(e, "No se pudo enviar el mensaje");
  } finally {
    enviando.value = false;
  }
}

onMounted(cargar);
</script>

<style scoped>
.aviso-lectura {
  padding: 9px 12px; margin-bottom: 12px;
  border: 1px solid var(--line); border-radius: var(--radio);
  background: var(--bg-soft); color: var(--ink-3); font-size: 12.5px;
}
</style>
