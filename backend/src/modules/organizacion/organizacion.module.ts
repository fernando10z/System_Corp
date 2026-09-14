import { Module } from "@nestjs/common";
import { OrganizacionController } from "./organizacion.controller";
import { OrganizacionService } from "./organizacion.service";
import { OrganizacionRepository } from "./organizacion.repository";

@Module({
  controllers: [OrganizacionController],
  providers: [OrganizacionService, OrganizacionRepository],
})
export class OrganizacionModule {}
