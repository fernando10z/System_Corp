import { registerAs } from "@nestjs/config";

/**
 * Reservado. NO hay conector SAP.
 *
 * El cap. 22.4 del documento deja pendientes los campos exactos de SOLPED, la
 * versión de SAP por cliente, las APIs disponibles y las autorizaciones; el
 * cap. 38 cierra con una regla de gobernanza explícita: una decisión pendiente
 * no se resuelve con un supuesto de desarrollador.
 *
 * El flujo administrativo funciona en modo manual y auditado. Esta configuración
 * existe para que el día que el cliente defina su entorno no haya que reabrir
 * el arranque de la aplicación.
 */
export default registerAs("sap", () => ({
  enabled: process.env.SAP_ENABLED === "true",
  baseUrl: process.env.SAP_BASE_URL,
  clientId: process.env.SAP_CLIENT_ID,
  clientSecret: process.env.SAP_CLIENT_SECRET,
}));
