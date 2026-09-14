import {
  LayoutDashboard, Inbox, ClipboardList, Coins, BarChart3,
  Building2, Users, ShieldCheck, Settings, ScrollText, Truck,
} from "lucide-vue-next";

/**
 * Fuente única de la navegación. La usan el sidebar y las migas de la barra
 * superior; añadir una pantalla en dos sitios distintos es cómo se desincronizan.
 *
 * `permiso` se comprueba con useAuth().puede(). Es sólo para MOSTRAR: quien
 * autoriza de verdad es el stored procedure.
 */
export const SECCIONES = [
  {
    titulo: "Operación",
    items: [
      { to: "/inicio", label: "Inicio", icono: LayoutDashboard, permiso: null },
      { to: "/solicitudes", label: "Solicitudes", icono: Inbox, permiso: "solicitudes:listar", contador: "solicitudes" },
      { to: "/ot", label: "Órdenes de trabajo", icono: ClipboardList, permiso: "ot:listar", contador: "revision" },
    ],
  },
  {
    titulo: "Administración de compras",
    items: [
      { to: "/administrativo", label: "SOLPED · OC · liberación", icono: Truck, permiso: "administrativo:ver", contador: "administrativo" },
    ],
  },
  {
    titulo: "Análisis",
    items: [
      { to: "/costos", label: "Costos unitarios", icono: Coins, permiso: "costos:ver" },
      { to: "/reportes", label: "Reportes", icono: BarChart3, permiso: "reportes:ver" },
    ],
  },
  {
    titulo: "Configuración",
    items: [
      { to: "/organizacion", label: "Organización", icono: Building2, permiso: "organizacion:crear" },
      { to: "/usuarios", label: "Usuarios", icono: Users, permiso: "usuarios:listar" },
      { to: "/roles", label: "Roles y permisos", icono: ShieldCheck, permiso: "roles:listar" },
      { to: "/auditoria", label: "Auditoría", icono: ScrollText, permiso: "auditoria:ver" },
      { to: "/configuracion", label: "Parámetros", icono: Settings, permiso: "configuracion:editar" },
    ],
  },
];

/** Aplana la navegación para resolver las migas por ruta. */
export function tituloDeRuta(path) {
  for (const s of SECCIONES) {
    for (const i of s.items) {
      if (path === i.to || path.startsWith(i.to + "/")) return { seccion: s.titulo, item: i.label };
    }
  }
  return { seccion: "", item: "" };
}
