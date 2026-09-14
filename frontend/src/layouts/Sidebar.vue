<template>
  <aside class="sidebar">
    <div class="marca">
      <div class="marca-glifo" aria-hidden="true">M</div>
      <div class="marca-texto" v-show="!plegada">
        <div class="marca-nombre">MIP</div>
        <div class="marca-sub">Mantenimiento</div>
      </div>
    </div>

    <nav class="nav" aria-label="Navegación principal">
      <div v-for="s in seccionesVisibles" :key="s.titulo" class="nav-seccion">
        <div class="nav-titulo">{{ s.titulo }}</div>
        <router-link
          v-for="i in s.items"
          :key="i.to"
          :to="i.to"
          class="nav-item"
          :class="{ activo: esActiva(i.to) }"
          :title="plegada ? i.label : undefined"
        >
          <component :is="i.icono" :size="16" :stroke-width="1.9" />
          <span>{{ i.label }}</span>
          <!-- El contador ámbar dice "esto te espera a ti". -->
          <span v-if="contadores[i.contador]" class="nav-pendiente">{{ contadores[i.contador] }}</span>
        </router-link>
      </div>
    </nav>

    <div class="nav-usuario">
      <div class="msg-avatar" :title="usuario?.nombre">{{ usuario?.iniciales ?? "··" }}</div>
      <div v-show="!plegada" class="crecer" style="min-width: 0">
        <div style="font-size: 12.5px; font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">
          {{ usuario?.nombre }}
        </div>
        <div class="muted" style="font-size: 10.5px">{{ usuario?.cargo ?? rolPrincipal }}</div>
      </div>
    </div>
  </aside>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useRoute } from "vue-router";
import { SECCIONES } from "../shared/config/navigation.js";
import { useAuth } from "../shared/composables/useAuth.js";
import { useSidebar } from "../shared/composables/useSidebar.js";
import { apiFetch } from "../shared/api/client.js";
import { etiqueta } from "../shared/utils/formato.js";

const route = useRoute();
const { plegada } = useSidebar();
const { usuario, puede, estado } = useAuth();

const contadores = ref({});

const seccionesVisibles = computed(() =>
  SECCIONES.map((s) => ({ ...s, items: s.items.filter((i) => puede(i.permiso)) })).filter(
    (s) => s.items.length > 0,
  ),
);

const rolPrincipal = computed(() => etiqueta(estado.roles?.[0] ?? ""));

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
