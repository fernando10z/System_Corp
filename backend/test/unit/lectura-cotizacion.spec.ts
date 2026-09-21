import { describe, expect, it } from "vitest";
import {
  construirPdf,
  desdeTexto,
  COTIZACION_TIPICA,
  COTIZACION_DOLARES,
} from "../fixtures/cotizacion-pdf";
import { textoDePdf } from "../../src/modules/cotizaciones/lectura/texto-pdf";
import {
  aNumero,
  interpretarCotizacion,
  rucValido,
} from "../../src/modules/cotizaciones/lectura/interpretar-cotizacion";

/** Atajo: PDF -> campos leídos, que es el camino completo que usa el endpoint. */
async function leer(texto: string, rucsPropios: string[] = []) {
  const { texto: extraido } = await textoDePdf(construirPdf(desdeTexto(texto)));
  return interpretarCotizacion(extraido, { rucsPropios });
}

describe("importes escritos de distintas maneras", () => {
  it("lee el formato peruano y el europeo", () => {
    expect(aNumero("2,850.00")).toBe(2850);
    expect(aNumero("1.250,00")).toBe(1250);
    expect(aNumero("S/ 4,661.00")).toBe(4661);
    expect(aNumero("US$ 1.680,50")).toBe(1680.5);
    expect(aNumero("420")).toBe(420);
    expect(aNumero("sin numeros")).toBeNull();
  });
});

describe("RUC", () => {
  it("valida el dígito verificador", () => {
    expect(rucValido("20512345671")).toBe(true);
    expect(rucValido("20512345670")).toBe(false); // mismo RUC, dígito cambiado
    expect(rucValido("12345678901")).toBe(false); // no empieza por 10/15/16/17/20
    expect(rucValido("205123456")).toBe(false);
  });
});

describe("cotización peruana típica", () => {
  it("saca proveedor, número, fecha, total y condiciones", async () => {
    const { textoDetectado, campos } = await leer(COTIZACION_TIPICA);

    expect(textoDetectado).toBe(true);
    expect(campos.proveedorRuc?.valor).toBe("20512345671");
    expect(campos.proveedorNombre?.valor).toContain("MECANICA INDUSTRIAL DEL SUR");
    expect(campos.numeroCotizacion?.valor).toBe("COT-2026-0187");
    expect(campos.fecha?.valor).toBe("2026-03-14");
    expect(campos.moneda?.valor).toBe("PEN");
    expect(campos.plazoOfrecidoDias?.valor).toBe(12);
    expect(campos.validezDias?.valor).toBe(30);
  });

  it("toma el TOTAL, no el subtotal ni el IGV ni la línea más cara", async () => {
    const { campos } = await leer(COTIZACION_TIPICA);
    expect(campos.monto?.valor).toBe(4661);
    expect(campos.monto?.confianza).toBe("alta");
  });

  it('no toma el RUC del cliente aunque vaya en la línea de abajo de "Señores"', async () => {
    // Sin pasarle los RUC propios: la única pista es que ese RUC cuelga del
    // renglón que nombra al destinatario.
    const { campos } = await leer(COTIZACION_TIPICA);
    expect(campos.proveedorRuc?.valor).toBe("20512345671");
    expect(campos.proveedorRuc?.confianza).toBe("alta");
  });

  it("descarta el RUC del propio cliente y se queda con el del proveedor", async () => {
    const { campos } = await leer(COTIZACION_TIPICA, ["20601234565"]);
    expect(campos.proveedorRuc?.valor).toBe("20512345671");
    // Con el del cliente descartado queda un único candidato: eso sube la confianza.
    expect(campos.proveedorRuc?.confianza).toBe("alta");
  });

  it("respalda cada campo con la línea de la que salió", async () => {
    const { campos } = await leer(COTIZACION_TIPICA);
    expect(campos.monto?.evidencia).toContain("4,661.00");
    expect(campos.fecha?.evidencia).toMatch(/14\/03\/2026/);
  });
});

describe("proforma en dólares con coma decimal", () => {
  it("entiende la otra convención de números y la otra moneda", async () => {
    const { campos } = await leer(COTIZACION_DOLARES);

    expect(campos.proveedorNombre?.valor).toContain("HYDRAULIC PARTS PERU");
    expect(campos.proveedorRuc?.valor).toBe("20548899177");
    expect(campos.numeroCotizacion?.valor).toBe("PRF-88/2026");
    expect(campos.fecha?.valor).toBe("2026-04-02");
    expect(campos.monto?.valor).toBe(1680.5);
    expect(campos.moneda?.valor).toBe("USD");
    expect(campos.plazoOfrecidoDias?.valor).toBe(20);
    expect(campos.validezDias?.valor).toBe(15);
  });
});

describe("cuando no hay nada que leer", () => {
  it("avisa de que es un escaneo en vez de inventar datos", async () => {
    const r = await leer("Cotizacion");
    expect(r.textoDetectado).toBe(false);
    expect(r.campos).toEqual({});
    expect(r.aviso).toMatch(/escaneo|foto/i);
  });

  it("marca como dudoso el importe cuando no hay línea de total", () => {
    const r = interpretarCotizacion(
      [
        "TALLER ELECTROMECANICO ANDINO S.R.L.",
        "RUC: 20512345671",
        "Servicio de mantenimiento correctivo de compresor",
        "Incluye repuestos, mano de obra y pruebas de operacion",
        "S/ 1,890.00",
      ].join("\n"),
    );
    expect(r.campos.monto?.valor).toBe(1890);
    expect(r.campos.monto?.confianza).toBe("media");
    expect(r.aviso).toBeUndefined();
  });

  it("no confunde un teléfono con un importe", () => {
    const r = interpretarCotizacion(
      [
        "SERVICIOS INDUSTRIALES LIMA S.A.C.",
        "RUC: 20512345671",
        "Telf. 4528890",
        "Reparacion de bomba centrifuga",
        "TOTAL S/ 980.00",
      ].join("\n"),
    );
    expect(r.campos.monto?.valor).toBe(980);
  });
});
