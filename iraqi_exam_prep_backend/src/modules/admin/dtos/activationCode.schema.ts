import { z } from "zod";

export const generateCodeSchema = z.object({
    body: z.object({
        subjects: z.array(z.string()).optional().default([]),
        unlockAll: z.boolean().optional().default(false),
        maxUses: z.number().int().min(1).optional().default(1),
        expiresInDays: z.number().int().min(1).optional(),
        count: z.number().int().min(1).max(100).optional().default(1),
    }),
});

export const listCodesSchema = z.object({
    query: z.object({
        status: z.enum(["active", "used", "revoked"]).optional(),
        subject: z.string().optional(),
        limit: z.string().regex(/^\d+$/).optional(),
        offset: z.string().regex(/^\d+$/).optional(),
    }),
});

export const codeIdParamSchema = z.object({
    params: z.object({
        id: z.string().uuid(),
    }),
});
