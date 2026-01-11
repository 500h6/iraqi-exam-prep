import {
  JwtPayload as JwtPayloadBase,
  Secret,
  SignOptions,
  sign,
  verify,
} from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";
import { env } from "../config/env";

export interface JwtPayload {
  sub: string;
  role: string;
  jti?: string;
}

const accessSecret: Secret = env.jwtAccessSecret;
const refreshSecret: Secret = env.jwtRefreshSecret;

export const signAccessToken = (payload: JwtPayload) => {
  return sign(payload, accessSecret, {
    expiresIn: env.accessTokenTtl,
  } as SignOptions);
};

export const signRefreshToken = (payload: JwtPayload) => {
  return sign({ ...payload, jti: uuidv4() }, refreshSecret, {
    expiresIn: env.refreshTokenTtl,
  } as SignOptions);
};

export const verifyAccessToken = (token: string) =>
  verify(token, accessSecret) as JwtPayload & JwtPayloadBase;

export const verifyRefreshToken = (token: string) =>
  verify(token, refreshSecret) as JwtPayload & JwtPayloadBase;
