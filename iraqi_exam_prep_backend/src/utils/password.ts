import bcrypt from "bcrypt";
import { env } from "../config/env";

export const hashPassword = async (plain: string) => {
  return bcrypt.hash(plain, env.bcryptSaltRounds);
};

export const comparePassword = async (plain: string, hash: string) => {
  return bcrypt.compare(plain, hash);
};
