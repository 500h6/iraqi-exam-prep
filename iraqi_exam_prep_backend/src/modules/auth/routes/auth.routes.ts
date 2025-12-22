import { Router } from "express";
import {
  loginHandler,
  meHandler,
  refreshHandler,
  registerHandler,
  logoutHandler,
} from "../controllers/auth.controller";
import {
  loginSchema,
  refreshSchema,
  registerSchema,
} from "../dtos/auth.schema";
import { validateResource } from "../../../middlewares/validateResource";
import { authenticate } from "../../../middlewares/authMiddleware";
import { authRateLimiter } from "../../../middlewares/rateLimiter";

export const authRouter = Router();

authRouter.post(
  "/register",
  authRateLimiter,
  validateResource(registerSchema),
  registerHandler,
);

authRouter.post(
  "/login",
  authRateLimiter,
  validateResource(loginSchema),
  loginHandler,
);

authRouter.post(
  "/refresh",
  validateResource(refreshSchema),
  refreshHandler,
);

authRouter.get("/me", authenticate(), meHandler);

authRouter.post("/logout", logoutHandler);
