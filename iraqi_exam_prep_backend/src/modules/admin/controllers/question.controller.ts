import { Response } from "express";
import { AuthenticatedRequest } from "../../../middlewares/authMiddleware";
import { examService } from "../../exams/services/exam.service";
import { sendSuccess } from "../../../utils/response";

export const createQuestionHandler = async (
  req: AuthenticatedRequest,
  res: Response,
) => {
  const question = await examService.createQuestion(req.body);
  return sendSuccess(
    res,
    {
      data: { question },
    },
    201,
  );
};

export const listQuestionsHandler = async (
  req: AuthenticatedRequest,
  res: Response,
) => {
  const subject = req.query.subject as string | undefined;
  const limitParam = req.query.limit as string | undefined;
  const limit = limitParam ? Number(limitParam) : 25;
  const questions = await examService.listQuestions(subject, limit);
  return sendSuccess(res, {
    data: { questions },
    meta: { count: questions.length },
  });
};
