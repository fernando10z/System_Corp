import { ref } from "vue";
import { THEME_KEY } from "../config/api.config.js";

const tema = ref("light");

/** Se llama antes de montar la app para evitar el destello de tema al cargar. */
export function initThemeEarly() {
  const guardado = localStorage.getItem(THEME_KEY);
  const preferido = window.matchMedia?.("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  tema.value = guardado ?? preferido;
  document.documentElement.setAttribute("data-theme", tema.value);
}

export function useTheme() {
  function alternar() {
    tema.value = tema.value === "dark" ? "light" : "dark";
    document.documentElement.setAttribute("data-theme", tema.value);
    localStorage.setItem(THEME_KEY, tema.value);
  }
  return { tema, alternar };
}
