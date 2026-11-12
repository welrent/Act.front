import fs from "node:fs";
import path from "node:path";
import { query } from "../src/db";
import { SCHEMA_SQL } from "../src/schema";
import { hashPassword } from "../src/auth";
import { createContract } from "../src/contracts";

type PageSeed = { title: string; slug: string; content: string };

function pagesFromDart(): PageSeed[] {
  const file = path.join(process.cwd(), "lib/models/seed_data.dart");
  const src = fs.readFileSync(file, "utf8");
  const pages: PageSeed[] = [];
  const re = /title:\s*'([^']+)',\s*slug:\s*'([^']+)',\s*content:\s*'''([\s\S]*?)'''/g;
  let match: RegExpExecArray | null;
  while ((match = re.exec(src))) {
    pages.push({ title: match[1], slug: match[2], content: match[3] });
  }
  if (pages.length === 0) {
    throw new Error("No pages extracted from lib/models/seed_data.dart");
  }
  return pages;
}

const SETTINGS: Array<{ key: string; value: string; label: string }> = [
  { key: "COMPANY_ADDRESS", value: "Welrent AutoVerhuur, The Netherlands", label: "Company address" },
  { key: "CHAMBER_OF_COMMERCE_NUMBER", value: "KVK pending", label: "Chamber of Commerce" },
  { key: "VAT_NUMBER", value: "NL VAT pending", label: "VAT number" },
  { key: "EMAIL", value: "hello@welrent.com", label: "Email" },
  { key: "PHONE_NUMBER", value: "+31 (0)20 000 0000", label: "Phone" },
];

async function upsertUser(uid: string, email: string, password: string, displayName: string, role: string) {
  const passwordHash = await hashPassword(password);
  await query(
    `INSERT INTO users (uid, email, password_hash, display_name, role)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (email) DO UPDATE
       SET password_hash = EXCLUDED.password_hash,
           display_name = EXCLUDED.display_name,
           role = EXCLUDED.role`,
    [uid, email, passwordHash, displayName, role],
  );
}

async function main() {
  await query(SCHEMA_SQL);
  const pages = pagesFromDart();
  for (const page of pages) {
    await query(
      `INSERT INTO pages (title, slug, content)
       VALUES ($1, $2, $3)
       ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, content = EXCLUDED.content, updated_at = NOW()`,
      [page.title, page.slug, page.content],
    );
    await query(
      `INSERT INTO agreements (title, description, content)
       SELECT $1, $2, $3
       WHERE NOT EXISTS (SELECT 1 FROM agreements WHERE title = $1)`,
      [page.title, page.slug, page.content],
    );
  }
  for (const setting of SETTINGS) {
    await query(
      `INSERT INTO site_settings (key, value, label) VALUES ($1, $2, $3)
       ON CONFLICT (key) DO NOTHING`,
      [setting.key, setting.value, setting.label],
    );
  }
  const adminEmail = process.env.ADMIN_EMAIL || "admin@id.welrent.com";
  const adminPassword = process.env.ADMIN_PASSWORD || "";
  const demoEmail = process.env.DEMO_EMAIL || "demo@welrent.com";
  const demoPassword = process.env.DEMO_PASSWORD || "";
  if (!adminPassword || !demoPassword) {
    throw new Error("ADMIN_PASSWORD and DEMO_PASSWORD must be set");
  }
  await upsertUser("admin-user-001", adminEmail, adminPassword, "Admin User", "admin");
  await upsertUser("demo-user-001", demoEmail, demoPassword, "Demo Renter", "user");
  await query(
    `INSERT INTO admins (email) VALUES ($1) ON CONFLICT (email) DO NOTHING`,
    [adminEmail],
  );

  await createContract({
    user_uid: "demo-user-001",
    user_email: demoEmail,
    user_name: "Demo Renter",
    booking_ref: "WLR-2026-DEMO1",
    vehicle_type: "car",
    vehicle_name: "Audi RS6",
    start_date: "2026-06-01",
    end_date: "2026-06-05",
    price: 890,
    location: "Amsterdam",
    source: "seed",
  });
  await createContract({
    user_uid: "demo-user-001",
    user_email: demoEmail,
    user_name: "Demo Renter",
    booking_ref: "WLR-2026-DEMO2",
    vehicle_type: "motorcycle",
    vehicle_name: "Yamaha MT-07",
    start_date: "2026-07-10",
    end_date: "2026-07-12",
    price: 240,
    location: "Rotterdam",
    source: "seed",
  });

  const counts = await query<{ pages: string; users: string; contracts: string }>(
    `SELECT
       (SELECT COUNT(*) FROM pages)::text AS pages,
       (SELECT COUNT(*) FROM users)::text AS users,
       (SELECT COUNT(*) FROM contracts)::text AS contracts`,
  );
  console.log("[act] seed complete", counts.rows[0]);
  await (await import("../src/db")).getPool().end();
}

main().catch((err) => {
  console.error("[act] seed failed", err);
  process.exit(1);
});
