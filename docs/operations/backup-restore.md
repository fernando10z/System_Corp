# Respaldo y restauración

## Respaldo

```bash
bash db/scripts/backup.sh                 # → db/backups/mip-<fecha>.dump
DB_NAME=mip_prod bash db/scripts/backup.sh
```

Usa `pg_dump -Fc` (formato comprimido), que permite restaurar selectivamente.

Se respalda **toda** la base, incluidos `core.ot_evento` y `audit.audit_log`.
Son las tablas que más crecen y las que menos se pueden perder: sin ellas, el
árbol de trazabilidad pierde su hilo de eventos.

## Restauración

```bash
bash db/scripts/restore.sh db/backups/mip-2026-08-22.dump
```

El script pide confirmación explícita: restaurar sobrescribe.

## Reconstruir un entorno de desarrollo

```bash
ALLOW_RESET=yes bash db/scripts/reset-dev.sh
```

Borra los cuatro schemas y los reconstruye desde las migraciones. Exige
`ALLOW_RESET=yes` porque es demasiado fácil ejecutarlo apuntando sin querer a una
base que importa.

## Qué NO está en el respaldo de la base

Los **adjuntos**. Los bytes viven en MinIO/S3; la base sólo guarda la
`storage_key`. Un respaldo de la base sin respaldo del bucket deja OT con
referencias a archivos que ya no existen.

```bash
mc mirror --overwrite local/mip-adjuntos /destino/respaldo/adjuntos
```

## Retención

Pendiente de definir por cliente (cap. 38: tiempo de retención, residencia de
datos, antivirus y borrado legal). Hasta que exista esa política, **nada se
purga**: es coherente con el ADR 0005, y cuando llegue el momento será un proceso
explícito y auditado, no un `DELETE` en un cron.
