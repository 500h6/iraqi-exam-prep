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
} from "../controllers/question.controller";

export const adminRouter = Router();

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
