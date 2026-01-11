import { z } from "zod";

export const identifySchema = z.object({
  body: z.object({
    name: z.string().min(2).max(100),
    phone: z.string().min(10).max(15),
    branch: z.string().optional(),
    city: z.string().optional(),
  }),
});

export const registerSchema = z.object({
  body: z.object({
    name: z.string().min(2).max(100),
    email: z.string().email().optional(),
    password: z.string().min(6).optional(),
    phone: z.string(),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email().optional(),
    phone: z.string().optional(),
    password: z.string().min(6).optional(),
  }),
});

export const refreshSchema = z.object({
  body: z.object({
    refreshToken: z.string(),
  }),
});
