import "express-async-errors";
import express from "express";
import cors from "cors";
import compression from "compression";
import helmet from "helmet";
import morgan from "morgan";
import cookieParser from "cookie-parser";
import { env } from "./config/env";
import { requestLogger } from "./middlewares/requestLogger";
import { errorHandler } from "./middlewares/errorHandler";
import { globalRateLimiter } from "./middlewares/rateLimiter";
import { authRouter } from "./modules/auth/routes/auth.routes";
import { activationRouter } from "./modules/activation/routes/activation.routes";
import { examRouter } from "./modules/exams/routes/exam.routes";
import { logger } from "./config/logger";
import { adminRouter } from "./modules/admin/routes/admin.routes";

export const app = express();

app.use(helmet());
app.use(
  cors({
    origin: true, // Allow all origins for development
    credentials: true,
  }),
);
app.use(compression());
app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(globalRateLimiter);
app.use(requestLogger);
app.use(
  morgan("tiny", {
    stream: {
      write: (message: string) => logger.info(message.trim()),
    },
    skip: () => env.nodeEnv === "test",
  }),
);

app.get("/healthz", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.use("/api/v1/auth", authRouter);
app.use("/api/v1/activation", activationRouter);
app.use("/api/v1/exams", examRouter);
app.use("/api/v1/admin", adminRouter);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: { message: `Route ${req.path} not found`, code: "NOT_FOUND" },
  });
});

app.use(errorHandler);
