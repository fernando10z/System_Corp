/**
 * Entrar cuando el límite de intentos por minuto ya está agotado.
 *
 * MIP limita los intentos de login por IP a propósito, y la propia suite los
 * gasta: el bloque de seguridad falla contraseñas adrede y cada bloque entra
 * con varias cuentas. Correrlos seguidos choca con ese límite, que es justo lo
 * que debe pasar.
 *
 * La respuesta correcta es esperar a que la ventana se renueve, no aflojar la
 * protección para que las pruebas sean cómodas: eso dejaría el sistema abierto
 * a fuerza bruta por conveniencia del equipo de QA.
 */
export async function conEsperaSi429(peticion, { intentos = 4, esperaMs = 20_000 } = {}) {
  let r;
  for (let i = 1; i <= intentos; i++) {
    r = await peticion();
    if (r?.status !== 429) return r;
    console.log(`    … límite de intentos de login alcanzado; esperando ${esperaMs / 1000} s (${i}/${intentos})`);
    await new Promise((listo) => setTimeout(listo, esperaMs));
  }
  return r;
}
