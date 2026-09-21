<template>
  <header class="topbar">
    <button
      class="icon-btn plano"
      :title="plegada ? 'Mostrar el menú' : 'Plegar el menú'"
      :aria-label="plegada ? 'Mostrar el menú' : 'Plegar el menú'"
      @click="alternarBarra"
    >
      <PanelLeftOpen v-if="plegada" :size="16" />
      <PanelLeftClose v-else :size="16" />
    </button>

    <nav class="crumbs" aria-label="Ubicación">
      <router-link v-if="migas.length > 1" to="/inicio" class="c">Inicio</router-link>
      <template v-for="(m, i) in migas" :key="i">
        <span v-if="i > 0 || migas.length > 1" class="sep"><ChevronRight :size="12" /></span>
        <router-link v-if="m.to" :to="m.to" class="c">{{ m.label }}</router-link>
        <span v-else class="c current">{{ m.label }}</span>
      </template>
    </nav>

    <div class="spacer" />

    <BuscadorGlobal />

    <!-- Notificaciones: lo que espera al usuario, sin salir de la pantalla. -->
    <div ref="raizNotis" class="pop-wrap">
      <button class="icon-btn" aria-label="Notificaciones" @click="alternarNotis">
        <Bell :size="15" />
        <span v-if="noLeidas > 0" class="noti-dot">{{ noLeidas > 9 ? "9+" : noLeidas }}</span>
      </button>
      <Transition name="pop">
        <div v-if="notisAbiertas" class="pop-menu noti-menu">
          <div class="pop-head">
            <span>Notificaciones</span>
            <button v-if="noLeidas > 0" class="link-mini" @click="marcarTodas">Marcar todas</button>
          </div>
          <div v-if="!notis.length" class="pop-empty">Nada pendiente de su atención.</div>
          <button
            v-for="n in notis"
            :key="n.id"
            :class="['noti-item', n.leida_at ? '' : 'nueva']"
            @click="abrirNoti(n)"
          >
            <div class="t">{{ n.titulo }}</div>
            <div v-if="n.cuerpo" class="b">{{ n.cuerpo }}</div>
            <div class="f">{{ desde(n.fecha ?? n.created_at) }}</div>
          </button>
        </div>
      </Transition>
    </div>

    <button
      class="icon-btn"
      :title="esOscuro ? 'Modo claro' : 'Modo oscuro'"
      :aria-label="esOscuro ? 'Activar modo claro' : 'Activar modo oscuro'"
      @click="alternar"
    >
      <Transition name="tema" mode="out-in">
        <Sun v-if="esOscuro" key="sol" :size="15" />
        <Moon v-else key="luna" :size="15" />
      </Transition>
    </button>

    <div ref="raizUsuario" class="pop-wrap">
      <button class="topbar-avatar" aria-label="Menú de usuario" :aria-expanded="usuarioAbierto" @click="usuarioAbierto = !usuarioAbierto">
        {{ usuario?.iniciales ?? "··" }}
      </button>
      <Transition name="pop">
        <div v-if="usuarioAbierto" class="pop-menu user-menu">
          <div class="user-info">
            <div class="avatar-sm lg">{{ usuario?.iniciales ?? "··" }}</div>
            <div class="user-meta">
              <div class="user-name">{{ usuario?.nombre }}</div>
              <div class="user-role">{{ usuario?.email }}</div>
              <!-- El rol va bajo el correo, no en un bloque aparte: es parte de
                   quién es esta persona, no una sección propia. -->
              <div class="user-tags">
                <span v-for="r in estado.roles" :key="r" class="tag">{{ etiqueta(r) }}</span>
                <span v-if="!estado.roles?.length" class="mas-muted" style="font-size: 11.5px">Sin rol asignado</span>
              </div>
            </div>
          </div>
          <div class="user-sep" />
          <button class="user-action" @click="abrirCuenta"><Settings :size="14" /> Mi cuenta</button>
          <button class="user-action peligro" @click="salir"><LogOut :size="14" /> Cerrar sesión</button>
        </div>
      </Transition>
    </div>

    <CuentaModal :abierto="cuenta" @cerrar="cuenta = false" />
  </header>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { Bell, ChevronRight, LogOut, Moon, PanelLeftClose, PanelLeftOpen, Settings, Sun } from "lucide-vue-next";
import BuscadorGlobal from "../shared/components/ui/BuscadorGlobal.vue";
import CuentaModal from "../shared/components/ui/CuentaModal.vue";
import { tituloDeRuta } from "../shared/config/navigation.js";
import { useSidebar } from "../shared/composables/useSidebar.js";
import { useTheme } from "../shared/composables/useTheme.js";
import { useAuth } from "../shared/composables/useAuth.js";
import { useTitulo } from "../shared/composables/useTitulo.js";
import { apiFetch } from "../shared/api/client.js";
import { desde, etiqueta } from "../shared/utils/formato.js";

