import { Role, Subject, User } from "@prisma/client";
import { createHash } from "crypto";
import { prisma } from "../../shared/prisma";
import { telegramService } from "../../notifications/telegram.service";
import { hashPassword, comparePassword } from "../../../utils/password";
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
} from "../../../utils/jwt";
import { AppError } from "../../../utils/appError";
import { normalizePhoneNumber, getPhoneVariants } from "../../../utils/phoneUtils";

const hashToken = (token: string) =>
  createHash("sha256").update(token).digest("hex");

const buildTokens = async (userId: string, role: Role) => {
  const accessToken = signAccessToken({ sub: userId, role });
  const refreshToken = signRefreshToken({ sub: userId, role });
  await prisma.refreshToken.create({
    data: {
      userId,
      tokenHash: hashToken(refreshToken),
      expiresAt: new Date(
        Date.now() + 1000 * 60 * 60 * 24 * 14, // 14 days fallback
      ),
    },
  });
  return { accessToken, refreshToken };
};

export const toUserResponse = (user: User) => ({
  id: user.id,
  email: user.email,
  name: user.name,
  phone: user.phone,
  branch: user.branch,
  city: user.city,
  role: user.role,
  isPremium: user.isPremium,
  unlockedSubjects: user.unlockedSubjects,
  createdAt: user.createdAt,
});

// Simple in-memory OTP store (Use Redis in production)
const otpStore = new Map<string, { code: string; expires: number }>();

export const authService = {
  requestOtp: async (phone: string) => {
    // Normalize phone to standard format
    const normalizedPhone = normalizePhoneNumber(phone);
    const phoneVariants = getPhoneVariants(phone);

    // 1. Check if user exists with any phone variant
    const user = await prisma.user.findFirst({
      where: {
        phone: { in: phoneVariants },
      },
    });

    if (!user || !user.telegramChatId) {
      return { linked: false };
    }

    // 2. Generate OTP
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expires = Date.now() + 5 * 60 * 1000; // 5 minutes

    // 3. Store OTP
    // Store with normalized phone for consistent lookup
    otpStore.set(normalizedPhone, { code, expires });

    // 4. Send via Telegram
    const sent = await telegramService.sendOtp(user.phone!, code);
    if (!sent) {
      throw new AppError("Failed to send OTP via Telegram", 500, "TELEGRAM_ERROR");
    }

    return { linked: true };
  },

  verifyOtp: async (phone: string, code: string) => {
    const normalizedPhone = normalizePhoneNumber(phone);
    const phoneVariants = getPhoneVariants(phone);

    // 1. Verify OTP (using normalized phone)
    const stored = otpStore.get(normalizedPhone);
    if (!stored) {
      throw new AppError("OTP expired or not requested", 400, "OTP_EXPIRED");
    }

    if (Date.now() > stored.expires) {
      otpStore.delete(normalizedPhone);
      throw new AppError("OTP expired", 400, "OTP_EXPIRED");
    }

    if (stored.code !== code) {
      throw new AppError("Invalid OTP", 400, "INVALID_OTP");
    }

    otpStore.delete(normalizedPhone); // Consume OTP

    // 2. Find User (try all phone variants)
    let user = await prisma.user.findFirst({
      where: { phone: { in: phoneVariants } },
    });

    if (!user) {
      // Should not happen if requestOtp checks existance, but strictly speaking
      // requestOtp only checks if LINKED.
      // If user linked via Bot but deleted from DB (edge case),
      // or if we allow OTP for unlinked? No, requestOtp returns linked:false.
      throw new AppError("User not found", 404, "USER_NOT_FOUND");
    }

    const tokens = await buildTokens(user.id, user.role);
    return { user: toUserResponse(user), ...tokens };
  },

  completeProfile: async (userId: string, name: string) => {
    const user = await prisma.user.update({
      where: { id: userId },
      data: { name }
    });
    return toUserResponse(user);
  },

  getProfile: async (userId: string) => {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) throw new AppError("User not found", 404, "USER_NOT_FOUND");
    return toUserResponse(user);
  },

  logout: async (refreshToken?: string) => {
    if (!refreshToken) return;
    const tokenHash = hashToken(refreshToken);
    await prisma.refreshToken.updateMany({
      where: { tokenHash },
      data: { revoked: true },
    });
  },

  refresh: async (refreshToken: string) => {
    const payload = verifyRefreshToken(refreshToken);
    const tokenHash = hashToken(refreshToken);
    const stored = await prisma.refreshToken.findUnique({
      where: { tokenHash },
    });
    if (!stored || stored.revoked) {
      throw new AppError("Refresh token invalid", 401, "UNAUTHORIZED");
    }
    const user = await prisma.user.findUnique({
      where: { id: payload.sub },
    });
    if (!user) {
      throw new AppError("User not found", 404, "USER_NOT_FOUND");
    }
    await prisma.refreshToken.delete({ where: { tokenHash } });
    const tokens = await buildTokens(user.id, user.role);
    return { user: toUserResponse(user), ...tokens };
  },
};
