import { Subject } from "@prisma/client";
import { prisma } from "../../shared/prisma";
import { AppError } from "../../../utils/appError";
import crypto from "crypto";

interface GenerateCodeOptions {
    subjects: Subject[];
    unlockAll?: boolean;
    maxUses?: number;
    expiresInDays?: number;
    createdById?: string;
}

interface ListCodesOptions {
    status?: "active" | "used" | "revoked";
    subject?: Subject;
    limit?: number;
    offset?: number;
}

export const activationCodeService = {
    /**
     * Generate a single activation code
     */
    generateCode: async (options: GenerateCodeOptions) => {
        const code = generateRandomCode();
        const expiresAt = options.expiresInDays
            ? new Date(Date.now() + options.expiresInDays * 24 * 60 * 60 * 1000)
            : null;

        return prisma.activationCode.create({
            data: {
                code,
                subjects: options.subjects,
                unlockAll: options.unlockAll ?? false,
                maxUses: options.maxUses ?? 1,
                expiresAt,
                createdById: options.createdById ?? null,
                status: "active",
            },
        });
    },

    /**
     * Generate multiple activation codes at once
     */
    generateBulkCodes: async (count: number, options: GenerateCodeOptions) => {
        const codes: string[] = [];
        for (let i = 0; i < count; i++) {
            codes.push(generateRandomCode());
        }

        const expiresAt = options.expiresInDays
            ? new Date(Date.now() + options.expiresInDays * 24 * 60 * 60 * 1000)
            : null;

        const data = codes.map((code) => ({
            code,
            subjects: options.subjects,
            unlockAll: options.unlockAll ?? false,
            maxUses: options.maxUses ?? 1,
            expiresAt,
            createdById: options.createdById ?? null,
            status: "active",
        }));

        await prisma.activationCode.createMany({ data });

        return prisma.activationCode.findMany({
            where: { code: { in: codes } },
            orderBy: { createdAt: "desc" },
        });
    },

    /**
     * List all activation codes with optional filters
     */
    listCodes: async (options: ListCodesOptions = {}) => {
        const where: any = {};
        if (options.status) where.status = options.status;
        if (options.subject) where.subjects = { has: options.subject };

        return prisma.activationCode.findMany({
            where,
            take: options.limit ?? 50,
            skip: options.offset ?? 0,
            orderBy: { createdAt: "desc" },
            include: {
                createdBy: { select: { id: true, name: true, email: true } },
                redeemedBy: { select: { id: true, name: true, email: true } },
            },
        });
    },

    /**
     * Revoke an activation code
     */
    revokeCode: async (codeId: string) => {
        const existing = await prisma.activationCode.findUnique({
            where: { id: codeId },
        });
        if (!existing) {
            throw new AppError("Activation code not found", 404, "CODE_NOT_FOUND");
        }
        return prisma.activationCode.update({
            where: { id: codeId },
            data: { status: "revoked" },
        });
    },

    /**
     * Get a single code by ID
     */
    getCodeById: async (codeId: string) => {
        const code = await prisma.activationCode.findUnique({
            where: { id: codeId },
            include: {
                createdBy: { select: { id: true, name: true, email: true } },
                redeemedBy: { select: { id: true, name: true, email: true } },
            },
        });
        if (!code) {
            throw new AppError("Activation code not found", 404, "CODE_NOT_FOUND");
        }
        return code;
    },
};

/**
 * Generate a random 12-character alphanumeric code
 * Format: XXXX-XXXX-XXXX (e.g., A1B2-C3D4-E5F6)
 */
function generateRandomCode(): string {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // Removed confusing chars (0,O,1,I)
    let code = "";
    for (let i = 0; i < 12; i++) {
        if (i > 0 && i % 4 === 0) code += "-";
        code += chars[crypto.randomInt(chars.length)];
    }
    return code;
}
