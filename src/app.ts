import { Hono } from "hono";
import { cors } from "hono/cors";
import { query } from "./db";
import { SCHEMA_SQL } from "./schema";
import {
  bearerToken,
  createSession,
  hashPassword,
  logLogin,
  requireStaff,
  resolveRole,
  userFromToken,
  verifyPassword,
  type AuthUser,
} from "./auth";
import { applyPlaceholders, createContract, loadSettingsMap, shapeContract } from "./contracts";
import { aiConfigured, summarize } from "./ai";
import { putObject, signedGet, storageConfigured } from "./storage";

type Env = { Variables: { user: AuthUser } };

const app = new Hono<Env>();

let schemaReady: Promise<void> | null = null;

function ensureSchema(): Promise<void> {
  if (!schemaReady) {
    schemaReady = query(SCHEMA_SQL).then(() => undefined).catch((err) => {
      schemaReady = null;
      throw err;
    });
  }
  return schemaReady;
}

app.use("*", cors());
app.use("*", async (c, next) => {
  if (c.req.path.startsWith("/api")) {
    await ensureSchema();
  }
  await next();
});

app.get("/api/health", async (c) => {
  let database = false;
  try {
    await query("SELECT 1");
    database = true;
  } catch {
    database = false;
  }
  return c.json({
    ok: database,
    database,
    storage: storageConfigured(),
    aiGateway: aiConfigured(),
    bucket: process.env.S3_BUCKET || "actfiles",
  });
});

app.post("/api/auth/login", async (c) => {
  const body = await c.req.json<{ email?: string; password?: string }>().catch(() => ({ email: "", password: "" }));
  const email = String(body.email ?? "").trim().toLowerCase();
  const password = String(body.password ?? "");
  const ip = c.req.header("x-forwarded-for") ?? null;
  const userAgent = c.req.header("user-agent") ?? null;
  if (!email || !password) {
    return c.json({ error: "Email and password are required" }, 400);
  }
  const found = await query<{
    uid: string;
    email: string;
    password_hash: string;
    display_name: string | null;
    photo_url: string | null;
    role: string;
  }>("SELECT uid, email, password_hash, display_name, photo_url, role FROM users WHERE lower(email) = $1", [email]);
  const row = found.rows[0];
  if (!row || !(await verifyPassword(password, row.password_hash))) {
    await logLogin(email, false, ip, userAgent);
    return c.json({ error: "Invalid email or password" }, 401);
  }
  const role = await resolveRole(row.email, row.role);
  if (role !== row.role) {
    await query("UPDATE users SET role = $1 WHERE uid = $2", [role, row.uid]);
  }
  const token = await createSession(row.uid);
  await logLogin(email, true, ip, userAgent);
  const user = {
    uid: row.uid,
    email: row.email,
    displayName: row.display_name,
    photoUrl: row.photo_url,
    role,
  };
  return c.json({ token, user, role });
});

app.get("/api/auth/me", async (c) => {
  const user = await userFromToken(bearerToken(c.req.header("authorization")));
  if (!user) return c.json({ error: "Unauthorized" }, 401);
  return c.json({ user, role: user.role });
});

app.post("/api/auth/session", async (c) => {
  const user = await userFromToken(bearerToken(c.req.header("authorization")));
  if (!user) return c.json({ error: "Unauthorized" }, 401);
  return c.json({ user, role: user.role });
});

app.delete("/api/auth/session", async (c) => {
  const token = bearerToken(c.req.header("authorization"));
  if (token) {
    const { hashToken } = await import("./auth");
    await query("DELETE FROM sessions WHERE token_hash = $1", [hashToken(token)]);
  }
  return c.json({ ok: true });
});

app.get("/api/pages", async (c) => {
  const settings = await loadSettingsMap();
  const result = await query("SELECT id, title, slug, content, created_at, updated_at FROM pages ORDER BY title");
  const pages = result.rows.map((row) => ({
    ...row,
    content: applyPlaceholders(String(row.content ?? ""), settings),
  }));
  return c.json(pages);
});

app.get("/api/pages/:slug", async (c) => {
  const settings = await loadSettingsMap();
  const result = await query(
    "SELECT id, title, slug, content, created_at, updated_at FROM pages WHERE slug = $1",
    [c.req.param("slug")],
  );
  const row = result.rows[0];
  if (!row) return c.json({ error: "Not found" }, 404);
  return c.json({
    page: { ...row, content: applyPlaceholders(String(row.content ?? ""), settings) },
  });
});

app.get("/api/site-settings", async (c) => {
  const result = await query("SELECT key, value, label FROM site_settings ORDER BY key");
  return c.json(result.rows);
});

