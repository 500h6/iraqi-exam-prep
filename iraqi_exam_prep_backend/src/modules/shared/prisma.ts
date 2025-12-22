import { PrismaClient } from "@prisma/client";
import { logger } from "../../config/logger";

export const prisma = new PrismaClient({
  log: [
    { emit: "event", level: "query" },
    { emit: "event", level: "error" },
    { emit: "event", level: "warn" },
  ],
});

prisma.$on("error", (event) => logger.error(event, "Prisma error"));
prisma.$on("warn", (event) => logger.warn(event, "Prisma warning"));
prisma.$on("query", (event) => {
  if (process.env.NODE_ENV !== "production") {
    logger.debug({ query: event.query, params: event.params }, "Prisma query");
  }
});
