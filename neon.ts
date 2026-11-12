import { defineConfig } from "@neon/config/v1";

export default defineConfig({
  auth: false,
  aiGateway: true,
  buckets: {
    actfiles: {
      access: "private",
    },
  },
  functions: {
    actapi: {
      name: "Welrent Act API",
      source: "./functions/api/index.ts",
    },
  },
  branch: (branch) => {
    if (branch.isDefault) {
      return {};
    }
    if (!branch.exists) {
      return { ttl: "7d" };
    }
    return {};
  },
});