app.get("/api/contracts", async (c) => {
  const uid = c.req.query("uid");
  const user = await userFromToken(bearerToken(c.req.header("authorization")));
  if (uid) {
    const result = await query("SELECT * FROM contracts WHERE user_uid = $1 ORDER BY created_at DESC", [uid]);
    return c.json({ contracts: result.rows.map((row) => shapeContract(row as Record<string, unknown>)) });
  }
  if (!user || (user.role !== "admin" && user.role !== "worker")) {
    return c.json({ error: "Unauthorized" }, 401);
  }
  const result = await query("SELECT * FROM contracts ORDER BY created_at DESC LIMIT 200");
  return c.json({ contracts: result.rows.map((row) => shapeContract(row as Record<string, unknown>)) });
});

app.get("/api/contracts/:ref", async (c) => {
  const ref = c.req.param("ref");
  const result = await query(
    "SELECT * FROM contracts WHERE contract_ref = $1 OR booking_ref = $1 LIMIT 1",
    [ref],
  );
  const row = result.rows[0];
  if (!row) return c.json({ error: "Not found" }, 404);
  return c.json({ contract: shapeContract(row as Record<string, unknown>) });
});

app.post("/api/contracts", async (c) => {
  const ingestKey = process.env.WELRENT_INGEST_KEY;
  if (ingestKey && c.req.header("x-welrent-key") !== ingestKey) {
    return c.json({ error: "Unauthorized" }, 401);
  }
  const body = await c.req.json().catch(() => null);
  if (!body || typeof body !== "object") return c.json({ error: "Invalid JSON" }, 400);
  try {
    const result = await createContract(body as Record<string, unknown>);
    return c.json(
      {
        contract: result.contract,
        contract_ref: result.contract.contract_ref,
        contract_url: result.contract.contract_url,
        created: result.created,
      },
      result.created ? 201 : 200,
    );
  } catch (err) {
    const status = (err as { status?: number }).status ?? 500;
    const message = err instanceof Error ? err.message : "Failed to create contract";
    return c.json({ error: message }, status as 400);
  }
});

app.get("/api/search", async (c) => {
  const q = (c.req.query("q") || "").trim();
  if (q.length < 2) return c.json([]);
  const like = `%${q}%`;
  const pages = await query<{ title: string; slug: string }>(
    "SELECT title, slug FROM pages WHERE title ILIKE $1 OR content ILIKE $1 LIMIT 20",
    [like],
  );
  const contracts = await query<{ contract_ref: string; vehicle_name: string }>(
    "SELECT contract_ref, vehicle_name FROM contracts WHERE contract_ref ILIKE $1 OR vehicle_name ILIKE $1 OR booking_ref ILIKE $1 LIMIT 20",
    [like],
  );
  const results = [
    ...pages.rows.map((row) => ({ title: row.title, type: "Page", url: `/pages/${row.slug}` })),
    ...contracts.rows.map((row) => ({
      title: `${row.vehicle_name} (${row.contract_ref})`,
      type: "Contract",
      url: `/contracts/${row.contract_ref}`,
    })),
  ];
  return c.json(results);
});

app.post("/api/contact", async (c) => {
  const body = (await c.req.json().catch(() => ({}))) as {
    name?: string;
    email?: string;
    message?: string;
  };
  const name = String(body.name ?? "").trim();
  const email = String(body.email ?? "").trim();
  const message = String(body.message ?? "").trim();
  if (!name || !email || !message || !email.includes("@")) {
    return c.json({ error: "Name, email, and message are required" }, 400);
  }
  await query("INSERT INTO contact_messages (name, email, message) VALUES ($1, $2, $3)", [name, email, message]);
  return c.json({ ok: true }, 201);
});

app.post("/api/ai/summarize", async (c) => {
  if (!aiConfigured()) {
    return c.json({ error: "AI gateway is not configured" }, 503);
  }
  const body = (await c.req.json().catch(() => ({}))) as { text?: string; ref?: string };
  let text = String(body.text ?? "");
  if (!text && body.ref) {
    const found = await query<{ contract_html: string | null }>(
      "SELECT contract_html FROM contracts WHERE contract_ref = $1",
      [body.ref],
    );
    text = found.rows[0]?.contract_html ?? "";
  }
  if (!text.trim()) return c.json({ error: "Nothing to summarize" }, 400);
  try {
    const summary = await summarize(text);
    return c.json({ summary });
  } catch (err) {
    const message = err instanceof Error ? err.message : "AI request failed";
    return c.json({ error: message }, 502);
  }
});

