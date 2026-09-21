<template>
  <div class="pila">
    <Cargando v-if="cargando" texto="Reconstruyendo la jerarquía…" />

    <template v-else>
      <div v-if="jerarquia?.bloqueantes_abiertas" class="aviso peligro">
        <GitBranch :size="15" />
        <div>
          <b>{{ jerarquia.bloqueantes_abiertas }} derivada(s) bloquean el cierre.</b>
          La OT padre no puede cerrarse mientras sigan vivas.
        </div>
      </div>

      <section class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile violet"><GitBranch :size="14" /></span>
            Jerarquía
          </span>
        </div>
        <div class="card-cuerpo">
          <p class="muted" style="margin: 0 0 14px; font-size: 12.5px; max-width: 72ch">
            Una OT representa una intervención ejecutable. Cuando el trabajo se divide por especialidad, proveedor o
            alcance, se separa en derivadas para que costos y cierres no se mezclen. La sangría es el nivel real de
            derivación, no una decoración.
          </p>
          <ArbolDerivadas
            :nodos="jerarquia?.nodos ?? []"
            :actual="otId"
            @abrir="(n) => n.id !== otId && $router.push(`/ot/${n.id}`)"
          />
        </div>
      </section>

      <!-- Consolidación informativa: no fusiona estados ni reescribe historiales. -->
      <section v-if="consolidado?.total_descendientes" class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile neutral"><Network :size="14" /></span>
            Resumen de descendientes
          </span>
          <span class="muted" style="font-size: 11.5px">{{ consolidado.nota }}</span>
        </div>
        <div class="card-cuerpo defs">
          <div>
            <div class="def-k">Descendientes</div>
            <div class="def-v mono" style="font-size: 18px; font-weight: 600">{{ consolidado.total_descendientes }}</div>
          </div>
          <div>
            <div class="def-k">Bloquean el cierre</div>
            <div
              class="def-v mono"
              :style="consolidado.bloquean_cierre ? 'color:var(--red-ink);font-weight:700;font-size:18px' : 'font-size:18px'"
            >
              {{ consolidado.bloquean_cierre }}
            </div>
          </div>
          <div v-for="(n, k) in consolidado.por_estado" :key="k">
            <div class="def-k">{{ etiqueta(k) }}</div>
            <div class="def-v mono">{{ n }}</div>
          </div>
        </div>
      </section>
    </template>
  </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import { GitBranch, Network } from "lucide-vue-next";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import ArbolDerivadas from "../../../shared/components/ui/ArbolDerivadas.vue";
import { otApi } from "../api/ot.api.js";
import { etiqueta } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const props = defineProps({ otId: { type: String, required: true } });

const jerarquia = ref(null);
const consolidado = ref(null);
const cargando = ref(true);

onMounted(async () => {
  try {
    const [j, c] = await Promise.all([otApi.jerarquia(props.otId), otApi.consolidado(props.otId)]);
    jerarquia.value = j.data;
    consolidado.value = c.data;
  } catch (e) {
    await mostrarError(e, "No se pudo cargar la jerarquía");
  } finally {
    cargando.value = false;
  }
});
</script>
