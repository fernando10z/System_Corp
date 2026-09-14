import { SetMetadata } from "@nestjs/common";
export const ROLES_KEY = "roles";
/**
 * Filtro grueso por rol. El filtro FINO es el permiso, y lo aplica el SP dentro
 * de la base: aunque alguien se saltara esto, la operación seguiría rechazada.
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
