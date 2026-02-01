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

  const code = err instanceof AppError ? err.code : "INTERNAL_SERVER_ERROR";

  logger.error(
    {
      err: {
        message: err.message,
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
        code,
        status
      }
    },
    "Unhandled error"
  );

  res.status(status).json({
    success: false,
    error: {
      message,
      code,
      details: err instanceof AppError ? err.details : (process.env.NODE_ENV === 'development' ? err.stack : undefined),
    },
  });
};
