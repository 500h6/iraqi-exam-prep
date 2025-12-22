import pino, { LoggerOptions } from "pino";
import { env } from "./env";

const baseOptions: LoggerOptions = {
  level: env.nodeEnv === "production" ? "info" : "debug",
};

if (env.nodeEnv !== "production") {
  baseOptions.transport = {
    target: "pino-pretty",
    options: {
      colorize: true,
      translateTime: "SYS:standard",
    },
  };
}

export const logger = pino(baseOptions);
