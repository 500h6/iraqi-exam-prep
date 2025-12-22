import { Response } from "express";

export interface ApiResponse<T> {
  success?: boolean;
  data?: T;
  message?: string;
  meta?: Record<string, unknown>;
}

export const sendSuccess = <T>(
  res: Response,
  payload: ApiResponse<T>,
  status = 200,
) => {
  return res.status(status).json({ success: true, ...payload });
};

export const sendError = (
  res: Response,
  message: string,
  status = 500,
  code?: string,
  details?: unknown,
) => {
  return res.status(status).json({
    success: false,
    error: {
      code,
      message,
      details,
    },
  });
};
