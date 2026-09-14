import { Module } from "@nestjs/common";
import { AdministrativoController } from "./administrativo.controller";
import { AdministrativoService } from "./administrativo.service";
import { AdministrativoRepository } from "./administrativo.repository";

@Module({
  controllers: [AdministrativoController],
  providers: [AdministrativoService, AdministrativoRepository],
})
export class AdministrativoModule {}
