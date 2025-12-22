import { Request, Response } from "express";
import { examService } from "../services/exam.service";
import { AuthenticatedRequest } from "../../../middlewares/authMiddleware";
import { sendSuccess } from "../../../utils/response";
import { AppError } from "../../../utils/appError";

export const getQuestionsHandler = async (
  req: AuthenticatedRequest,
  res: Response,
) => {
  const subject = req.params.subject;
  if (!subject) {
    throw new AppError("Subject is required", 400, "SUBJECT_REQUIRED");
  }
  const questions = await examService.getQuestions(req.user!.id, subject);
  return sendSuccess(res, {
    data: { questions },
    meta: { count: questions.length },
  });
};

export const submitExamHandler = async (
  req: AuthenticatedRequest,
  res: Response,
) => {
  const subject = req.params.subject;
  if (!subject) {
    throw new AppError("Subject is required", 400, "SUBJECT_REQUIRED");
  }
  const result = await examService.submitExam(
    req.user!.id,
    subject,
    req.body.answers,
  );
  return sendSuccess(res, { data: { result } });
};

export const getResultsHandler = async (
  req: AuthenticatedRequest,
  res: Response,
) => {
  const limit = req.query.limit ? Number(req.query.limit) : 10;
  const results = await examService.listResults(req.user!.id, limit);
  return sendSuccess(res, { data: { results } });
};
