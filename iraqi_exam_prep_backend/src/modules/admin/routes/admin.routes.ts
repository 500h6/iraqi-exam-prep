import { Router } from "express";
import { Role } from "@prisma/client";
import { authenticate } from "../../../middlewares/authMiddleware";
import { requireRole } from "../../../middlewares/requireRole";
import { validateResource } from "../../../middlewares/validateResource";
import {
  createQuestionSchema,
  listQuestionsSchema,
} from "../dtos/question.schema";
import {
  createQuestionHandler,
  listQuestionsHandler,
  updateQuestionHandler,
  deleteQuestionHandler,
  getQuestionHandler,
} from "../controllers/question.controller";
import {
  generateCodeSchema,
  listCodesSchema,
  codeIdParamSchema,
} from "../dtos/activationCode.schema";
import {
  generateCodeHandler,
  listCodesHandler,
  revokeCodeHandler,
  getCodeHandler,
} from "../controllers/activationCode.controller";
import {
  listUsersHandler,
  promoteUserHandler,
  demoteUserHandler,
  activateUserHandler,
  deactivateUserHandler,
} from "../controllers/user.controller";
import { sendNotificationHandler } from "../controllers/notification.controller";

export const adminRouter = Router();

// Notification Management
adminRouter.post(
  "/notifications/send",
  authenticate(),
  requireRole([Role.ADMIN]),
  sendNotificationHandler,
);

// Question Management
adminRouter.post(
  "/questions",
  authenticate(),
  requireRole([Role.ADMIN]),
  validateResource(createQuestionSchema),
  createQuestionHandler,
);

adminRouter.get(
  "/questions",
  authenticate(),
  requireRole([Role.ADMIN]),
  validateResource(listQuestionsSchema),
  listQuestionsHandler,
);

adminRouter.get(
  "/questions/:id",
  authenticate(),
  requireRole([Role.ADMIN]),
  getQuestionHandler,
);

adminRouter.patch(
  "/questions/:id",
  authenticate(),
  requireRole([Role.ADMIN]),
  updateQuestionHandler,
);

adminRouter.delete(
  "/questions/:id",
  authenticate(),
  requireRole([Role.ADMIN]),
  deleteQuestionHandler,
);

// Activation Code Management
adminRouter.post(
  "/activation-codes",
  authenticate(),
  requireRole([Role.ADMIN]),
  validateResource(generateCodeSchema),
  generateCodeHandler,
);

adminRouter.get(
  "/activation-codes",
  authenticate(),
  requireRole([Role.ADMIN]),
  validateResource(listCodesSchema),
  listCodesHandler,
);

adminRouter.get(
  "/activation-codes/:id",
  authenticate(),
  requireRole([Role.ADMIN]),
  validateResource(codeIdParamSchema),
  getCodeHandler,
);

adminRouter.patch(
  "/activation-codes/:id/revoke",
  authenticate(),
  requireRole([Role.ADMIN]),
  validateResource(codeIdParamSchema),
  revokeCodeHandler,
);

// User Management
adminRouter.get(
  "/users",
  authenticate(),
  requireRole([Role.ADMIN]),
  listUsersHandler,
);

adminRouter.patch(
  "/users/:id/promote",
  authenticate(),
  requireRole([Role.ADMIN]),
  promoteUserHandler,
);

adminRouter.patch(
  "/users/:id/demote",
  authenticate(),
  requireRole([Role.ADMIN]),
  demoteUserHandler,
);

adminRouter.patch(
  "/users/:id/activate",
  authenticate(),
  requireRole([Role.ADMIN]),
  activateUserHandler,
);

adminRouter.patch(
  "/users/:id/deactivate",
  authenticate(),
  requireRole([Role.ADMIN]),
  deactivateUserHandler,
);
