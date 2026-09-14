<template>
  <div style="max-width: 820px">
    <PageHeader
      eyebrow="Configuración"
      title="Parámetros"
      subtitle="Lo que cambia entre clientes se ajusta aquí. El flujo operativo central no se configura: es el mismo para todos."
    />

    <Cargando v-if="cargando" />
    <div v-else class="pila">
      <section class="card">
        <div class="card-head"><span class="card-titulo">Parámetros del cliente</span></div>
        <div class="card-cuerpo">
          <table class="stbl">
            <thead><tr><th>Clave</th><th>Valor</th><th></th></tr></thead>
            <tbody>
              <tr v-for="c in claves" :key="c">
                <td class="mono">{{ c }}</td>
                <td class="mono muted" style="max-width: 380px; overflow: hidden; text-overflow: ellipsis">
                  {{ JSON.stringify(config[c] ?? null) }}
                </td>
                <td class="der"><button class="btn sm" @click="editar(c)">Editar</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!--
        Se muestra explícitamente lo que NO se puede configurar. Es más honesto
        que dejar al administrador buscando un interruptor que no existe.
      -->
      <section class="card">
        <div class="card-head"><span class="card-titulo">Lo que no se configura</span></div>
        <div class="card-cuerpo">
          <ul style="margin: 0; padding-left: 18px; color: var(--ink-2); font-size: 12.5px">
            <li v-for="(n, i) in noConfigurable" :key="i" style="margin-bottom: 4px">{{ n }}</li>
          </ul>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import { configuracionApi } from "../../shared/catalogos.api.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const config = ref({});
const claves = ref([]);
const noConfigurable = ref([]);
const cargando = ref(true);

async function cargar() {
  cargando.value = true;
  try {
    const d = (await configuracionApi.obtener()).data;
    config.value = d.configuracion ?? {};
    claves.value = d.claves_disponibles ?? [];
    noConfigurable.value = d.no_configurable ?? [];
  } catch (e) {
    await mostrarError(e, "No se pudo cargar la configuración");
  } finally {
    cargando.value = false;
  }
}

async function editar(clave) {
  const actual = JSON.stringify(config.value[clave] ?? null, null, 2);
  const texto = await notify.pedirTexto(`Editar ${clave}`, {
    texto: "El valor es JSON. Revise el formato antes de guardar.",
    confirmar: "Guardar",
  });
  if (texto === null) return;
  let valor;
  try {
    valor = JSON.parse(texto);
  } catch {
    return notify.error("El valor no es JSON válido", `Ejemplo del valor actual:\n${actual}`);
  }
  try {
    await configuracionApi.guardar({ clave, valor });
    await notify.exito("Parámetro guardado");
    await cargar();
  } catch (e) { await mostrarError(e); }
}

onMounted(cargar);
</script>
