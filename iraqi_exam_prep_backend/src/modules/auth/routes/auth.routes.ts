import { Router } from "express";
import {
  loginWithPhoneHandler,
  verifyOtpHandler,
  completeProfileHandler,
  meHandler,
  refreshHandler,
  logoutHandler,
} from "../controllers/auth.controller";
import {
  loginSchema,
  verifyOtpSchema,
  completeProfileSchema,
  refreshSchema,
} from "../dtos/auth.schema";
import { validateResource } from "../../../middlewares/validateResource";
import { authenticate } from "../../../middlewares/authMiddleware";
import { authRateLimiter } from "../../../middlewares/rateLimiter";

export const authRouter = Router();

authRouter.post(
  "/login",
  authRateLimiter,
  validateResource(loginSchema),
  loginWithPhoneHandler,
);

authRouter.post(
  "/verify-otp",
  authRateLimiter,
  validateResource(verifyOtpSchema),
  verifyOtpHandler,
);

authRouter.post(
  "/complete-profile",
  authenticate(),
  validateResource(completeProfileSchema),
  completeProfileHandler,
);

authRouter.post(
  "/refresh",
  validateResource(refreshSchema),
  refreshHandler,
);

authRouter.get("/me", authenticate(), meHandler);

authRouter.post("/logout", logoutHandler);
