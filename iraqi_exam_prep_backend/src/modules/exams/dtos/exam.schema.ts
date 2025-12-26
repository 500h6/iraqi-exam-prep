import { z } from "zod";

export const submitExamSchema = z.object({
  params: z.object({
    subject: z.string(),
  }),
  body: z.object({
    answers: z.record(z.string(), z.number().int().min(0).max(9)),
  }),
});
