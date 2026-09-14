<template>
  <div class="entrada">
    <!--
      El lado izquierdo no es una imagen decorativa: es la tesis del producto.
      Una OT y todo lo que generó, colgando de ella. Es lo que MIP hace.
    -->
    <aside class="entrada-tesis" aria-hidden="true">
      <div class="tesis-marca">
        <div class="marca-glifo">M</div>
        <div>
          <div class="marca-nombre" style="color: inherit">MIP</div>
          <div class="marca-sub">Maintenance Intelligence Platform</div>
        </div>
      </div>

      <div class="tesis-cuerpo">
        <h2 class="tesis-titulo">Una orden de trabajo,<br />y todo lo que generó.</h2>
        <div class="viajera tesis-arbol">
          <div v-for="(s, i) in muestra" :key="i" class="sello" :class="s.clase" :style="{ animationDelay: i * 90 + 'ms' }">
            <div class="sello-cab">
              <span class="sello-titulo">{{ s.t }}</span>
              <span class="sello-meta">{{ s.m }}</span>
            </div>
          </div>
        </div>
        <p class="tesis-pie">
          Cada decisión queda sellada con su autor, su instante y su motivo.
          Nada se sobrescribe.
        </p>
      </div>
    </aside>

    <main class="entrada-form">
      <div class="entrada-caja">
        <h1 class="page-title" style="font-size: 22px">Entrar</h1>
        <p class="page-sub" style="margin-bottom: 22px">Use el correo con el que le dieron de alta.</p>

        <form class="col" style="gap: 14px" @submit.prevent="entrar">
          <div class="campo">
            <label class="campo-label" for="email">Correo</label>
            <input
              id="email" v-model.trim="email" class="input" type="email"
              autocomplete="username" required autofocus placeholder="nombre@empresa.com"
            />
          </div>

          <div class="campo">
            <label class="campo-label" for="password">Contraseña</label>
            <input
              id="password" v-model="password" class="input" type="password"
              autocomplete="current-password" required
            />
          </div>

          <!-- El error dice qué pasó, sin disculparse ni ser vago. -->
          <p v-if="error" role="alert" class="entrada-error">{{ error }}</p>

          <button class="btn primary" type="submit" :disabled="cargando" style="height: 38px">
            {{ cargando ? "Comprobando…" : "Entrar" }}
          </button>
        </form>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useAuth } from "../../../shared/composables/useAuth.js";

const router = useRouter();
const route = useRoute();
const { login } = useAuth();

const email = ref("");
const password = ref("");
const cargando = ref(false);
const error = ref("");

// Muestra estática: ilustra la idea sin fingir datos de un cliente real.
const muestra = [
  { t: "Solicitud recibida", m: "ST-000148", clase: "hito" },
  { t: "Diagnóstico v2", m: "reemplaza v1", clase: "" },
  { t: "Cotización cargada", m: "S/ 2 850", clase: "" },
  { t: "Derivada OT-000149", m: "otro proveedor", clase: "espera" },
  { t: "Cierre con OC pendiente", m: "revisado", clase: "cierre" },
];

async function entrar() {
  error.value = "";
  cargando.value = true;
  try {
    await login(email.value, password.value);
    router.push(route.query.desde ?? "/inicio");
  } catch (e) {
    error.value =
      e.code === "UNAUTHORIZED"
        ? "El correo o la contraseña no coinciden."
        : e.message || "No se pudo entrar. Inténtelo otra vez.";
  } finally {
    cargando.value = false;
  }
}
</script>

<style scoped>
.entrada { display: grid; grid-template-columns: 1.05fr 1fr; min-height: 100vh; }

.entrada-tesis {
  background: var(--grafito-1);
  color: #f2f4f5;
  padding: 34px 40px;
  display: flex; flex-direction: column; gap: 40px;
  position: relative; overflow: hidden;
}
/* Trama tenue de plano técnico. Se queda en el fondo y no compite con nada. */
.entrada-tesis::after {
  content: ""; position: absolute; inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,0.04) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.04) 1px, transparent 1px);
  background-size: 34px 34px;
  pointer-events: none;
}
.tesis-marca { display: flex; align-items: center; gap: 11px; position: relative; z-index: 1; }
.tesis-marca .marca-glifo { background: var(--senal); color: var(--grafito-1); }
.tesis-marca .marca-sub { color: rgba(242,244,245,0.55); }

.tesis-cuerpo { position: relative; z-index: 1; margin: auto 0; max-width: 430px; }
.tesis-titulo {
  font-size: 33px; line-height: 1.15; letter-spacing: -0.03em;
  margin-bottom: 26px; font-weight: 600;
}
.tesis-arbol { padding-left: 24px; }
/* Dentro del panel oscuro los tokens claros no sirven: se fija la paleta local. */
.tesis-arbol::before { background: linear-gradient(to bottom, rgba(255,255,255,0.3), transparent); }
.tesis-arbol .sello { padding-bottom: 13px; animation: sello-entra 0.4s ease both; }
.tesis-arbol .sello::before {
  background: var(--grafito-1);
  border-color: rgba(255,255,255,0.35);
  box-shadow: 0 0 0 3px var(--grafito-1);
}
.tesis-arbol .sello.hito::before { background: #f2f4f5; border-color: #f2f4f5; }
.tesis-arbol .sello.espera::before { background: var(--senal); border-color: var(--senal); }
.tesis-arbol .sello.cierre::before { background: var(--verde); border-color: var(--verde); }
.tesis-arbol .sello-titulo { color: #f2f4f5; }
.tesis-arbol .sello-meta { color: rgba(242,244,245,0.5); }
.tesis-pie { margin-top: 26px; color: rgba(242,244,245,0.6); font-size: 13px; max-width: 40ch; }

@keyframes sello-entra {
  from { opacity: 0; transform: translateX(-7px); }
  to   { opacity: 1; transform: none; }
}

.entrada-form { display: grid; place-items: center; padding: 34px; background: var(--bg); }
.entrada-caja { width: 100%; max-width: 348px; }
.entrada-error {
  margin: 0;
  padding: 8px 11px;
  border-radius: var(--radio-sm);
  background: var(--rojo-piel);
  border: 1px solid var(--rojo-linea);
  color: var(--rojo);
  font-size: 12.5px;
}

@media (max-width: 900px) {
  .entrada { grid-template-columns: 1fr; }
  .entrada-tesis { display: none; }
}
</style>
