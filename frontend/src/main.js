import { createApp } from "vue";
import App from "./App.vue";
import router from "./router/index.js";
import { initThemeEarly } from "./shared/composables/useTheme.js";
import "sweetalert2/dist/sweetalert2.min.css";
import "./styles/globals.css";
import "./styles/dialogos.css";

// Se aplica el tema antes de montar para evitar el destello de fondo claro.
initThemeEarly();

createApp(App).use(router).mount("#app");
