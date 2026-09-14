# Visión general

```
   Navegador
      │  fetch · sobre {ok,data,error,meta}
      ▼
┌──────────────────────────────────────────────┐
│ Frontend · Vue 3 + Vite                      │
│   composables (sin Pinia) · un módulo por    │
│   dominio, espejo de los módulos del backend │
└──────────────────────────────────────────────┘
      │  HTTP · Bearer JWT
      ▼
┌──────────────────────────────────────────────┐
│ Backend · NestJS 10 + Fastify                │
│   controller → service (ctx) → repository    │
│   El repository es el ÚNICO sitio donde      │
│   aparecen nombres de stored procedures.     │
└──────────────────────────────────────────────┘
      │  SELECT app.fn_x($1,$2,…)
      ▼
┌──────────────────────────────────────────────┐
│ PostgreSQL 16                                │
│   app       ← única superficie expuesta      │
│   internal  ← helpers SECURITY DEFINER       │
│   core      ← tablas, enums, triggers        │
│   audit     ← auditoría                      │
└──────────────────────────────────────────────┘
```

## Qué hace cada capa

**Frontend.** Pinta y recoge datos. No decide nada: si oculta un botón es por
comodidad, no por seguridad. La poda de secciones sensibles (costos, RUC,
cotizaciones) llega ya hecha desde la base.

**Backend.** Traduce HTTP a llamadas de stored procedure y el JWT al contexto
`(userId, tenantId, isSuperAdmin)`. No abre transacciones: un SP es una
operación de negocio atómica, y repartir la atomicidad entre dos capas es la
forma más segura de acabar con media operación aplicada.

**Base de datos.** Todo lo demás. Reglas, validación de tenant, permisos,
alcance organizacional, transiciones de estado, auditoría y el motor de
trazabilidad.

## El sobre

Un único formato de respuesta recorre las tres capas sin traducirse:

```jsonc
{ "ok": true,  "data": { … }, "meta": { "total": 42, "page": 1, "pages": 2 } }
{ "ok": false, "error": { "code": "BUSINESS_RULE", "message": "…", "field": "…" } }
```

`ok:false` no siempre es un error. Cerrar una OT con pendientes administrativos
devuelve `ok:false` **con los datos** que la interfaz necesita para pedir la
confirmación explícita que exige el cap. 31.2. Por eso el cliente distingue
entre endpoints que lanzan y endpoints que devuelven el sobre entero.
