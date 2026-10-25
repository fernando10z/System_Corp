import { afterAll, describe, expect, it } from "vitest";
import { mkdtempSync, rmSync } from "node:fs";
import { readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ConfigService } from "@nestjs/config";
import { DiscoService } from "../../src/infrastructure/storage/disco.service";
import { firmarEnlace, verificarEnlace } from "../../src/infrastructure/storage/url-firmada";

const SECRETO = "s".repeat(32);
const raiz = mkdtempSync(join(tmpdir(), "mip-disco-"));
afterAll(() => rmSync(raiz, { recursive: true, force: true }));

function disco(vars: Record<string, string> = {}) {
  const todo: Record<string, string> = {
    STORAGE_FS_ROOT: raiz,
    STORAGE_URL_SECRET: SECRETO,
    ...vars,
  };
  return new DiscoService({ get: (k: string) => todo[k] } as unknown as ConfigService);
}

/** Saca el token de la URL que recibe el navegador. */
const tokenDe = (url: string) => new URL(url, "http://x").searchParams.get("t") ?? "";

describe("enlace firmado", () => {
  const ahora = 1_000_000;

  it("devuelve lo firmado mientras no caduca", () => {
    const t = firmarEnlace(SECRETO, {
      k: "a/b/c.pdf",
      n: "c.pdf",
      m: "application/pdf",
      e: ahora + 60,
    });
    expect(verificarEnlace(SECRETO, t, ahora)).toMatchObject({
      k: "a/b/c.pdf",
      m: "application/pdf",
    });
  });

  it("rechaza un enlace caducado", () => {
    const t = firmarEnlace(SECRETO, { k: "a", e: ahora - 1 });
    expect(verificarEnlace(SECRETO, t, ahora)).toBeNull();
  });

  it("rechaza un enlace alterado o firmado con otro secreto", () => {
    const t = firmarEnlace(SECRETO, { k: "tenant-a/x", e: ahora + 60 });
    const [, sig] = t.split(".");
    const otroCuerpo = Buffer.from(JSON.stringify({ k: "tenant-b/x", e: ahora + 60 })).toString(
      "base64url",
    );
    expect(verificarEnlace(SECRETO, `${otroCuerpo}.${sig}`, ahora)).toBeNull();
    expect(verificarEnlace("o".repeat(32), t, ahora)).toBeNull();
    expect(verificarEnlace(SECRETO, "", ahora)).toBeNull();
    expect(verificarEnlace(SECRETO, `${t}.extra`, ahora)).toBeNull();
  });
});

describe("almacén en disco", () => {
  it("guarda, entrega por enlace y elimina", async () => {
    const d = disco();
    await d.onModuleInit();
    const clave = d.construirClave("tenant", null, "cotización 1.pdf");
    await d.subir(clave, Buffer.from("%PDF-prueba"));
    expect(await readFile(join(raiz, clave), "utf8")).toBe("%PDF-prueba");

    const url = await d.urlDescarga(clave, { nombre: "cotización 1.pdf", mime: "application/pdf" });
    expect(url.startsWith("/api/archivos?t=")).toBe(true);
    const abierto = await d.abrir(tokenDe(url));
    expect(abierto?.bytes).toBe(11);
    expect(abierto?.contenido.n).toBe("cotización 1.pdf");
    abierto?.flujo.destroy();

    await d.eliminar(clave);
    expect(await d.abrir(tokenDe(url))).toBeNull();
  });

  it("no deja salir una clave de la raíz", async () => {
    const d = disco();
    await expect(d.subir("../fuera.txt", Buffer.from("x"))).rejects.toThrow(/fuera de la raíz/);
    const url = await d.urlDescarga("../../etc/passwd");
    expect(await d.abrir(tokenDe(url))).toBeNull();
  });

  it("no arranca sin secreto suficiente ni con una raíz relativa", () => {
    expect(() => disco({ STORAGE_URL_SECRET: "corto" })).toThrow(/STORAGE_URL_SECRET/);
    expect(() => disco({ STORAGE_FS_ROOT: "adjuntos" })).toThrow(/STORAGE_FS_ROOT/);
  });
});
