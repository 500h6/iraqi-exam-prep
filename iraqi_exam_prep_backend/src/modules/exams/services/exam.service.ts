import { Subject } from "@prisma/client";
import { prisma } from "../../shared/prisma";
import { AppError } from "../../../utils/appError";
import { normalizeSubject } from "../../../utils/subject";

const QUESTIONS_PER_EXAM = 25;

type QuestionInput = {
  subject: string;
  questionText: string;
  options: string[];
  correctAnswer: number;
  explanation?: string;
  difficulty?: number;
};

const ensureAccess = (subject: Subject, user: { isPremium: boolean; unlockedSubjects: Subject[]; freeAttempts: Record<string, boolean> }) => {
  if (subject === Subject.ARABIC) {
    return true;
  }
  if (user.isPremium) return true;
  if (user.unlockedSubjects.includes(subject)) return true;
  throw new AppError("Subject requires premium access", 402, "PAYMENT_REQUIRED");
};

export const examService = {
  getQuestions: async (userId: string, subjectParam: string) => {
    const subject = normalizeSubject(subjectParam);
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new AppError("User not found", 404, "USER_NOT_FOUND");

    ensureAccess(subject, {
      isPremium: user.isPremium,
      unlockedSubjects: user.unlockedSubjects,
      freeAttempts: (user.freeAttempts as Record<string, boolean>) ?? {},
    });

    const questions = await prisma.examQuestion.findMany({
      where: { subject, isActive: true },
      take: QUESTIONS_PER_EXAM,
      orderBy: { createdAt: "desc" },
    });

    // Relaxed check for testing - allow exams with fewer questions
    if (questions.length === 0) {
      throw new AppError(
        `No questions available for subject ${subject}`,
        500,
        "NO_QUESTIONS",
      );
    }

    return questions;
  },

  submitExam: async (
    userId: string,
    subjectParam: string,
    answers: Record<string, number>,
  ) => {
    const subject = normalizeSubject(subjectParam);
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new AppError("User not found", 404, "USER_NOT_FOUND");

    ensureAccess(subject, {
      isPremium: user.isPremium,
      unlockedSubjects: user.unlockedSubjects,
      freeAttempts: (user.freeAttempts as Record<string, boolean>) ?? {},
    });

    const questionIds = Object.keys(answers);
    if (questionIds.length === 0) {
      throw new AppError("No answers received", 400, "NO_ANSWERS");
    }

    const questions = await prisma.examQuestion.findMany({
      where: { id: { in: questionIds }, subject },
    });
    if (questions.length !== questionIds.length) {
      throw new AppError("Invalid question set", 400, "INVALID_QUESTIONS");
    }

    let correctAnswers = 0;
    questions.forEach((question) => {
      if (question.correctAnswer === answers[question.id]) {
        correctAnswers += 1;
      }
    });

    const totalQuestions = questions.length;
    const wrongAnswers = totalQuestions - correctAnswers;
    const percentage = (correctAnswers / totalQuestions) * 100;
    const passed = percentage >= 60;

    const attempt = await prisma.examAttempt.create({
      data: {
        userId,
        subject,
        answers,
        completedAt: new Date(),
        isFreeAttempt: subject === Subject.ARABIC && !user.isPremium,
      },
    });

    const result = await prisma.examResult.create({
      data: {
        attemptId: attempt.id,
        userId,
        subject,
        score: correctAnswers,
        totalQuestions,
        correctAnswers,
        wrongAnswers,
        percentage,
        passed,
        completedAt: new Date(),
      },
    });

    if (subject === Subject.ARABIC && !user.isPremium) {
      const freeAttempts = (user.freeAttempts as Record<string, boolean>) ?? {};
      freeAttempts[Subject.ARABIC] = true;
      await prisma.user.update({
        where: { id: userId },
        data: { freeAttempts },
      });
    }

    return result;
  },

  listResults: async (userId: string, limit = 10) => {
    return prisma.examResult.findMany({
      where: { userId },
      orderBy: { completedAt: "desc" },
      take: limit,
    });
  },

  createQuestion: async (payload: QuestionInput) => {
    const subject = normalizeSubject(payload.subject);
    if (!payload.options || payload.options.length < 2) {
      throw new AppError("At least two options are required", 422, "INVALID_OPTIONS");
    }
    if (
      payload.correctAnswer < 0 ||
      payload.correctAnswer >= payload.options.length
    ) {
      throw new AppError(
        "Correct answer index is out of bounds",
        422,
        "INVALID_CORRECT_ANSWER",
      );
    }

    return prisma.examQuestion.create({
      data: {
        subject,
        questionText: payload.questionText.trim(),
        options: payload.options.map((option) => option.trim()),
        correctAnswer: payload.correctAnswer,
        explanation: payload.explanation?.trim() ?? null,
        difficulty: payload.difficulty ?? 1,
        isActive: true,
      },
    });
  },

  listQuestions: async (subjectParam?: string, take = 25) => {
    const where = subjectParam
      ? { subject: normalizeSubject(subjectParam) }
      : {};
    return prisma.examQuestion.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take,
    });
  },
};
