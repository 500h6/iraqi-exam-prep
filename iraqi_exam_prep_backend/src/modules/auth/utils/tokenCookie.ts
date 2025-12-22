import { CookieOptions, Response } from "express";
import { env } from "../../../config/env";

const REFRESH_COOKIE_NAME = env.refreshTokenCookieName ?? "refreshToken";

const cookieOptions: CookieOptions = {
  httpOnly: true,
  sameSite: env.refreshTokenCookieSameSite,
  secure: env.refreshTokenCookieSecure,
  domain: env.refreshTokenCookieDomain,
  path: "/",
  maxAge: env.refreshTokenCookieMaxAge,
} as const;

export const setRefreshTokenCookie = (res: Response, token: string) => {
  res.cookie(REFRESH_COOKIE_NAME, token, cookieOptions);
};

export const clearRefreshTokenCookie = (res: Response) => {
  res.clearCookie(REFRESH_COOKIE_NAME, {
    ...cookieOptions,
    maxAge: undefined,
  });
};

export const getRefreshTokenFromCookies = (
  cookies?: Record<string, string>,
) => {
  if (!cookies) return undefined;
  return cookies[REFRESH_COOKIE_NAME];
};
