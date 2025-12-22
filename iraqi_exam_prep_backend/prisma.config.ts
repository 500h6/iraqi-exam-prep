import "dotenv/config";
import { defineConfig, env } from "prisma/config";

const config = defineConfig({
  schema: "prisma/schema.prisma",
  migrations: { path: "prisma/migrations" },
  engine: "classic",
  datasource: { url: env("DATABASE_URL") },
});

export default config;
