import { Pool, type QueryResult, type QueryResultRow } from "pg";

let pool: Pool | null = null;

export function getPool(): Pool {
  if (pool) return pool;
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("DATABASE_URL is not set");
  }
  pool = new Pool({
    connectionString,
    max: 5,
    ssl: { rejectUnauthorized: false },
  });
  pool.on("error", (err) => {
    console.error("[act] idle postgres client error", err.message);
  });
  try {
    // Neon Functions: idle disconnects must not crash the isolate.
    // Optional so local node still runs if the helper is unavailable.
    const { attachDatabasePool } = require("@neon/functions") as {
      attachDatabasePool: (p: Pool) => void;
    };
    attachDatabasePool(pool);
  } catch {
    // Local runs without the functions runtime.
  }
  return pool;
}

export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params: unknown[] = [],
): Promise<QueryResult<T>> {
  return getPool().query<T>(text, params);
}
