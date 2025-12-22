import { app } from "./app";
import { env } from "./config/env";
import { logger } from "./config/logger";
import { prisma } from "./modules/shared/prisma";

const server = app.listen(env.port, '0.0.0.0' as any, () => {
  logger.info(`Server running on port ${env.port}`);
});

const shutdown = async () => {
  logger.info("Shutting down server...");
  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
};

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
