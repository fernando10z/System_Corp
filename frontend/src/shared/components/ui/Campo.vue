<template>
  <!--
    Un campo de formulario: etiqueta, control, ayuda y error, siempre en el
    mismo orden. Tenerlo en un componente evita que cada modal invente su propia
    separación y su propio tamaño de letra.
  -->
  <label class="campo">
    <span v-if="label" class="campo-label">
      {{ label }}
      <span v-if="requerido" aria-hidden="true" style="color: var(--red)">*</span>
      <!-- De dónde salió un dato que el sistema escribió solo. -->
      <span v-if="marca" class="campo-marca" :class="tono">{{ marca }}</span>
    </span>
    <slot />
    <span v-if="error" class="campo-error">{{ error }}</span>
    <span v-else-if="ayuda" class="campo-ayuda">{{ ayuda }}</span>
  </label>
</template>

<script setup>
defineProps({
  label: { type: String, default: "" },
  ayuda: { type: String, default: "" },
  error: { type: String, default: "" },
  requerido: { type: Boolean, default: false },

  /** Procedencia del valor cuando no lo escribió la persona (p. ej. "del PDF"). */
  marca: { type: String, default: "" },
  /** `ok` = leído con su etiqueta. `espera` = deducido, hay que confirmarlo. */
  tono: { type: String, default: "ok" },
});
</script>
