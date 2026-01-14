import { Request, Response } from "express";
import { authService } from "../services/auth.service";
import { sendSuccess } from "../../../utils/response";
import { AuthenticatedRequest } from "../../../middlewares/authMiddleware";
import { AppError } from "../../../utils/appError";
import {
  clearRefreshTokenCookie,
  getRefreshTokenFromCookies,
  setRefreshTokenCookie,
} from "../utils/tokenCookie";

const selectRefreshToken = (req: Request) =>
  req.body.refreshToken ?? getRefreshTokenFromCookies(req.cookies);

export const identifyHandler = async (req: Request, res: Response) => {
  const { name, phone, branch, city } = req.body;
  const result = await authService.identify({ name, phone, branch, city });
  setRefreshTokenCookie(res, result.refreshToken);
  return sendSuccess(res, {
    data: {
      token: result.accessToken,
      refreshToken: result.refreshToken,
      user: result.user,
    },
  });
};

export const registerHandler = async (req: Request, res: Response) => {
  const { name, email, password, phone } = req.body;
  const result = await authService.register({ name, email, password, phone });
  setRefreshTokenCookie(res, result.refreshToken);
  return sendSuccess(res, {
    data: {
      token: result.accessToken,
      refreshToken: result.refreshToken,
      user: result.user,
    },
  }, 201);
};

export const loginWithPhoneHandler = async (req: Request, res: Response) => {
  const { phone } = req.body;
  const result = await authService.requestOtp(phone);
  return sendSuccess(res, { data: result });
};

export const verifyOtpHandler = async (req: Request, res: Response) => {
  const { phone, code } = req.body;
  const result = await authService.verifyOtp(phone, code);
  setRefreshTokenCookie(res, result.refreshToken);
  return sendSuccess(res, {
    data: {
      token: result.accessToken,
      refreshToken: result.refreshToken,
      user: result.user,
    },
  });
};

export const completeProfileHandler = async (req: AuthenticatedRequest, res: Response) => {
  const { name } = req.body;
  const user = await authService.completeProfile(req.user!.id, name);
  return sendSuccess(res, { data: { user } });
};

export const refreshHandler = async (req: Request, res: Response) => {
  const refreshToken = selectRefreshToken(req);
  if (!refreshToken) {
    throw new AppError("Refresh token missing", 401, "UNAUTHORIZED");
  }
  const result = await authService.refresh(refreshToken);
  setRefreshTokenCookie(res, result.refreshToken);
  return sendSuccess(res, {
    data: {
      token: result.accessToken,
      refreshToken: result.refreshToken,
      user: result.user,
    },
  });
};

export const meHandler = async (req: AuthenticatedRequest, res: Response) => {
  const user = await authService.getProfile(req.user!.id);
  return sendSuccess(res, { data: { user } });
};

export const logoutHandler = async (req: Request, res: Response) => {
  const refreshToken = selectRefreshToken(req);
  await authService.logout(refreshToken);
  clearRefreshTokenCookie(res);
  return sendSuccess(res, { data: { loggedOut: true } });
};
