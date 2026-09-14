import { Module } from "@nestjs/common";
import { ConversacionesController } from "./conversaciones.controller";
import { ConversacionesService } from "./conversaciones.service";
import { ConversacionesRepository } from "./conversaciones.repository";

@Module({
  controllers: [ConversacionesController],
  providers: [ConversacionesService, ConversacionesRepository],
})
export class ConversacionesModule {}
