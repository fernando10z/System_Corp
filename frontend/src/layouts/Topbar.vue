<template>
  <header class="topbar">
    <button class="btn icono plano" :title="plegada ? 'Mostrar el menú' : 'Plegar el menú'" @click="alternarBarra">
      <PanelLeft :size="16" />
    </button>

    <nav class="migas" aria-label="Ubicación">
      <span v-if="migas.seccion">{{ migas.seccion }}</span>
      <ChevronRight v-if="migas.seccion" :size="13" class="muted" />
      <b>{{ migas.item || "MIP" }}</b>
    </nav>

    <div class="crecer"></div>

    <div style="position: relative">
      <button class="btn icono plano" title="Notificaciones" @click="abrirNotificaciones">
        <Bell :size="16" />
        <span
          v-if="noLeidas"
          style="position:absolute;top:3px;right:3px;width:7px;height:7px;border-radius:99px;background:var(--accion)"
        ></span>
      </button>
    </div>

    <button class="btn icono plano" :title="tema === 'dark' ? 'Modo claro' : 'Modo oscuro'" @click="alternar">
      <Sun v-if="tema === 'dark'" :size="16" />
      <Moon v-else :size="16" />
    </button>

    <button class="btn sm" @click="salir">
      <LogOut :size="14" /> Salir
    </button>
  </header>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { Bell, ChevronRight, LogOut, Moon, PanelLeft, Sun } from "lucide-vue-next";
import { tituloDeRuta } from "../shared/config/navigation.js";
import { useSidebar } from "../shared/composables/useSidebar.js";
import { useTheme } from "../shared/composables/useTheme.js";
import { useAuth } from "../shared/composables/useAuth.js";
import { apiFetch } from "../shared/api/client.js";
import { notify } from "../shared/composables/useNotify.js";
import { desde } from "../shared/utils/formato.js";

const route = useRoute();
const router = useRouter();
const { plegada, alternar: alternarBarra } = useSidebar();
const { tema, alternar } = useTheme();
const { logout } = useAuth();

const noLeidas = ref(0);
const migas = computed(() => tituloDeRuta(route.path));

async function cargarNoLeidas() {
  try {
    const r = await apiFetch("/notificaciones?soloNoLeidas=true&limite=1");
    noLeidas.value = r.meta?.no_leidas ?? 0;
  } catch {
    noLeidas.value = 0;
  }
}

async function abrirNotificaciones() {
  try {
    const r = await apiFetch("/notificaciones?limite=12");
    const items = r.data ?? [];
    if (!items.length) {
      await notify.info("Sin notificaciones", "Aquí aparecerá lo que necesite su atención.");
      return;
    }
    const html = items
      .map(
        (n) => `<div style="text-align:left;padding:7px 0;border-bottom:1px solid var(--line-soft)">
            <div style="font-weight:600;font-size:12.5px">${n.titulo}</div>
            <div style="font-size:12px;color:var(--ink-3)">${n.cuerpo ?? ""}</div>
            <div style="font-size:10.5px;color:var(--ink-4);font-family:var(--fuente-mono)">${desde(n.fecha)}</div>
          </div>`,
      )
      .join("");
    const { default: Swal } = await import("sweetalert2");
    const r2 = await Swal.fire({
      title: "Notificaciones",
      html,
      width: 520,
      showCancelButton: true,
      confirmButtonText: "Marcar todo como leído",
      cancelButtonText: "Cerrar",
      buttonsStyling: false,
      reverseButtons: true,
      customClass: { popup: "swal-mip", confirmButton: "btn primary", cancelButton: "btn" },
    });
    if (r2.isConfirmed) {
      await apiFetch("/notificaciones/marcar-leida", { method: "POST", body: {} });
      await cargarNoLeidas();
    }
  } catch (e) {
    await notify.error("No se pudieron cargar las notificaciones", e.message);
  }
}

async function salir() {
  await logout();
  router.push("/login");
}

onMounted(cargarNoLeidas);
</script>
