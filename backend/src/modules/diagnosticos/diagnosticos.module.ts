import { Module } from "@nestjs/common";
import { DiagnosticosController } from "./diagnosticos.controller";
import { DiagnosticosService } from "./diagnosticos.service";
import { DiagnosticosRepository } from "./diagnosticos.repository";

@Module({
  controllers: [DiagnosticosController],
  providers: [DiagnosticosService, DiagnosticosRepository],
})
export class DiagnosticosModule {}
