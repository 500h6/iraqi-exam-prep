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
        const TARGET_COUNT = 25;
        let result: ExamQuestion[] = [];

        if (normalizedSubject === Subject.ENGLISH) {
            // English Specific Distribution: 45% Grammar, 30% Functions, 25% Reading
            // For 25 questions: 11.25 -> 11 Grammar, 7.5 -> 8 Functions, 6.25 -> 6 Reading
            const quotas = [
                { category: 'grammar', count: 11 },
                { category: 'functions', count: 8 },
                { category: 'reading', count: 6 }
            ];

            quotas.forEach(quota => {
                const categoryWrong = this.shuffle(wrongQuestions.filter(q => q.category === quota.category));
                const categoryNew = this.shuffle(newQuestions.filter(q => q.category === quota.category));
                const categoryCorrect = this.shuffle(correctQuestions.filter(q => q.category === quota.category));

                let categorySelected: ExamQuestion[] = [];

                // Add Wrong
                categorySelected.push(...categoryWrong);

                // Fill with New
                if (categorySelected.length < quota.count) {
                    const needed = quota.count - categorySelected.length;
                    categorySelected.push(...categoryNew.slice(0, needed));
                }

                // Fill with Correct
                if (categorySelected.length < quota.count) {
                    const needed = quota.count - categorySelected.length;
                    categorySelected.push(...categoryCorrect.slice(0, needed));
                }

                result.push(...categorySelected.slice(0, quota.count));
            });

        } else {
            // Default Selection Logic
            // Priority: Wrong -> New -> Correct

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
        }

        // 7. Final Shuffle of the selected set
        const selectedQuestions = this.shuffle(result.slice(0, TARGET_COUNT));

        // 8. Mask sensitive data (correctAnswer & explanation) before returning to client
        return selectedQuestions.map(q => {
            const { correctAnswer, explanation, ...rest } = q;
            return rest as any;
        });
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
        });
    }

    async updateQuestion(id: string, data: any) {
        return prisma.examQuestion.update({
            where: { id },
            data
        });
    }

    async deleteQuestion(id: string) {
        return prisma.examQuestion.delete({
            where: { id }
        });
    }

    async getQuestionById(id: string) {
        return prisma.examQuestion.findUnique({
            where: { id }
        });
    }

    async listQuestions(subject?: string, limit: number = 25, search?: string) {
        const where: any = {};
        if (subject) {
            where.subject = subject as Subject;
        }
        if (search) {
            where.questionText = {
                contains: search,
                mode: 'insensitive'
            };
        }
        return prisma.examQuestion.findMany({
            where,
            take: limit,
            orderBy: { createdAt: 'desc' }
        });
    }
}

export const examService = new ExamService();
