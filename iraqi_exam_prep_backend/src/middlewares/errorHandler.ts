import { NextFunction, Request, Response } from "express";
import { AppError } from "../utils/appError";
import { logger } from "../config/logger";

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  if (res.headersSent) {
    return;
  }

  const status = err instanceof AppError ? err.statusCode : 500;
  const message =
    err instanceof AppError && err.message
      ? err.message
      : "Internal server error";

  logger.error({ err }, "Unhandled error");

  res.status(status).json({
    success: false,
    error: {
      message,
      code: err instanceof AppError ? err.code : "INTERNAL_SERVER_ERROR",
      details: err instanceof AppError ? err.details : undefined,
    },
  });
};
