import { query } from "./db";

const VEHICLE_TYPES = ["car", "motorcycle", "boat", "equipment"] as const;

const AGREEMENT_BY_TYPE: Record<string, string> = {
  car: "car-rental-agreement",
  motorcycle: "motorcycle-rental-agreement",
  boat: "boat-rental-agreement",
  equipment: "equipment-rental-agreement",
};

export function normalizeVehicleType(value: unknown): string {
  const raw = String(value ?? "car").trim().toLowerCase();
  return (VEHICLE_TYPES as readonly string[]).includes(raw) ? raw : "car";
}

export function agreementSlugFor(vehicleType: string): string {
  return AGREEMENT_BY_TYPE[normalizeVehicleType(vehicleType)] ?? AGREEMENT_BY_TYPE.car;
}

export function contractRefFor(bookingRef: string): string {
  const cleaned = bookingRef.trim().toUpperCase().replace(/[^A-Z0-9-]+/g, "-").replace(/^-+|-+$/g, "");
  if (cleaned.startsWith("ACT-")) return cleaned;
  return `ACT-${cleaned}`;
}

export function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

export async function loadSettingsMap(): Promise<Record<string, string>> {
  const result = await query<{ key: string; value: string }>("SELECT key, value FROM site_settings");
  const map: Record<string, string> = {};
  for (const row of result.rows) map[row.key] = row.value ?? "";
  return map;
}

export function applyPlaceholders(html: string, settings: Record<string, string>): string {
  return html.replace(/\[([A-Z0-9_]+)\]/g, (full, key: string) => settings[key] ?? full);
}

type ContractInput = {
  user_uid?: string;
  user_email?: string;
  user_name?: string;
  booking_ref?: string;
  vehicle_type?: string;
  vehicle_name?: string;
  vehicle_image?: string;
  start_date?: string;
  end_date?: string;
  days?: number;
  price?: number;
  location?: string;
  status?: string;
  source?: string;
};

export function publicContractUrl(ref: string): string {
  const origin = (process.env.ACT_PUBLIC_URL || "http://127.0.0.1:8787").replace(/\/$/, "");
  return `${origin}/contracts/${encodeURIComponent(ref)}`;
}

export async function renderContractHtml(input: {
  vehicleName: string;
  vehicleType: string;
  userName: string;
  userEmail: string;
  startDate: string;
  endDate: string;
  location: string;
  price: number;
  days: number;
  bookingRef: string;
  agreementSlug: string;
}): Promise<string> {
  const page = await query<{ content: string | null }>(
    "SELECT content FROM pages WHERE slug = $1",
    [input.agreementSlug],
  );
  const settings = await loadSettingsMap();
  const body = applyPlaceholders(page.rows[0]?.content ?? "", settings);
  const summary = `
<section class="contract-summary">
  <h1>Rental contract ${escapeHtml(input.bookingRef)}</h1>
  <p><strong>Vehicle:</strong> ${escapeHtml(input.vehicleName)} (${escapeHtml(input.vehicleType)})</p>
  <p><strong>Renter:</strong> ${escapeHtml(input.userName)} &lt;${escapeHtml(input.userEmail)}&gt;</p>
  <p><strong>Period:</strong> ${escapeHtml(input.startDate)} → ${escapeHtml(input.endDate)} (${input.days} days)</p>
  <p><strong>Location:</strong> ${escapeHtml(input.location || "—")}</p>
  <p><strong>Price:</strong> €${input.price.toFixed(2)}</p>
</section>`;
  return `${summary}\n${body}`;
}

function daysBetween(start: string, end: string): number {
  const a = Date.parse(start);
  const b = Date.parse(end);
  if (Number.isNaN(a) || Number.isNaN(b)) return 1;
  const diff = Math.round((b - a) / 86400000);
  return Math.max(1, diff || 1);
}

export async function createContract(input: ContractInput) {
  const vehicleName = String(input.vehicle_name ?? "").trim();
  const userUid = String(input.user_uid ?? "").trim();
  const startDate = String(input.start_date ?? "").slice(0, 10);
  const endDate = String(input.end_date ?? "").slice(0, 10);
  if (!vehicleName || !userUid || !startDate || !endDate) {
    throw Object.assign(new Error("vehicle_name, user_uid, start_date and end_date are required"), { status: 400 });
  }
  const bookingRef = String(input.booking_ref ?? `${userUid}-${Date.now()}`).trim();
  const existing = await query("SELECT * FROM contracts WHERE booking_ref = $1", [bookingRef]);
  if (existing.rows[0]) {
    const row = existing.rows[0] as Record<string, unknown>;
    return { contract: shapeContract(row), created: false };
  }
  const vehicleType = normalizeVehicleType(input.vehicle_type);
  const agreementSlug = agreementSlugFor(vehicleType);
  const ref = contractRefFor(bookingRef);
  const days = input.days && input.days > 0 ? input.days : daysBetween(startDate, endDate);
  const price = Number(input.price ?? 0);
  const userName = String(input.user_name ?? "");
  const userEmail = String(input.user_email ?? "");
  const html = await renderContractHtml({
    vehicleName,
    vehicleType,
    userName,
    userEmail,
    startDate,
    endDate,
    location: String(input.location ?? ""),
    price,
    days,
    bookingRef,
    agreementSlug,
  });
  const inserted = await query(
    `INSERT INTO contracts (
      contract_ref, booking_ref, user_uid, user_email, user_name, vehicle_type, vehicle_name,
      vehicle_image, start_date, end_date, days, price, location, status, agreement_slug,
      contract_html, source
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)
    RETURNING *`,
    [
      ref,
      bookingRef,
      userUid,
      userEmail || null,
      userName || null,
      vehicleType,
      vehicleName,
      input.vehicle_image ?? null,
      startDate,
      endDate,
      days,
      price,
      input.location ?? null,
      input.status || "active",
      agreementSlug,
      html,
      input.source ?? "api",
    ],
  );
  return { contract: shapeContract(inserted.rows[0] as Record<string, unknown>), created: true };
}

export function shapeContract(row: Record<string, unknown>) {
  const ref = String(row.contract_ref ?? "");
  return {
    ...row,
    contract_ref: ref,
    price: row.price == null ? 0 : Number(row.price),
    days: row.days == null ? 1 : Number(row.days),
    start_date: row.start_date instanceof Date ? row.start_date.toISOString().slice(0, 10) : row.start_date,
    end_date: row.end_date instanceof Date ? row.end_date.toISOString().slice(0, 10) : row.end_date,
    contract_url: publicContractUrl(ref),
  };
}
