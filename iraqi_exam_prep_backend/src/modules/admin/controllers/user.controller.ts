import { Request, Response } from "express";
import { prisma } from "../../shared/prisma";
import { sendSuccess } from "../../../utils/response";
import { AppError } from "../../../utils/appError";
import { getPhoneVariants } from "../../../utils/phoneUtils";

/**
 * List users with optional phone search
 * GET /admin/users?phone=07XXXXXXXX
 */
export const listUsersHandler = async (req: Request, res: Response) => {
    const { phone, limit = "20" } = req.query;

    let whereClause = {};

    if (phone && typeof phone === "string" && phone.trim()) {
        const phoneVariants = getPhoneVariants(phone.trim());
        whereClause = {
            phone: { in: phoneVariants },
        };
    }

    const users = await prisma.user.findMany({
        where: whereClause,
        take: parseInt(limit as string, 10),
        orderBy: { createdAt: "desc" },
        select: {
            id: true,
            name: true,
            phone: true,
            email: true,
            role: true,
            isPremium: true,
            createdAt: true,
        },
    });

    return sendSuccess(res, { data: { users } });
};

/**
 * Promote a user to ADMIN role
 * PATCH /admin/users/:id/promote
 */
export const promoteUserHandler = async (req: Request, res: Response) => {
    const { id } = req.params;

    if (!id) {
        throw new AppError("User ID is required", 400, "MISSING_ID");
    }

    const user = await prisma.user.findUnique({ where: { id } });

    if (!user) {
        throw new AppError("User not found", 404, "USER_NOT_FOUND");
    }

    if (user.role === "ADMIN") {
        throw new AppError("User is already an admin", 400, "ALREADY_ADMIN");
    }

    const updatedUser = await prisma.user.update({
        where: { id },
        data: { role: "ADMIN" },
        select: {
            id: true,
            name: true,
            phone: true,
            role: true,
        },
    });

    return sendSuccess(res, {
        data: { user: updatedUser },
        message: `User "${updatedUser.name}" promoted to ADMIN`,
    });
};

/**
 * Demote a user from ADMIN to STUDENT role
 * PATCH /admin/users/:id/demote
 */
export const demoteUserHandler = async (req: Request, res: Response) => {
    const { id } = req.params;

    if (!id) {
        throw new AppError("User ID is required", 400, "MISSING_ID");
    }

    // Optional: Prevent self-demotion if you want to be safe
    // if (req.user?.id === id) {
    //     throw new AppError("You cannot demote yourself", 400, "SELF_DEMOTION");
    // }

    const user = await prisma.user.findUnique({ where: { id } });

    if (!user) {
        throw new AppError("User not found", 404, "USER_NOT_FOUND");
    }

    if (user.role === "STUDENT") {
        throw new AppError("User is already a student", 400, "ALREADY_STUDENT");
    }

    const updatedUser = await prisma.user.update({
        where: { id },
        data: { role: "STUDENT" },
        select: {
            id: true,
            name: true,
            phone: true,
            role: true,
        },
    });

    return sendSuccess(res, {
        data: { user: updatedUser },
        message: `User "${updatedUser.name}" demoted to STUDENT`,
    });
};

/**
 * Manually activate user (Make Premium)
 * PATCH /admin/users/:id/activate
 */
export const activateUserHandler = async (req: Request, res: Response) => {
    const { id } = req.params;

    if (!id) {
        throw new AppError("User ID is required", 400, "MISSING_ID");
    }

    const user = await prisma.user.findUnique({ where: { id } });

    if (!user) {
        throw new AppError("User not found", 404, "USER_NOT_FOUND");
    }

    if (user.isPremium) {
        throw new AppError("User is already premium", 400, "ALREADY_PREMIUM");
    }

    const updatedUser = await prisma.user.update({
        where: { id },
        data: {
            isPremium: true,
            // set a far future date if premiumUntil is required for some checks
            premiumUntil: new Date(new Date().setFullYear(new Date().getFullYear() + 10)),
        },
        select: {
            id: true,
            name: true,
            phone: true,
            isPremium: true,
            role: true,
        },
    });

    return sendSuccess(res, {
        data: { user: updatedUser },
        message: `User "${updatedUser.name}" has been activated (Premium)`,
    });
};
