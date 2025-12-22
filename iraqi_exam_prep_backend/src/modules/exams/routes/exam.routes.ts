import { Router } from "express";
import {
  getQuestionsHandler,
  submitExamHandler,
  getResultsHandler,
} from "../controllers/exam.controller";
import { authenticate } from "../../../middlewares/authMiddleware";
import { validateResource } from "../../../middlewares/validateResource";
import { submitExamSchema } from "../dtos/exam.schema";

export const examRouter = Router();

examRouter.get("/:subject/questions", authenticate(), getQuestionsHandler);

examRouter.post(
  "/:subject/submit",
  authenticate(),
  validateResource(submitExamSchema),
  submitExamHandler,
);

examRouter.get("/results/list", authenticate(), getResultsHandler);
