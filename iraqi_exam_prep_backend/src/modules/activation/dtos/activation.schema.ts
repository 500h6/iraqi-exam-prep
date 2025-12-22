import { z } from "zod";

export const activationCodeSchema = z.object({
  body: z.object({
    code: z.string().min(6),
  }),
});
