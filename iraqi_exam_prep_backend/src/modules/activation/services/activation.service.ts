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
    const activation = await prisma.activationCode.findUnique({
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

    const user = await prisma.user.findUnique({ where: { id: userId } });
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

    const updated = await prisma.user.update({
      where: { id: userId },
      data: {
        unlockedSubjects: Array.from(unlocked),
        isPremium: true,
        premiumUntil,
      },
    });

    await prisma.activationCode.update({
      where: { code },
      data: {
        uses: activation.uses + 1,
        redeemedById: userId,
        status: activation.uses + 1 >= activation.maxUses ? "used" : "active",
      },
    });

    return updated;
  },
};
