-- Se ejecuta una sola vez, en el primer arranque del contenedor.
-- Las extensiones reales las instala db/migrations/00_extensions.sql; aquí sólo
-- se deja la base lista y el timezone alineado con el tenant por defecto.
ALTER DATABASE mip_dev SET timezone TO 'America/Lima';
