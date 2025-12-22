import "dotenv/config";

const requiredEnv = [
  "PORT",
  "DATABASE_URL",
  "JWT_ACCESS_SECRET",
  "JWT_REFRESH_SECRET",
  "ACCESS_TOKEN_TTL",
  "REFRESH_TOKEN_TTL",
  "BCRYPT_SALT_ROUNDS",
];

requiredEnv.forEach((key) => {
  if (!process.env[key]) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
});

export const env = {
  nodeEnv: process.env.NODE_ENV ?? "development",
  port: Number(process.env.PORT) || 3000,
  databaseUrl: process.env.DATABASE_URL!,
  jwtAccessSecret: process.env.JWT_ACCESS_SECRET!,
  jwtRefreshSecret: process.env.JWT_REFRESH_SECRET!,
  accessTokenTtl: process.env.ACCESS_TOKEN_TTL!,
  refreshTokenTtl: process.env.REFRESH_TOKEN_TTL!,
  bcryptSaltRounds: Number(process.env.BCRYPT_SALT_ROUNDS) || 12,
  rateLimitWindowMs: Number(process.env.RATE_LIMIT_WINDOW) || 60000,
  rateLimitMax: Number(process.env.RATE_LIMIT_MAX) || 100,
  clientBaseUrl: process.env.CLIENT_BASE_URL ?? "*",
  adminEmail: process.env.ADMIN_EMAIL ?? "admin@iraqi-exam.app",
  adminPassword: process.env.ADMIN_PASSWORD ?? "Admin@123456",
  adminName: process.env.ADMIN_NAME ?? "Platform Admin",
  refreshTokenCookieName: process.env.REFRESH_COOKIE_NAME ?? "refreshToken",
  refreshTokenCookieDomain: process.env.REFRESH_COOKIE_DOMAIN,
  refreshTokenCookieSecure:
    process.env.REFRESH_COOKIE_SECURE === "true" || process.env.NODE_ENV === "production",
  refreshTokenCookieSameSite: (process.env.REFRESH_COOKIE_SAME_SITE as
    | "lax"
    | "none"
    | "strict") ?? "lax",
  refreshTokenCookieMaxAge:
    Number(process.env.REFRESH_COOKIE_MAX_AGE ?? 1000 * 60 * 60 * 24 * 14),
};
