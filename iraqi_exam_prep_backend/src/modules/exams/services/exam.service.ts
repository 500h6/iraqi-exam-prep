import { ExamQuestion, Subject } from "@prisma/client";
import { prisma } from "../../shared/prisma";
import { AppError } from "../../../utils/appError";

export class ExamService {
    private shuffle<T>(array: T[]): T[] {
        const shuffled = [...array];
        for (let i = shuffled.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [shuffled[i], shuffled[j]] = [shuffled[j]!, shuffled[i]!];
        }
        return shuffled;
    }

    async getQuestions(userId: string, subject: string): Promise<ExamQuestion[]> {
        // 1. Validate subject (convert to uppercase to match enum)
        const normalizedSubject = subject.toUpperCase();
        if (!Object.values(Subject).includes(normalizedSubject as Subject)) {
            throw new AppError("Invalid subject", 400, "INVALID_SUBJECT");
        }

        // 2. Fetch all active questions for the subject
        // TODO: For very large datasets (e.g. > 10k questions), we should optimize this 
        // to not fetch everything. For < 1k, fetching all ID/Status is acceptable for accurate history checks.
        const allQuestions = await prisma.examQuestion.findMany({
            where: {
                subject: normalizedSubject as Subject,
                isActive: true,
            },
        });

        if (allQuestions.length === 0) {
            return [];
        }

        // 3. Fetch user's past attempts for this subject
        const pastAttempts = await prisma.examAttempt.findMany({
            where: {
                userId,
                subject: normalizedSubject as Subject,
            },
            select: {
                answers: true,
            },
        });

        // 4. Analyze history
        const correctQuestionIds = new Set<string>();
        const wrongQuestionIds = new Set<string>();

        pastAttempts.forEach((attempt) => {
            const answers = attempt.answers as Record<string, number>;
            Object.entries(answers).forEach(([questionId, selectedOption]) => {
                const question = allQuestions.find((q) => q.id === questionId);
                if (question) {
                    if (question.correctAnswer === selectedOption) {
                        correctQuestionIds.add(questionId);
                        // If it was corrected later, remove from wrong list
                        wrongQuestionIds.delete(questionId);
                    } else {
                        wrongQuestionIds.add(questionId);
                    }
                }
            });
        });

        // Refine sets
        const actuallyCorrectIds = correctQuestionIds;
        const actuallyWrongIds = new Set(
            [...wrongQuestionIds].filter((id) => !actuallyCorrectIds.has(id))
        );

        // 5. Categorize questions
        const wrongQuestions: ExamQuestion[] = [];
        const newQuestions: ExamQuestion[] = [];
        const correctQuestions: ExamQuestion[] = [];

        allQuestions.forEach((q) => {
            if (actuallyWrongIds.has(q.id)) {
                wrongQuestions.push(q);
            } else if (actuallyCorrectIds.has(q.id)) {
                correctQuestions.push(q);
            } else {
                newQuestions.push(q);
            }
        });

        // 6. Selection Logic (Target 25)
        // Priority: Wrong -> New -> Correct
        const result: ExamQuestion[] = [];
        const TARGET_COUNT = 25;

        // Add Wrong (Shuffled)
        const shuffledWrong = this.shuffle(wrongQuestions);
        result.push(...shuffledWrong);

        // Fill with New (Shuffled)
        if (result.length < TARGET_COUNT) {
            const needed = TARGET_COUNT - result.length;
            const shuffledNew = this.shuffle(newQuestions);
            result.push(...shuffledNew.slice(0, needed));
        }

        // Fill with Correct (Shuffled) - Review
        if (result.length < TARGET_COUNT) {
            const needed = TARGET_COUNT - result.length;
            const shuffledCorrect = this.shuffle(correctQuestions);
            result.push(...shuffledCorrect.slice(0, needed));
        }

        // 7. Final Shuffle of the selected set
        return this.shuffle(result.slice(0, TARGET_COUNT));
    }

    async submitExam(
        userId: string,
        subject: string,
        answers: Record<string, number>
    ) {
        // 1. Validate subject (convert to uppercase to match enum)
        const normalizedSubject = subject.toUpperCase();
        if (!Object.values(Subject).includes(normalizedSubject as Subject)) {
            throw new AppError("Invalid subject", 400, "INVALID_SUBJECT");
        }

        const questions = await prisma.examQuestion.findMany({
            where: {
                id: { in: Object.keys(answers) },
            },
        });

        let score = 0;
        let correctAnswers = 0;
        let wrongAnswers = 0;

        questions.forEach((q) => {
            const userAnswer = answers[q.id];
            if (userAnswer === q.correctAnswer) {
                score++;
                correctAnswers++;
            } else {
                wrongAnswers++;
            }
        });

        const totalQuestions = questions.length;
        const percentage =
            totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
        const passed = percentage >= 50;

        // Transaction to save attempt and result ensures consistency
        const result = await prisma.$transaction(async (tx) => {
            const attempt = await tx.examAttempt.create({
                data: {
                    userId,
                    subject: normalizedSubject as Subject,
                    answers,
                    completedAt: new Date(),
                },
            });

            const examResult = await tx.examResult.create({
                data: {
                    attemptId: attempt.id,
                    userId,
                    subject: normalizedSubject as Subject,
                    score,
                    totalQuestions,
                    correctAnswers,
                    wrongAnswers,
                    percentage,
                    passed,
                    completedAt: new Date(),
                },
            });

            return examResult;
        });

        return result;
    }

    async listResults(userId: string, limit: number) {
        return prisma.examResult.findMany({
            where: { userId },
            orderBy: { completedAt: "desc" },
            take: limit,
            include: {
                attempt: true,
            }
        });
    }

    async createQuestion(data: any) {
        return prisma.examQuestion.create({
            data
        })
    }

    async listQuestions(subject?: string, limit: number = 25) {
        const where: any = {};
        if (subject) {
            where.subject = subject as Subject;
        }
        return prisma.examQuestion.findMany({
            where,
            take: limit
        })
    }
}

export const examService = new ExamService();
