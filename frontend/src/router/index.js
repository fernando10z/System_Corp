import { createRouter, createWebHistory } from "vue-router";
import { ACCESS_TOKEN_KEY, USER_KEY } from "../shared/config/api.config.js";
import MainLayout from "../layouts/MainLayout.vue";
import Login from "../modules/auth/pages/Login.vue";

const rutas = [
  { path: "/", redirect: "/inicio" },
  { path: "/login", name: "login", component: Login, meta: { publica: true } },

  {
    path: "/",
    component: MainLayout,
    meta: { requiereAuth: true },
    children: [
      { path: "inicio", name: "inicio", component: () => import("../modules/inicio/pages/Inicio.vue") },

      { path: "solicitudes", name: "solicitudes", component: () => import("../modules/solicitudes/pages/Solicitudes.vue") },
      { path: "solicitudes/nueva", name: "solicitud-nueva", component: () => import("../modules/solicitudes/pages/SolicitudNueva.vue") },
      { path: "solicitudes/:id", name: "solicitud-detalle", component: () => import("../modules/solicitudes/pages/SolicitudDetalle.vue") },

      { path: "ot", name: "ot", component: () => import("../modules/ot/pages/OrdenesTrabajo.vue") },
      // La ficha de OT es la pantalla central del producto.
      { path: "ot/:id", name: "ot-detalle", component: () => import("../modules/ot/pages/OtDetalle.vue") },

      { path: "administrativo", name: "administrativo", component: () => import("../modules/administrativo/pages/Administrativo.vue") },
      { path: "costos", name: "costos", component: () => import("../modules/costos/pages/Costos.vue") },
      { path: "reportes", name: "reportes", component: () => import("../modules/reportes/pages/Reportes.vue") },

      { path: "organizacion", name: "organizacion", component: () => import("../modules/organizacion/pages/Organizacion.vue") },
      { path: "usuarios", name: "usuarios", component: () => import("../modules/usuarios/pages/Usuarios.vue") },
      { path: "roles", name: "roles", component: () => import("../modules/roles/pages/Roles.vue") },
      { path: "auditoria", name: "auditoria", component: () => import("../modules/auditoria/pages/Auditoria.vue") },
      { path: "configuracion", name: "configuracion", component: () => import("../modules/configuracion/pages/Configuracion.vue") },
    ],
  },

  { path: "/:pathMatch(.*)*", redirect: "/inicio" },
];

const router = createRouter({ history: createWebHistory(), routes: rutas });

router.beforeEach((to) => {
  if (to.meta.publica) return true;

  const autenticado = !!localStorage.getItem(ACCESS_TOKEN_KEY) && !!localStorage.getItem(USER_KEY);
  if (to.meta.requiereAuth && !autenticado) {
    return { path: "/login", query: { desde: to.fullPath } };
  }
  if (to.path === "/login" && autenticado) return { path: "/inicio" };
  return true;
});

export default router;
