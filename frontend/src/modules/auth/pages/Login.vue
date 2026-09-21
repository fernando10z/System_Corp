<template>
  <div class="login-hero">
    <!-- Izquierda: la puerta. Nada que distraiga de las dos cajas y el botón. -->
    <div class="login-col">
      <div class="login-card">
        <div class="login-logo" aria-hidden="true"><Wrench :size="24" /></div>
        <h1>MIP</h1>
        <p class="lf-sub">Maintenance Intelligence Platform.<br />Entre con el correo con el que le dieron de alta.</p>

        <form class="lf" @submit.prevent="entrar">
          <p v-if="error" class="lf-error" role="alert"><TriangleAlert :size="15" /> {{ error }}</p>

          <div class="lf-field">
            <label for="email">Correo</label>
            <div class="lf-wrap" :class="{ error: !!error }">
              <Mail :size="15" />
              <input
                id="email" v-model.trim="email" type="email"
                autocomplete="username" required autofocus placeholder="nombre@empresa.com"
              />
            </div>
          </div>

          <div class="lf-field">
            <label for="password">Contraseña</label>
            <div class="lf-wrap" :class="{ error: !!error }">
              <KeyRound :size="15" />
              <input
                id="password" v-model="password" :type="verClave ? 'text' : 'password'"
                autocomplete="current-password" required placeholder="··········"
              />
              <button
                type="button" class="lf-eye"
                :aria-label="verClave ? 'Ocultar la contraseña' : 'Mostrar la contraseña'"
                @click="verClave = !verClave"
              >
                <EyeOff v-if="verClave" :size="15" />
                <Eye v-else :size="15" />
              </button>
            </div>
          </div>

          <button class="lf-submit" type="submit" :disabled="cargando">
            <span v-if="cargando" class="spinner" />
            {{ cargando ? "Comprobando…" : "Entrar" }}
            <ArrowRight v-if="!cargando" :size="16" />
          </button>
        </form>

        <p class="lf-foot">Cada decisión queda sellada · nada se sobrescribe</p>
      </div>
    </div>

    <!--
      Derecha: la tesis del producto, no una ilustración decorativa. Una OT y
      todo lo que generó colgando de ella. Es literalmente lo que MIP hace.
    -->
    <div class="login-col derecha">
      <div class="login-tesis">
        <div class="eyebrow">La orden de trabajo como raíz</div>
        <h2>Una orden de trabajo,<br />y todo lo que generó.</h2>
        <p class="lead">
          El diagnóstico que cambió, la cotización que lo reemplazó, la derivada que bloqueó el cierre y
          la OC que llegó tarde. Todo cuelga de la misma OT, con su autor, su instante y su motivo.
        </p>

        <div class="tesis-card">
          <div class="tesis-card-head">
            <span class="icon-tile"><ClipboardList :size="14" /></span>
            <span class="n">OT-000148</span>
            <span class="estado-op e-en_trabajo">En trabajo</span>
            <span class="crecer" />
            <span class="tag emergencia">Emergencia</span>
          </div>

          <div class="viajera">
            <article
              v-for="(s, i) in muestra"
              :key="i"
              class="sello tesis-sello"
              :class="s.clase"
              :style="{ animationDelay: i * 90 + 'ms' }"
            >
              <div class="sello-cab">
                <span class="sello-titulo">{{ s.t }}</span>
                <span class="sello-meta">{{ s.m }}</span>
              </div>
              <div v-if="s.motivo" class="sello-motivo"><b>Motivo</b>{{ s.motivo }}</div>
            </article>
          </div>
        </div>

        <div class="tesis-chips">
          <span class="tesis-chip"><GitBranch :size="14" /> Derivadas recursivas</span>
          <span class="tesis-chip"><History :size="14" /> Versiones que no se pisan</span>
          <span class="tesis-chip"><ShieldCheck :size="14" /> Auditoría campo a campo</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import {
  ArrowRight, ClipboardList, Eye, EyeOff, GitBranch, History, KeyRound, Mail,
  ShieldCheck, TriangleAlert, Wrench,
} from "lucide-vue-next";
import { useAuth } from "../../../shared/composables/useAuth.js";

const router = useRouter();
const route = useRoute();
const { login } = useAuth();

const email = ref("");
const password = ref("");
const verClave = ref(false);
const cargando = ref(false);
const error = ref("");

// Muestra estática: ilustra la idea sin fingir datos de un cliente real.
const muestra = [
  { t: "Solicitud recibida", m: "ST-000148", clase: "hito" },
  { t: "Diagnóstico v2", m: "reemplaza a v1", clase: "", motivo: "El desmontaje descartó la causa inicial" },
  { t: "Cotización cargada", m: "S/ 2 850,00", clase: "" },
  { t: "Derivada OT-000149", m: "otra especialidad", clase: "espera" },
  { t: "Cierre con OC pendiente", m: "revisado", clase: "cierre" },
];

async function entrar() {
  error.value = "";
  cargando.value = true;
  try {
    await login(email.value, password.value);
    router.push(route.query.desde ?? "/inicio");
  } catch (e) {
    // El servidor distingue "credenciales inválidas" de "cuenta bloqueada" y de
    // "cuenta inactiva". Sustituir todo por un mensaje genérico dejaría a
    // alguien bloqueado reintentando sin entender por qué, y alargando su
    // propio bloqueo. Sólo se suaviza el caso genérico.
    error.value =
      e.message && !/credenciales inválidas/i.test(e.message)
        ? e.message
        : "El correo o la contraseña no coinciden.";
  } finally {
    cargando.value = false;
  }
}
</script>
