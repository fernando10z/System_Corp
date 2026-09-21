<template>
  <div>
    <Cargando v-if="cargando" texto="Cargando la conversación…" />

    <template v-else>
      <div v-if="soloLectura" class="aviso" style="margin-bottom: var(--gap-paneles)">
        <Lock :size="15" />
        <div>La conversación quedó en solo lectura al cerrar la OT. Se reactiva si se reabre.</div>
      </div>

      <section class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile neutral"><MessagesSquare :size="14" /></span>
            Conversación
            <span class="head-meta">{{ linea.length }}</span>
          </span>
          <span class="muted" style="font-size: 12px">Solicitante y coordinador, más los hechos del sistema</span>
        </div>

        <div class="card-cuerpo">
          <p v-if="!linea.length" class="muted" style="margin: 0; font-size: 12.5px">
            Todavía no hay mensajes. Aquí conversan el solicitante y el coordinador sobre esta OT.
          </p>

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
                <span v-if="m.visibilidad === 'interna'" class="tag espera"><EyeOff :size="10" /> Nota interna</span>
                <span v-if="m.estado === 'editado'" class="mas-muted" style="font-size: 10.5px">editado</span>
              </div>
              <div class="msg-texto">
                <template v-if="m.clase === 'evento'">
                  {{ nombreEvento(m.evento) }}{{ m.motivo ? " · " + m.motivo : "" }}
                </template>
                <template v-else-if="m.estado === 'retirado'">Mensaje retirado</template>
                <template v-else>{{ m.cuerpo }}</template>
              </div>
            </div>
          </div>
        </div>

        <div v-if="!soloLectura && puede('conversacion:escribir')" class="card-cuerpo">
          <textarea
            v-model.trim="borrador"
            class="textarea"
            style="min-height: 76px"
            placeholder="Escriba un mensaje. Un mensaje no sustituye un avance, un diagnóstico ni una incidencia."
          />
          <div class="fila fila-sep" style="margin-top: 10px">
            <label v-if="puedeInterna" class="check-linea">
              <input type="checkbox" v-model="interna" />
              <span>Nota interna · el solicitante no la verá</span>
            </label>
            <span v-else />
            <button class="btn primary" :disabled="!borrador || enviando" @click="publicar">
              <span v-if="enviando" class="spinner" />
              <Send v-else :size="14" />
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
import { EyeOff, Lock, MessagesSquare, Send, Settings2 } from "lucide-vue-next";
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
