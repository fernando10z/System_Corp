import { Injectable, Logger, OnModuleDestroy } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import Redis from "ioredis";

/**
 * Redis se usa para la whitelist de refresh tokens: un refresh sólo vale si su
 * `jti` sigue en la lista, lo que permite revocar sesiones sin esperar a que
 * caduque el token.
 *
 * Si Redis no está disponible el login sigue funcionando; lo que se pierde es la
 * capacidad de revocar. El servicio degrada en lugar de tumbar la aplicación,
 * pero lo deja claro en el log.
 */
@Injectable()
export class RedisService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private readonly client: Redis;
  private readonly prefix: string;
  private disponible = true;

  constructor(config: ConfigService) {
    this.prefix = config.get<string>("REDIS_PREFIX") ?? "mip:";
    this.client = new Redis(config.get<string>("REDIS_URL") ?? "redis://localhost:6383", {
      maxRetriesPerRequest: 2,
      lazyConnect: true,
      retryStrategy: (veces) => Math.min(veces * 500, 5000),
    });
    this.client.on("error", (e) => {
      if (this.disponible) {
        this.disponible = false;
        this.logger.warn(`Redis no disponible (${e.message}). Las sesiones no podrán revocarse.`);
      }
    });
    this.client.on("ready", () => {
      this.disponible = true;
      this.logger.log("Redis conectado");
    });
    void this.client.connect().catch(() => undefined);
  }

  async guardarRefresh(jti: string, userId: string, ttlSegundos: number): Promise<void> {
    try {
      await this.client.set(`${this.prefix}refresh:${jti}`, userId, "EX", ttlSegundos);
    } catch {
      /* degradación silenciosa: ya se avisó en el log al perder la conexión */
    }
  }

  async refreshVigente(jti: string): Promise<boolean> {
    try {
      return (await this.client.exists(`${this.prefix}refresh:${jti}`)) === 1;
    } catch {
      // Sin Redis no se puede comprobar la whitelist. Se acepta el token válido
      // criptográficamente: negar todo dejaría a los usuarios fuera por una
      // caída de la caché.
      return true;
    }
  }

  async revocarRefresh(jti: string): Promise<void> {
    try {
      await this.client.del(`${this.prefix}refresh:${jti}`);
    } catch {
      /* ídem */
    }
  }

  async revocarTodosDe(userId: string): Promise<number> {
    try {
      const claves = await this.client.keys(`${this.prefix}refresh:*`);
      let n = 0;
      for (const k of claves) {
        if ((await this.client.get(k)) === userId) {
          await this.client.del(k);
          n++;
        }
      }
      return n;
    } catch {
      return 0;
    }
  }

  async ping(): Promise<boolean> {
    try {
      return (await this.client.ping()) === "PONG";
    } catch {
      return false;
    }
  }

  async onModuleDestroy() {
    await this.client.quit().catch(() => undefined);
  }
}
