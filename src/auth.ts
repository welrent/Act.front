import { createHash, randomBytes, scrypt as scryptCb, timingSafeEqual } from "node:crypto";
import { promisify } from "node:util";
import type { Context, Next } from "hono";
import { query } from "./db";

const scrypt = promisify(scryptCb);
const SESSION_DAYS = 7;

export type AuthUser = {
  uid: string;
  email: string;
  displayName: string | null;
  photoUrl: string | null;
  role: "user" | "worker" | "admin";
};

export function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16).toString("hex");
  const derived = (await scrypt(password, salt, 64)) as Buffer;
  return `scrypt$${salt}$${derived.toString("hex")}`;
}

export async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const [scheme, salt, hex] = stored.split("$");
  if (scheme !== "scrypt" || !salt || !hex) return false;
  const derived = (await scrypt(password, salt, 64)) as Buffer;
  const expected = Buffer.from(hex, "hex");
  if (derived.length !== expected.length) return false;
  return timingSafeEqual(derived, expected);
}

export function staffRoleForEmail(email: string): "admin" | "worker" | "user" {
  const normalized = email.trim().toLowerCase();
  if (normalized.endsWith("@id.welrent.com") || normalized === "welrent.business@gmail.com") {
    return "admin";
  }
  return "user";
}

export async function resolveRole(email: string, storedRole: string): Promise<AuthUser["role"]> {
  const automatic = staffRoleForEmail(email);
  if (automatic === "admin") return "admin";
  const workers = await query("SELECT 1 FROM workers WHERE lower(email) = lower($1) LIMIT 1", [email]);
  if (workers.rowCount) return "worker";
  const admins = await query("SELECT 1 FROM admins WHERE lower(email) = lower($1) LIMIT 1", [email]);
  if (admins.rowCount) return "admin";
  if (storedRole === "admin" || storedRole === "worker") return storedRole;
  return "user";
}

export async function createSession(uid: string): Promise<string> {
  const token = randomBytes(32).toString("hex");
  const expires = new Date(Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000);
  await query(
    "INSERT INTO sessions (token_hash, user_uid, expires_at) VALUES ($1, $2, $3)",
    [hashToken(token), uid, expires.toISOString()],
  );
  return token;
}

export async function userFromToken(token: string | undefined): Promise<AuthUser | null> {
  if (!token) return null;
  const result = await query<{
    uid: string;
    email: string;
    display_name: string | null;
    photo_url: string | null;
    role: string;
  }>(
    `SELECT u.uid, u.email, u.display_name, u.photo_url, u.role
     FROM sessions s
     JOIN users u ON u.uid = s.user_uid
     WHERE s.token_hash = $1 AND s.expires_at > NOW()`,
    [hashToken(token)],
  );
  const row = result.rows[0];
  if (!row) return null;
  const role = await resolveRole(row.email, row.role);
  return {
    uid: row.uid,
    email: row.email,
    displayName: row.display_name,
    photoUrl: row.photo_url,
    role,
  };
}

export function bearerToken(header: string | undefined): string | undefined {
  if (!header) return undefined;
  const match = header.match(/^Bearer\s+(.+)$/i);
  return match?.[1]?.trim();
}

export async function requireUser(c: Context, next: Next) {
  const user = await userFromToken(bearerToken(c.req.header("authorization")));
  if (!user) return c.json({ error: "Unauthorized" }, 401);
  c.set("user", user);
  await next();
}

export async function requireStaff(c: Context, next: Next) {
  const user = await userFromToken(bearerToken(c.req.header("authorization")));
  if (!user) return c.json({ error: "Unauthorized" }, 401);
  if (user.role !== "admin" && user.role !== "worker") {
    return c.json({ error: "Forbidden" }, 403);
  }
  c.set("user", user);
  await next();
}

export async function logLogin(email: string, success: boolean, ip: string | null, _userAgent: string | null) {
  await query(
    "INSERT INTO login_logs (email, ip_address, status) VALUES ($1, $2, $3)",
    [email, ip, success ? "success" : "failed"],
  );
}
