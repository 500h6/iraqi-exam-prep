import { Response } from "express";
import { AuthenticatedRequest } from "../../../middlewares/authMiddleware";
import { sendSuccess } from "../../../utils/response";
import { activationCodeService } from "../services/activationCode.service";
import { Subject } from "@prisma/client";

export const generateCodeHandler = async (
    req: AuthenticatedRequest,
    res: Response
) => {
    const { subjects, unlockAll, maxUses, expiresInDays, count } = req.body;

    // Normalize subjects to uppercase
    const normalizedSubjects = (subjects as string[])?.map(
        (s) => s.toUpperCase() as Subject
    ) ?? [];

    if (count && count > 1) {
        // Bulk generation
        const codes = await activationCodeService.generateBulkCodes(count, {
            subjects: normalizedSubjects,
            unlockAll,
            maxUses,
            expiresInDays,
            createdById: req.user!.id,
        });
        return sendSuccess(res, {
            data: { codes },
            meta: { count: codes.length },
        });
    }

    // Single code generation
    const code = await activationCodeService.generateCode({
        subjects: normalizedSubjects,
        unlockAll,
        maxUses,
        expiresInDays,
        createdById: req.user!.id,
    });
    return sendSuccess(res, { data: { code } });
};

export const listCodesHandler = async (
    req: AuthenticatedRequest,
    res: Response
) => {
    const { status, subject, limit, offset } = req.query;

    const codes = await activationCodeService.listCodes({
        ...(status && { status: status as "active" | "used" | "revoked" }),
        ...(subject && { subject: (subject as string).toUpperCase() as Subject }),
        ...(limit && { limit: Number(limit) }),
        ...(offset && { offset: Number(offset) }),
    });

    return sendSuccess(res, {
        data: { codes },
        meta: { count: codes.length },
    });
};

export const revokeCodeHandler = async (
    req: AuthenticatedRequest,
    res: Response
) => {
    const { id } = req.params;
    if (!id) throw new Error("ID is required");
    const code = await activationCodeService.revokeCode(id);
    return sendSuccess(res, { data: { code } });
};

export const getCodeHandler = async (
    req: AuthenticatedRequest,
    res: Response
) => {
    const { id } = req.params;
    if (!id) throw new Error("ID is required");
    const code = await activationCodeService.getCodeById(id);
    return sendSuccess(res, { data: { code } });
};
