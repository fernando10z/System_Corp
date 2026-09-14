import { Module } from "@nestjs/common";
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from "@nestjs/core";
import { ConfigModule } from "@nestjs/config";
import { JwtModule } from "@nestjs/jwt";
import { ScheduleModule } from "@nestjs/schedule";
import { ThrottlerGuard, ThrottlerModule } from "@nestjs/throttler";
import { join } from "node:path";

import {
  appConfig, databaseConfig, jwtConfig, mailConfig, redisConfig, sapConfig, storageConfig, validateEnv,
} from "./config";

import { LoggerModule } from "./infrastructure/logger/logger.module";
import { DatabaseModule } from "./infrastructure/database/database.module";
import { CacheModule } from "./infrastructure/cache/cache.module";
import { StorageModule } from "./infrastructure/storage/storage.module";
import { MailModule } from "./infrastructure/mail/mail.module";
import { HealthModule } from "./infrastructure/health/health.module";

import { JwtAuthGuard } from "./common/guards/jwt-auth.guard";
import { RolesGuard } from "./common/guards/roles.guard";
import { GlobalExceptionFilter } from "./common/filters/global-exception.filter";
import { RequestIdInterceptor } from "./common/interceptors/request-id.interceptor";

import { AuthModule } from "./modules/auth/auth.module";
import { OrganizacionModule } from "./modules/organizacion/organizacion.module";
import { UsuariosModule } from "./modules/usuarios/usuarios.module";
import { RolesModule } from "./modules/roles/roles.module";
import { CatalogosModule } from "./modules/catalogos/catalogos.module";
import { SolicitudesModule } from "./modules/solicitudes/solicitudes.module";
import { OtModule } from "./modules/ot/ot.module";
import { DiagnosticosModule } from "./modules/diagnosticos/diagnosticos.module";
import { CotizacionesModule } from "./modules/cotizaciones/cotizaciones.module";
import { EjecucionModule } from "./modules/ejecucion/ejecucion.module";
import { CierreModule } from "./modules/cierre/cierre.module";
import { AdministrativoModule } from "./modules/administrativo/administrativo.module";
import { ConversacionesModule } from "./modules/conversaciones/conversaciones.module";
import { AdjuntosModule } from "./modules/adjuntos/adjuntos.module";
import { CostosModule } from "./modules/costos/costos.module";
import { NotificacionesModule } from "./modules/notificaciones/notificaciones.module";
import { AuditoriaModule } from "./modules/auditoria/auditoria.module";
import { DashboardsModule } from "./modules/dashboards/dashboards.module";
import { ReportesModule } from "./modules/reportes/reportes.module";
import { ConfiguracionModule } from "./modules/configuracion/configuracion.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [join(process.cwd(), ".env")],
      load: [appConfig, databaseConfig, jwtConfig, redisConfig, storageConfig, mailConfig, sapConfig],
      validate: validateEnv,
    }),
    JwtModule.register({ global: true }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([
      {
        ttl: Number(process.env.RATE_LIMIT_TTL_MS ?? 60_000),
        limit: Number(process.env.RATE_LIMIT_MAX ?? 100),
      },
    ]),

    LoggerModule,
    DatabaseModule,
    CacheModule,
    StorageModule,
    MailModule,
    HealthModule,

    // Los 20 módulos de negocio, en el mismo orden que las migraciones del
    // schema `app`. Cada uno es una carpeta autocontenida.
    AuthModule,
    OrganizacionModule,
    UsuariosModule,
    RolesModule,
    CatalogosModule,
    SolicitudesModule,
    OtModule,
    DiagnosticosModule,
    CotizacionesModule,
    EjecucionModule,
    CierreModule,
    AdministrativoModule,
    ConversacionesModule,
    AdjuntosModule,
    CostosModule,
    NotificacionesModule,
    AuditoriaModule,
    DashboardsModule,
    ReportesModule,
    ConfiguracionModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    // Autenticación global: se sale con @Public().
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    // Roles opt-in: sólo actúa donde hay @Roles(). El permiso fino lo aplica el SP.
    { provide: APP_GUARD, useClass: RolesGuard },
    { provide: APP_FILTER, useClass: GlobalExceptionFilter },
    { provide: APP_INTERCEPTOR, useClass: RequestIdInterceptor },
  ],
})
export class AppModule {}
