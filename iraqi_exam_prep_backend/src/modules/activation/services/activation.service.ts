import { Subject } from "@prisma/client";
import { prisma } from "../../shared/prisma";
import { AppError } from "../../../utils/appError";

export const activationService = {
  checkStatus: async (userId: string) => {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new AppError("User not found", 404, "USER_NOT_FOUND");
    return {
      isPremium: user.isPremium,
      unlockedSubjects: user.unlockedSubjects,
      premiumUntil: user.premiumUntil,
    };
  },

  validateCode: async (userId: string, code: string) => {
    return await prisma.$transaction(async (tx) => {
      const activation = await tx.activationCode.findUnique({
        where: { code },
      });

      if (!activation) {
        throw new AppError("Invalid activation code", 404, "CODE_NOT_FOUND");
      }
      if (activation.status !== "active") {
        throw new AppError("Activation code is not active", 400, "CODE_INACTIVE");
      }
      if (activation.expiresAt && activation.expiresAt < new Date()) {
        throw new AppError("Activation code expired", 400, "CODE_EXPIRED");
      }
      if (activation.uses >= activation.maxUses) {
        throw new AppError("Activation code already used", 400, "CODE_USED");
      }

      const user = await tx.user.findUnique({ where: { id: userId } });
      if (!user) throw new AppError("User not found", 404, "USER_NOT_FOUND");

      const unlocked = new Set<Subject>(user.unlockedSubjects);
      activation.subjects.forEach((s) => unlocked.add(s));
      if (activation.unlockAll) {
        unlocked.add(Subject.ARABIC);
        unlocked.add(Subject.ENGLISH);
        unlocked.add(Subject.COMPUTER);
      }

      const premiumUntil = new Date();
      premiumUntil.setMonth(premiumUntil.getMonth() + 1);

      const updatedUser = await tx.user.update({
        where: { id: userId },
        data: {
          unlockedSubjects: Array.from(unlocked),
          isPremium: true,
          premiumUntil,
        },
      });

      const newUses = activation.uses + 1;
      await tx.activationCode.update({
        where: { id: activation.id },
        data: {
          uses: newUses,
          redeemedById: userId,
          status: newUses >= activation.maxUses ? "used" : "active",
        },
      });

      return updatedUser;
    });
  },
};
