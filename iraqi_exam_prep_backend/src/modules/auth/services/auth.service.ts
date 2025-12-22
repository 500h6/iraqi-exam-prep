import { Role, Subject, User } from "@prisma/client";
import { createHash } from "crypto";
import { prisma } from "../../shared/prisma";
import { hashPassword, comparePassword } from "../../../utils/password";
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
} from "../../../utils/jwt";
import { AppError } from "../../../utils/appError";

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

const toUserResponse = (user: User) => ({
  id: user.id,
  email: user.email,
  name: user.name,
  phone: user.phone,
  role: user.role,
  isPremium: user.isPremium,
  unlockedSubjects: user.unlockedSubjects,
  createdAt: user.createdAt,
});

export const authService = {
  register: async (data: {
    email: string;
    password: string;
    name: string;
    phone?: string;
  }) => {
    const existing = await prisma.user.findUnique({
      where: { email: data.email.toLowerCase() },
    });
    if (existing) {
      throw new AppError("Email already in use", 409, "EMAIL_EXISTS");
    }
    const passwordHash = await hashPassword(data.password);
    const user = await prisma.user.create({
      data: {
        email: data.email.toLowerCase(),
        passwordHash,
        name: data.name,
        phone: data.phone ?? null,
        unlockedSubjects: [Subject.ARABIC], // free subject unlocked by default
      },
    });

    const tokens = await buildTokens(user.id, user.role);
    return { user: toUserResponse(user), ...tokens };
  },

  login: async (data: { email: string; password: string }) => {
    const user = await prisma.user.findUnique({
      where: { email: data.email.toLowerCase() },
    });
    if (!user) {
      throw new AppError("Invalid credentials", 401, "INVALID_CREDENTIALS");
    }
    const isValid = await comparePassword(data.password, user.passwordHash);
    if (!isValid) {
      throw new AppError("Invalid credentials", 401, "INVALID_CREDENTIALS");
    }

    const tokens = await buildTokens(user.id, user.role);
    return { user: toUserResponse(user), ...tokens };
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
};
