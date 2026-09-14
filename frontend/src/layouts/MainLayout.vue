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
/* El armazón vive en globals.css: .sidebar es fixed y .main lleva el margen. */
</style>
