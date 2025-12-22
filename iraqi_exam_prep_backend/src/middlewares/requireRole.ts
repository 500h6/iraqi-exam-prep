import { NextFunction, Response } from "express";
import { Role } from "@prisma/client";
import { AppError } from "../utils/appError";
import { AuthenticatedRequest } from "./authMiddleware";

export const requireRole = (roles: Role[]) => {
  return (req: AuthenticatedRequest, _res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new AppError("Authentication required", 401, "UNAUTHORIZED");
    }
    if (!roles.includes(req.user.role as Role)) {
      throw new AppError("Forbidden", 403, "FORBIDDEN");
    }
    return next();
  };
};
