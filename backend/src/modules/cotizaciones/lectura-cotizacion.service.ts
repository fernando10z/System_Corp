import { BadRequestException, Injectable, Logger } from "@nestjs/common";
import { CotizacionesRepository } from "./cotizaciones.repository";
import { textoDePdf } from "./lectura/texto-pdf";
import { interpretarCotizacion, type LecturaCotizacion } from "./lectura/interpretar-cotizacion";
import type { JwtPayload } from "../../common/types/jwt-payload.type";

/** 25 MB: el mismo techo que el cap. 28.3 fija para un PDF adjunto. */
const MAXIMO_BYTES = 26_214_400;

export interface ResultadoLectura extends LecturaCotizacion {
  archivo: string;
  paginas: number;
  paginasLeidas: number;
}

/**
 * Lectura asistida del PDF de la cotización.
 *
 * Es deliberadamente un paso APARTE de guardar: esta llamada no escribe nada,
 * ni en la base ni en el almacén. Devuelve lo que entendió del documento para
 * que una persona lo confirme o lo corrija, y recién al guardar se crea la
 * cotización y se archiva el PDF. Un importe mal leído que entrara solo al
 * histórico de costos contaminaría los reportes de años siguientes.
 */
@Injectable()
export class LecturaCotizacionService {
  private readonly logger = new Logger(LecturaCotizacionService.name);

  constructor(private readonly repo: CotizacionesRepository) {}

  async leerPdf(
    u: JwtPayload,
    archivo: { buffer: Buffer; filename: string; mimetype?: string },
  ): Promise<ResultadoLectura> {
    if (!archivo?.buffer?.length) {
      throw new BadRequestException({
        code: "VALIDATION",
        message: "No se recibió ningún archivo",
      });
    }
    if (archivo.buffer.length > MAXIMO_BYTES) {
      throw new BadRequestException({
        code: "VALIDATION",
        message: `El PDF supera los ${Math.round(MAXIMO_BYTES / 1024 / 1024)} MB`,
      });
    }
    // La comprobación real es la firma del archivo, no el nombre ni el tipo que
    // declara el navegador: los dos se pueden escribir a mano.
    if (archivo.buffer.subarray(0, 5).toString("latin1") !== "%PDF-") {
      throw new BadRequestException({
        code: "VALIDATION",
        message: "El archivo no es un PDF",
      });
    }

    // Los RUC del propio cliente sirven para descartar su RUC cuando aparece
    // como destinatario y quedarse con el del proveedor.
    let rucsPropios: string[] = [];
    try {
      rucsPropios = await this.repo.rucsPropios({
        userId: u.sub,
        tenantId: u.tenant_id,
        isSuperAdmin: u.is_super_admin,
      });
    } catch (e) {
      // Sin esa lista la lectura sigue funcionando, solo que con una regla menos.
      this.logger.warn(`No se pudieron leer los RUC propios: ${(e as Error).message}`);
    }

    let extraido: { texto: string; paginas: number; paginasLeidas: number };
    try {
      extraido = await textoDePdf(archivo.buffer);
    } catch (e) {
      this.logger.warn(`PDF ilegible (${archivo.filename}): ${(e as Error).message}`);
      return {
        archivo: archivo.filename,
        paginas: 0,
        paginasLeidas: 0,
        textoDetectado: false,
        campos: {},
        aviso:
          "No se pudo abrir el PDF: puede estar protegido con contraseña o dañado. " +
          "Escriba los datos a mano; el archivo se adjunta igual.",
      };
    }

    const lectura = interpretarCotizacion(extraido.texto, { rucsPropios });
    return {
      ...lectura,
      archivo: archivo.filename,
      paginas: extraido.paginas,
      paginasLeidas: extraido.paginasLeidas,
      aviso:
        lectura.aviso ??
        (extraido.paginasLeidas < extraido.paginas
          ? `Se leyeron las primeras ${extraido.paginasLeidas} de ${extraido.paginas} páginas.`
          : undefined),
    };
  }
}
