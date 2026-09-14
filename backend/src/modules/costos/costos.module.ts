import { Module } from "@nestjs/common";
import { CostosController } from "./costos.controller";
import { CostosService } from "./costos.service";
import { CostosRepository } from "./costos.repository";

@Module({ controllers: [CostosController], providers: [CostosService, CostosRepository] })
export class CostosModule {}
