import {
  LayoutDashboard, Inbox, ClipboardList, Coins, BarChart3,
  Building2, Users, ShieldCheck, Settings, ScrollText, Truck,
} from "lucide-vue-next";

/**
 * Fuente única de la navegación. La usan el sidebar, las migas de la barra
 * superior y el buscador global; añadir una pantalla en tres sitios distintos
 * es exactamente cómo se desincronizan.
 *
 * `permiso` se comprueba con useAuth().puede(). Es sólo para MOSTRAR: quien
 * autoriza de verdad es el stored procedure.
 *
 * `claves` son sinónimos para el buscador: quien busca "compras" o "sap" debe
 * encontrar la pantalla de SOLPED aunque no se llame así.
 */
export const SECCIONES = [
  {
    titulo: "Operación",
    items: [
      {
        to: "/inicio", label: "Inicio", icono: LayoutDashboard, permiso: null,
        claves: "bandeja tablero panel pendientes",
      },
      {
        to: "/solicitudes", label: "Solicitudes", icono: Inbox, permiso: "solicitudes:listar",
        contador: "solicitudes", claves: "reportes entrada pedidos revisar",
      },
      {
        to: "/ot", label: "Órdenes de trabajo", icono: ClipboardList, permiso: "ot:listar",
        contador: "revision", claves: "ot trabajos intervenciones derivadas",
      },
    ],
  },
  {
    titulo: "Administración de compras",
    items: [
      {
        to: "/administrativo", label: "SOLPED · OC · liberación", icono: Truck,
        permiso: "administrativo:ver", contador: "administrativo",
        claves: "compras sap solped orden de compra liberacion",
      },
    ],
  },
  {
    titulo: "Análisis",
    items: [
      {
        to: "/costos", label: "Costos unitarios", icono: Coins, permiso: "costos:ver",
        claves: "precios historico proveedores promedio",
      },
      {
        to: "/reportes", label: "Reportes", icono: BarChart3, permiso: "reportes:ver",
        claves: "indicadores kpi metricas exportar",
      },
    ],
  },
  {
    titulo: "Configuración",
    items: [
      {
        to: "/organizacion", label: "Organización", icono: Building2, permiso: "organizacion:crear",
        claves: "sucursal empresa ruc area",
      },
      {
        to: "/usuarios", label: "Usuarios", icono: Users, permiso: "usuarios:listar",
        claves: "personas cuentas altas equipo",
      },
      {
        to: "/roles", label: "Roles y permisos", icono: ShieldCheck, permiso: "roles:listar",
        claves: "accesos matriz seguridad",
      },
      {
        to: "/auditoria", label: "Auditoría", icono: ScrollText, permiso: "auditoria:ver",
        claves: "log historial cambios trazabilidad tecnica",
      },
      {
        to: "/configuracion", label: "Parámetros", icono: Settings, permiso: "configuracion:editar",
        claves: "ajustes configuracion umbrales",
      },
    ],
  },
];

/** Aplana la navegación para resolver las migas por ruta. */
export function tituloDeRuta(path) {
  for (const s of SECCIONES) {
    for (const i of s.items) {
      if (path === i.to || path.startsWith(i.to + "/")) return { seccion: s.titulo, item: i.label, base: i.to };
    }
  }
  return { seccion: "", item: "", base: "" };
}

/** Lista plana de lo que este usuario puede abrir. La consume el buscador. */
export function itemsNavegables(puede) {
  return SECCIONES.flatMap((s) =>
    s.items.filter((i) => puede(i.permiso)).map((i) => ({ ...i, seccion: s.titulo })),
  );
}