const route = useRoute();
const router = useRouter();
const { plegada, alternar: alternarBarra } = useSidebar();
const { tema, alternar } = useTheme();
const { logout, usuario, estado } = useAuth();
const { titulo: tituloFicha, limpiar: limpiarTitulo } = useTitulo();

const esOscuro = computed(() => tema.value === "dark");

/**
 * Las migas salen del propio menú: una sola fuente de verdad. En una ficha de
 * detalle se añade un tercer nivel con el título que la ficha publique a
 * través de useTitulo().
 */
const migas = computed(() => {
  const { item, base } = tituloDeRuta(route.path);
  if (!item) return [{ label: "MIP" }];
  const enDetalle = route.path !== base;
  const salida = [{ label: item, to: enDetalle ? base : undefined }];
  if (enDetalle) salida.push({ label: tituloFicha.value || "Detalle" });
  return salida;
});

// ── notificaciones ──────────────────────────────────────────────────────────
const notis = ref([]);
const noLeidas = ref(0);
const notisAbiertas = ref(false);
const raizNotis = ref(null);
let temporizador = null;

async function cargarNotis() {
  try {
    const r = await apiFetch("/notificaciones?limite=12");
    notis.value = r.data ?? [];
    noLeidas.value = r.meta?.no_leidas ?? 0;
  } catch {
    // La bandeja es accesoria: si falla, la barra sigue usable y no se
    // interrumpe al usuario con un diálogo de error.
  }
}

function alternarNotis() {
  notisAbiertas.value = !notisAbiertas.value;
  if (notisAbiertas.value) cargarNotis();
}

async function marcarTodas() {
  await apiFetch("/notificaciones/marcar-leida", { method: "POST", body: {} }).catch(() => undefined);
  await cargarNotis();
}

async function abrirNoti(n) {
  notisAbiertas.value = false;
  if (n.url) router.push(n.url);
}

// ── menú de usuario ─────────────────────────────────────────────────────────
const raizUsuario = ref(null);
const usuarioAbierto = ref(false);
const cuenta = ref(false);

function abrirCuenta() {
  usuarioAbierto.value = false;
  cuenta.value = true;
}

async function salir() {
  usuarioAbierto.value = false;
  await logout();
  router.push("/login");
}

function alClicFuera(e) {
  if (usuarioAbierto.value && raizUsuario.value && !raizUsuario.value.contains(e.target)) usuarioAbierto.value = false;
  if (notisAbiertas.value && raizNotis.value && !raizNotis.value.contains(e.target)) notisAbiertas.value = false;
}

// Al navegar, la miga de detalle se borra hasta que la nueva ficha publique
// la suya: si no, se vería el número de la OT anterior durante la carga.
watch(() => route.path, () => limpiarTitulo());

onMounted(() => {
  document.addEventListener("click", alClicFuera);
  cargarNotis();
  // La bandeja cambia mientras se trabaja: refresco discreto cada minuto.
  temporizador = setInterval(cargarNotis, 60_000);
});
onBeforeUnmount(() => {
  document.removeEventListener("click", alClicFuera);
  if (temporizador) clearInterval(temporizador);
});
</script>

<style scoped>
.tema-enter-active, .tema-leave-active { transition: opacity 0.18s ease, transform 0.18s ease; }
.tema-enter-from { opacity: 0; transform: rotate(-45deg) scale(0.6); }
.tema-leave-to { opacity: 0; transform: rotate(45deg) scale(0.6); }

.noti-menu { width: 330px; max-height: 430px; overflow-y: auto; }
.noti-item {
  display: block; width: 100%; text-align: left;
  padding: 9px 10px; border: none; background: none;
  border-radius: 8px; cursor: pointer;
}
.noti-item:hover { background: var(--bg-soft); }
.noti-item.nueva { background: var(--amber-soft); }
.noti-item .t { font-size: 12.5px; font-weight: 600; color: var(--ink); }
.noti-item .b { font-size: 11.5px; color: var(--ink-3); margin-top: 2px; }
.noti-item .f { font-size: 10.5px; color: var(--ink-4); margin-top: 3px; font-family: var(--font-mono); }

.user-menu { width: 248px; }
.user-info { display: flex; align-items: center; gap: 10px; padding: 8px 8px 10px; }
.user-meta { min-width: 0; }
.user-name { font-size: 13px; font-weight: 600; color: var(--ink); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.user-role { font-size: 11.5px; color: var(--ink-3); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.user-sep { height: 1px; background: var(--line); margin: 2px 0 6px; }
.user-tags { display: flex; flex-wrap: wrap; gap: 4px; margin-top: 6px; }
.user-action {
  width: 100%; display: flex; align-items: center; gap: 9px;
  padding: 9px 10px; background: none; border: none;
  border-radius: 8px; cursor: pointer;
  font-size: 13px; color: var(--ink-2); text-align: left;
}
.user-action:hover { background: var(--bg-soft); }
.user-action.peligro { color: var(--red-ink); }
.user-action.peligro:hover { background: var(--red-soft); }
</style>
