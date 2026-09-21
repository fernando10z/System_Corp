import type { AuthenticatedRequest } from "./authenticated-request.type";

/**
 * @fastify/multipart amplía FastifyRequest con `file()`, pero esa ampliación no
 * llega al tipo de Nest. Se declara aquí, una sola vez, usando la forma real
 * del plugin en lugar de que cada controlador invente la suya.
 */
export interface ParteSubida {
  filename: string;
  mimetype: string;
  toBuffer: () => Promise<Buffer>;
  fields: Record<string, unknown>;
}

export type PeticionMultipart = AuthenticatedRequest & {
  file: () => Promise<ParteSubida | undefined>;
};

/** Los campos del formulario llegan como `{ value }`; un campo ausente es undefined. */
export function campoDe(parte: ParteSubida, nombre: string): string | undefined {
  const f = parte.fields?.[nombre] as { value?: unknown } | undefined;
  return typeof f?.value === "string" ? f.value : undefined;
}
