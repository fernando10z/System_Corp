import { Module } from "@nestjs/common";
import { OtController } from "./ot.controller";
import { OtService } from "./ot.service";
import { OtRepository } from "./ot.repository";

@Module({
  controllers: [OtController],
  providers: [OtService, OtRepository],
  exports: [OtService, OtRepository],
})
export class OtModule {}
