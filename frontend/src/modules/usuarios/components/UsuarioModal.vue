<template>
  <Modal
    :abierto="abierto"
    ancho="ancho"
    persistente
:titulo="editando ? `Editar a ${usuario.nombre}` : 'Nuevo usuario'"
    :subtitulo="editando
      ? 'El correo no se edita: es la identidad con la que firmó su historial y con la que entra.'
      : 'Se crea activo y con una contraseña inicial que deberá cambiar al entrar.'"
    @cerrar="$emit('cerrar')"
  >
    <form id="form-usuario" class="col" style="gap: 16px" @submit.prevent="guardar">
      <div class="form-grid">
        <Campo label="Nombres" requerido :error="tocado && !d.nombres ? 'Obligatorio.' : ''">
          <input v-model.trim="d.nombres" class="input" :class="{ error: tocado && !d.nombres }" placeholder="María Elena" />
        </Campo>
        <Campo label="Apellidos" requerido :error="tocado && !d.apellidos ? 'Obligatorio.' : ''">
          <input v-model.trim="d.apellidos" class="input" :class="{ error: tocado && !d.apellidos }" placeholder="Quispe Ramos" />
        </Campo>
      </div>

      <Campo v-if="!editando" label="Correo" requerido :error="tocado && !emailValido ? 'Escriba un correo válido.' : ''">
        <input
          v-model.trim="d.email" type="email" class="input"
          :class="{ error: tocado && !emailValido }" placeholder="nombre@empresa.com"
        />
      </Campo>

      <div v-if="editando" class="aviso">
        <Info :size="15" />
        <div><b>{{ usuario.email }}</b>Para cambiar la contraseña use la acción "Restablecer contraseña".</div>
      </div>

      <Campo
        v-if="!editando"
        label="Contraseña inicial"
        requerido
        :error="tocado && d.password.length < 10 ? 'Necesita al menos 10 caracteres.' : ''"
        ayuda="Entréguesela por un canal distinto al correo. El usuario deberá cambiarla."
      >
        <div class="fila" style="gap: 8px">
          <input
            v-model="d.password" :type="verClave ? 'text' : 'password'" class="input"
            :class="{ error: tocado && d.password.length < 10 }" placeholder="mínimo 10 caracteres"
          />
          <button type="button" class="btn icono" :title="verClave ? 'Ocultar' : 'Mostrar'" @click="verClave = !verClave">
            <EyeOff v-if="verClave" :size="15" />
            <Eye v-else :size="15" />
          </button>
          <button type="button" class="btn" title="Generar una contraseña" @click="generar">
            <Dices :size="15" /> Generar
          </button>
        </div>
      </Campo>

      <div class="form-grid">
        <Campo label="Rol" requerido ayuda="Decide qué ve y qué puede hacer.">
          <SelectMenu v-model="d.rolCodigo" :opciones="opcRoles" placeholder="Elija el rol" />
        </Campo>
        <Campo label="Cargo" ayuda="Opcional. Aparece junto a su nombre.">
          <input v-model.trim="d.cargo" class="input" placeholder="Ej. Técnico mecánico" />
        </Campo>
      </div>

      <div class="form-grid">
        <Campo label="Documento" ayuda="Opcional.">
          <input v-model.trim="d.documento" class="input mono" placeholder="DNI o CE" />
        </Campo>
        <Campo label="Teléfono" ayuda="Opcional.">
          <input v-model.trim="d.telefono" class="input mono" placeholder="9XXXXXXXX" />
        </Campo>
      </div>

      <Campo v-if="editando" label="Estado" ayuda="Un usuario inactivo no puede entrar, pero conserva su historial.">
        <SelectMenu v-model="d.estado" :opciones="OPC_ESTADO" />
      </Campo>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button class="btn primary" form="form-usuario" type="submit" :disabled="enviando || !valido">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Guardando…" : editando ? "Guardar cambios" : "Crear usuario" }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { Dices, Eye, EyeOff, Info, TriangleAlert } from "lucide-vue-next";
import Modal from "../../../shared/components/ui/Modal.vue";
import Campo from "../../../shared/components/ui/Campo.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import { rolesApi, usuariosApi } from "../../shared/catalogos.api.js";
import { notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  /** Con usuario, el modal edita; sin él, da de alta. */
  usuario: { type: Object, default: null },
});
const emit = defineEmits(["cerrar", "guardado"]);

const OPC_ESTADO = [
  { value: "activo", label: "Activo", dot: "var(--emerald)" },
  { value: "inactivo", label: "Inactivo", dot: "var(--ink-4)" },
];

const vacio = () => ({
  nombres: "", apellidos: "", email: "", password: "",
  rolCodigo: "", cargo: "", documento: "", telefono: "", estado: "activo",
});

const editando = computed(() => !!props.usuario);

const d = reactive(vacio());
const roles = ref([]);
const verClave = ref(false);
const enviando = ref(false);
const tocado = ref(false);
const errorGeneral = ref("");

const opcRoles = computed(() =>
  roles.value.map((r) => ({ value: r.codigo, label: r.nombre, hint: `${r.permisos?.length ?? 0} permiso(s)` })),
);

const emailValido = computed(() => /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(d.email));
const valido = computed(() =>
  editando.value
    ? !!d.nombres && !!d.apellidos && !!d.rolCodigo
    : !!d.nombres && !!d.apellidos && emailValido.value && d.password.length >= 10 && !!d.rolCodigo,
);

/** Contraseña inicial legible: se dicta por teléfono sin confundir I con l. */
function generar() {
  const abc = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
  const bytes = crypto.getRandomValues(new Uint32Array(14));
  d.password = Array.from(bytes, (n) => abc[n % abc.length]).join("");
  verClave.value = true;
}

watch(
  () => props.abierto,
  async (v) => {
    if (!v) return;
    Object.assign(d, vacio());
    if (props.usuario) {
      Object.assign(d, {
        nombres: props.usuario.nombres ?? "",
        apellidos: props.usuario.apellidos ?? "",
        cargo: props.usuario.cargo ?? "",
        documento: props.usuario.documento ?? "",
        telefono: props.usuario.telefono ?? "",
        estado: props.usuario.estado ?? "activo",
        rolCodigo: props.usuario.roles?.[0]?.codigo ?? "",
      });
    }
    tocado.value = false;
    verClave.value = false;
    errorGeneral.value = "";
    try {
      roles.value = (await rolesApi.listar()).data ?? [];
      if (roles.value.length === 1) d.rolCodigo = roles.value[0].codigo;
    } catch {
      // Se puede crear sin haber cargado el catálogo; el SP validará el rol.
    }
  },
);

async function guardar() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    if (editando.value) {
      await usuariosApi.actualizar(props.usuario.id, {
        nombres: d.nombres,
        apellidos: d.apellidos,
        cargo: d.cargo,
        documento: d.documento,
        telefono: d.telefono,
        rolCodigos: [d.rolCodigo],
        estado: d.estado,
      });
      await notify.exito("Usuario actualizado");
    } else {
      await usuariosApi.crear({
        nombres: d.nombres,
        apellidos: d.apellidos,
        email: d.email,
        password: d.password,
        rolCodigos: [d.rolCodigo],
        cargo: d.cargo || undefined,
        documento: d.documento || undefined,
        telefono: d.telefono || undefined,
      });
      await notify.exito("Usuario creado", "Pídale que cambie la contraseña al entrar.");
    }
    emit("guardado");
  } catch (e) {
    errorGeneral.value = e.message ?? "No se pudo guardar el usuario.";
  } finally {
    enviando.value = false;
  }
}
</script>
