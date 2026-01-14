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
    phone: z.string().min(10).max(25), // Allow spaces: "+964 781 001 1034"
  }),
});

export const verifyOtpSchema = z.object({
  body: z.object({
    phone: z.string().min(10).max(25), // Allow spaces
    code: z.string().length(6),
  }),
});

export const completeProfileSchema = z.object({
  body: z.object({
    name: z.string().min(2).max(100),
  }),
});

export const refreshSchema = z.object({
  body: z.object({
    refreshToken: z.string(),
  }),
});
