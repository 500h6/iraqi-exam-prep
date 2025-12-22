import { z } from "zod";

const subjectEnum = z.enum(["ARABIC", "ENGLISH", "COMPUTER"]);

export const createQuestionSchema = z
  .object({
    body: z.object({
      subject: subjectEnum,
      questionText: z.string().min(10),
      options: z.array(z.string().min(1)).min(2),
      correctAnswer: z.number().int().min(0),
      explanation: z.string().optional(),
      difficulty: z.number().int().min(1).max(5).optional(),
    }),
  })
  .superRefine((data, ctx) => {
    const { options, correctAnswer } = data.body;
    if (correctAnswer >= options.length) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "Correct answer index must match one of the options",
        path: ["body", "correctAnswer"],
      });
    }
  });

export const listQuestionsSchema = z.object({
  query: z.object({
    subject: subjectEnum.optional(),
    limit: z
      .string()
      .transform((value) => Number(value))
      .refine((value) => Number.isNaN(value) === false, "Limit must be numeric")
      .optional(),
  }),
});
