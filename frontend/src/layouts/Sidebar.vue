<template>
  <aside :class="['sidebar', plegada ? 'is-collapsed' : '']">
    <div class="brand">
      <div class="brand-logo" aria-hidden="true">M</div>
      <div v-if="!plegada" class="brand-text">
        <div class="brand-name">MIP</div>
        <div class="brand-sub">Mantenimiento industrial</div>
      </div>
    </div>

    <nav class="nav-scroll" aria-label="Navegación principal">
      <div v-for="s in seccionesVisibles" :key="s.titulo">
        <div v-if="!plegada" class="nav-section-label">{{ s.titulo }}</div>
        <router-link
          v-for="i in s.items"
          :key="i.to"
          :to="i.to"
          class="nav-item"
          :class="{ active: esActiva(i.to) }"
          :title="plegada ? i.label : undefined"
        >
          <component :is="i.icono" :size="16" class="icon" />
          <span v-if="!plegada" class="label">{{ i.label }}</span>
          <!-- El contador ámbar dice "esto te espera a ti". -->
          <span v-if="contadores[i.contador]" class="badge">{{ contadores[i.contador] }}</span>
        </router-link>
      </div>
    </nav>

  </aside>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useRoute } from "vue-router";
import { SECCIONES } from "../shared/config/navigation.js";
import { useAuth } from "../shared/composables/useAuth.js";
import { useSidebar } from "../shared/composables/useSidebar.js";
import { apiFetch } from "../shared/api/client.js";

const route = useRoute();
const { plegada } = useSidebar();
const { puede } = useAuth();

const contadores = ref({});

const seccionesVisibles = computed(() =>
  SECCIONES.map((s) => ({ ...s, items: s.items.filter((i) => puede(i.permiso)) })).filter(
    (s) => s.items.length > 0,
  ),
);

// La ruta activa se resuelve por prefijo para que /ot/:id mantenga marcado "OT".
function esActiva(to) {
  return route.path === to || route.path.startsWith(to + "/");
}

/**
 * Los contadores salen del tablero del coordinador. Si el usuario no tiene
 * acceso a ese tablero, sencillamente no hay contadores: no se inventa un cero.
 */
onMounted(async () => {
  if (!puede("ot:listar")) return;
  try {
    const r = await apiFetch("/dashboard/coordinador");
    const d = r.data;
    contadores.value = {
      solicitudes: d.solicitudes_nuevas?.total || 0,
      revision: d.revision_final?.total || 0,
      administrativo: d.administracion_pendiente?.total || 0,
    };
  } catch {
    contadores.value = {};
  }
});
</script>
