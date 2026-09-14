import { ref } from "vue";

const CLAVE = "mip_sidebar_plegada";
const plegada = ref(localStorage.getItem(CLAVE) === "1");

export function useSidebar() {
  function alternar() {
    plegada.value = !plegada.value;
    localStorage.setItem(CLAVE, plegada.value ? "1" : "0");
  }
  return { plegada, alternar };
}
