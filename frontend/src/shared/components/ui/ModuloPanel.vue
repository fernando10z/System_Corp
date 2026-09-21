<template>
  <!--
    El contenedor de toda pantalla de listado.

    Cabecera y filtros forman UN bloque: antes la cabecera llevaba su borde y la
    barra de filtros su fondo gris, y el resultado se leía como un recuadro
    metido dentro de otro. Ahora comparten superficie y sólo una línea los
    separa de los datos, que es lo único que de verdad hay que separar.
  -->
  <section class="module-panel">
    <header class="module-panel-head" :class="{ 'con-filtros': !!$slots.filtros }">
      <h2>
        <span v-if="icono" :class="['icon-tile', color]"><component :is="icono" :size="14" /></span>
        <span class="truncar">{{ titulo }}</span>
        <span v-if="conteo !== null && conteo !== undefined" class="head-meta">{{ conteo }}</span>
      </h2>
      <div v-if="$slots.acciones" class="module-panel-head-actions"><slot name="acciones" /></div>
    </header>

    <div v-if="$slots.filtros" class="module-panel-toolbar"><slot name="filtros" /></div>

    <div :class="['module-panel-body', aSangre ? 'tabla-wrap' : '']"><slot /></div>

    <footer v-if="$slots.pie" class="module-panel-foot"><slot name="pie" /></footer>
  </section>
</template>

<script setup>
defineProps({
  titulo: { type: String, required: true },
  icono: { type: [Object, Function], default: null },
  color: { type: String, default: "" },
  conteo: { type: [Number, String], default: null },
  /** Las tablas van a sangre: usan el borde de la tarjeta como marco. */
  aSangre: { type: Boolean, default: false },
});
</script>
