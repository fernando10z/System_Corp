import { Module } from "@nestjs/common";
import { CierreController } from "./cierre.controller";
import { CierreService } from "./cierre.service";
import { CierreRepository } from "./cierre.repository";

@Module({ controllers: [CierreController], providers: [CierreService, CierreRepository] })
export class CierreModule {}
