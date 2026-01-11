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

export const authService = {
  identify: async (data: {
    name: string;
    phone: string;
    branch?: string;
    city?: string;
  }) => {
    // Check if user exists by phone
    let user = await prisma.user.findUnique({
      where: { phone: data.phone },
    });

    if (user) {
      // Update name or other info if provided
      user = await prisma.user.update({
        where: { id: user.id },
        data: {
          name: data.name,
          branch: data.branch ?? user.branch,
          city: data.city ?? user.city,
        },
      });
    } else {
      // Create new user
      user = await prisma.user.create({
        data: {
          name: data.name,
          phone: data.phone,
          branch: data.branch,
          city: data.city,
          unlockedSubjects: [Subject.ARABIC],
        },
      });
    }

    const tokens = await buildTokens(user.id, user.role);
    return { user: toUserResponse(user), ...tokens };
  },

  register: async (data: {
    email?: string;
    password?: string;
    name: string;
    phone: string;
  }) => {
    const existing = await prisma.user.findUnique({
      where: { phone: data.phone },
    });
    if (existing) {
      throw new AppError("Phone number already in use", 409, "PHONE_EXISTS");
    }

    const passwordHash = data.password ? await hashPassword(data.password) : null;
    const user = await prisma.user.create({
      data: {
        email: data.email?.toLowerCase() ?? null,
        passwordHash,
        name: data.name,
        phone: data.phone,
        unlockedSubjects: [Subject.ARABIC],
      },
    });

    const tokens = await buildTokens(user.id, user.role);
    return { user: toUserResponse(user), ...tokens };
  },

  login: async (data: { email?: string; phone?: string; password?: string }) => {
    let user;
    if (data.email) {
      user = await prisma.user.findUnique({
        where: { email: data.email.toLowerCase() },
      });
    } else if (data.phone) {
      user = await prisma.user.findUnique({
        where: { phone: data.phone },
      });
    }

    if (!user) {
      throw new AppError("User not found", 401, "INVALID_CREDENTIALS");
    }

    // Only check password if user has one
    if (user.passwordHash && data.password) {
      const isValid = await comparePassword(data.password, user.passwordHash);
      if (!isValid) {
        throw new AppError("Invalid credentials", 401, "INVALID_CREDENTIALS");
      }
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
