import { Module } from "@nestjs/common";
import { AdjuntosController } from "./adjuntos.controller";
import { AdjuntosService } from "./adjuntos.service";
import { AdjuntosRepository } from "./adjuntos.repository";

@Module({
  controllers: [AdjuntosController],
  providers: [AdjuntosService, AdjuntosRepository],
})
export class AdjuntosModule {}