app.post("/api/uploads", async (c) => {
  if (!storageConfigured()) return c.json({ error: "Storage is not configured" }, 503);
  const body = (await c.req.json().catch(() => ({}))) as {
    filename?: string;
    contentBase64?: string;
    contentType?: string;
  };
  const filename = String(body.filename ?? "upload.bin").replace(/[^a-zA-Z0-9._-]+/g, "-");
  const contentType = String(body.contentType ?? "application/octet-stream");
  const raw = String(body.contentBase64 ?? "");
  if (!raw) return c.json({ error: "contentBase64 is required" }, 400);
  const bytes = Buffer.from(raw, "base64");
  const key = `uploads/${Date.now()}-${filename}`;
  await putObject(key, bytes, contentType);
  const url = await signedGet(key);
  return c.json({ key, url }, 201);
});

app.get("/api/admin/pages", requireStaff, async (c) => {
  const result = await query("SELECT id, title, slug, content, created_at, updated_at FROM pages ORDER BY title");
  return c.json(result.rows);
});

app.post("/api/admin/pages", requireStaff, async (c) => {
  const body = await c.req.json<{ id?: number; content?: string; title?: string; slug?: string }>();
  if (body.id) {
    await query("UPDATE pages SET content = $1, updated_at = NOW() WHERE id = $2", [body.content ?? "", body.id]);
    return c.json({ ok: true });
  }
  if (!body.title || !body.slug) return c.json({ error: "id or title+slug required" }, 400);
  await query(
    `INSERT INTO pages (title, slug, content) VALUES ($1, $2, $3)
     ON CONFLICT (slug) DO UPDATE SET content = EXCLUDED.content, title = EXCLUDED.title, updated_at = NOW()`,
    [body.title, body.slug, body.content ?? ""],
  );
  return c.json({ ok: true });
});

app.get("/api/admin/settings", requireStaff, async (c) => {
  const result = await query("SELECT key, value, label FROM site_settings ORDER BY key");
  return c.json(result.rows);
});

app.post("/api/admin/settings", requireStaff, async (c) => {
  const body = await c.req.json<unknown>();
  const list = Array.isArray(body)
    ? body
    : body && typeof body === "object" && Array.isArray((body as { settings?: unknown }).settings)
      ? (body as { settings: unknown[] }).settings
      : null;
  if (!list) return c.json({ error: "Expected settings array" }, 400);
  for (const item of list) {
    if (!item || typeof item !== "object") continue;
    const row = item as { key?: string; value?: string; label?: string };
    if (!row.key) continue;
    await query(
      `INSERT INTO site_settings (key, value, label) VALUES ($1, $2, $3)
       ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, label = COALESCE(EXCLUDED.label, site_settings.label)`,
      [row.key, row.value ?? "", row.label ?? null],
    );
  }
  return c.json({ ok: true });
});

app.get("/api/admin/stats", requireStaff, async (c) => {
  const [contracts, pages, users, messages] = await Promise.all([
    query<{ count: string }>("SELECT COUNT(*)::text AS count FROM contracts"),
    query<{ count: string }>("SELECT COUNT(*)::text AS count FROM pages"),
    query<{ count: string }>("SELECT COUNT(*)::text AS count FROM users"),
    query<{ count: string }>("SELECT COUNT(*)::text AS count FROM contact_messages"),
  ]);
  return c.json({
    contracts: Number(contracts.rows[0]?.count ?? 0),
    pages: Number(pages.rows[0]?.count ?? 0),
    users: Number(users.rows[0]?.count ?? 0),
    messages: Number(messages.rows[0]?.count ?? 0),
  });
});

app.get("/api/admin/logs", requireStaff, async (c) => {
  const result = await query(
    "SELECT id, email, status, ip_address, created_at FROM login_logs ORDER BY created_at DESC LIMIT 100",
  );
  return c.json(result.rows);
});

app.get("/api/posts", async (c) => {
  const result = await query(
    "SELECT id, title, slug, content, image_path, created_at FROM posts ORDER BY created_at DESC",
  );
  return c.json(result.rows);
});

app.post("/api/admin/posts", requireStaff, async (c) => {
  const body = await c.req.json<{ title?: string; slug?: string; content?: string; image_path?: string }>();
  if (!body.title || !body.slug) return c.json({ error: "title and slug are required" }, 400);
  await query(
    `INSERT INTO posts (title, slug, content, image_path) VALUES ($1, $2, $3, $4)
     ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, content = EXCLUDED.content, image_path = EXCLUDED.image_path, updated_at = NOW()`,
    [body.title, body.slug, body.content ?? "", body.image_path ?? null],
  );
  return c.json({ ok: true }, 201);
});

app.notFound((c) => c.json({ error: "Not found" }, 404));

export default app;
