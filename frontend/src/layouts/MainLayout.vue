<template>
  <div :class="['app', plegada ? 'sidebar-collapsed' : '']">
    <Sidebar />
    <main class="main">
      <Topbar />
      <div class="page"><router-view /></div>
    </main>
  </div>
</template>

<script setup>
import Sidebar from "./Sidebar.vue";
import Topbar from "./Topbar.vue";
import { useSidebar } from "../shared/composables/useSidebar.js";

const { plegada } = useSidebar();
</script>

<style scoped>
/* El armazón vive en globals.css:
   - .app es un grid de dos columnas (sidebar + contenido); el sidebar es un
     HERMANO del contenido, no una capa flotante encima con margin-left.
   - .sidebar es sticky a 100vh, así que el pie con el usuario nunca se va con
     el scroll.
   - .page centra la columna de trabajo en --ancho-contenido. */
</style>
