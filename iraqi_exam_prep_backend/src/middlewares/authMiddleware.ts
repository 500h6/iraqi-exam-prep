import { NextFunction, Request, Response } from "express";
import { verifyAccessToken } from "../utils/jwt";
import { AppError } from "../utils/appError";
import { prisma } from "../modules/shared/prisma";

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    role: string;
  };
}

export const authenticate =
  (optional = false) =>
  async (req: AuthenticatedRequest, _res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      if (optional) return next();
      throw new AppError("Authentication required", 401, "UNAUTHORIZED");
    }

    try {
      const parts = authHeader.split(" ");
      if (parts.length !== 2) {
        throw new AppError("Invalid authorization header", 401, "UNAUTHORIZED");
      }
      const token = parts[1];
      if (!token) {
        throw new AppError("Invalid authorization header", 401, "UNAUTHORIZED");
      }
      const payload = verifyAccessToken(token);
      const user = await prisma.user.findUnique({
        where: { id: payload.sub },
      });
      if (!user) {
        throw new AppError("User not found", 401, "UNAUTHORIZED");
      }

      req.user = { id: user.id, role: user.role };
      return next();
    } catch (error) {
      if (optional) return next();
      throw new AppError("Invalid or expired token", 401, "UNAUTHORIZED", error);
    }
  };
