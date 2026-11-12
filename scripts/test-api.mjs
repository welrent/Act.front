const base = process.env.ACT_PUBLIC_URL || "http://127.0.0.1:8787";

async function request(path, options = {}) {
  const response = await fetch(`${base}${path}`, options);
  const text = await response.text();
  let body = null;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    body = text;
  }
  return { status: response.status, body };
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

const failures = [];

async function check(name, fn) {
  try {
    await fn();
    console.log(`ok  ${name}`);
  } catch (err) {
    failures.push(`${name}: ${err instanceof Error ? err.message : err}`);
    console.error(`FAIL ${name}: ${err instanceof Error ? err.message : err}`);
  }
}

await check("health", async () => {
  const res = await request("/api/health");
  assert(res.status === 200, `status ${res.status}`);
  assert(res.body.database === true, "database not ready");
  assert(res.body.storage === true, "storage not configured");
  assert(res.body.aiGateway === false || res.body.aiGateway === true, "ai flag missing");
});

await check("public pages", async () => {
  const res = await request("/api/pages");
  assert(res.status === 200 && Array.isArray(res.body) && res.body.length > 0, "no pages");
  assert(res.body.some((page) => page.slug === "car-rental-agreement"), "car agreement missing");
});

await check("search", async () => {
  const res = await request("/api/search?q=Audi");
  assert(res.status === 200 && Array.isArray(res.body), "search failed");
});

let token = "";
await check("login rejects bad password", async () => {
  const res = await request("/api/auth/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: process.env.ADMIN_EMAIL, password: "wrong-password" }),
  });
  assert(res.status === 401, `expected 401 got ${res.status}`);
});

await check("admin login", async () => {
  const res = await request("/api/auth/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: process.env.ADMIN_EMAIL, password: process.env.ADMIN_PASSWORD }),
  });
  assert(res.status === 200 && res.body.token, `login ${res.status}`);
  assert(res.body.role === "admin", `role ${res.body.role}`);
  token = res.body.token;
});

await check("settings", async () => {
  const res = await request("/api/admin/settings", {
    headers: { Authorization: `Bearer ${token}` },
  });
  assert(res.status === 200 && Array.isArray(res.body), `settings ${res.status}`);
  const denied = await request("/api/admin/settings");
  assert(denied.status === 401, "settings should require auth");
});

const booking = `WLR-TEST-${Date.now()}`;
let createdRef = "";
await check("create contract and idempotency", async () => {
  const payload = {
    user_uid: "demo-user-001",
    user_email: process.env.DEMO_EMAIL,
    user_name: "Demo Renter",
    booking_ref: booking,
    vehicle_type: "boat",
    vehicle_name: "Test Tender",
    start_date: "2026-08-01",
    end_date: "2026-08-03",
    price: 410,
    location: "IJmuiden",
  };
  const first = await request("/api/contracts", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  assert(first.status === 201, `create ${first.status} ${JSON.stringify(first.body)}`);
  createdRef = first.body.contract_ref;
  const second = await request("/api/contracts", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  assert(second.status === 200 && second.body.created === false, "idempotency failed");
  assert(second.body.contract_ref === createdRef, "ref changed");
});

await check("missing contract", async () => {
  const res = await request("/api/contracts/ACT-DOES-NOT-EXIST");
  assert(res.status === 404, `expected 404 got ${res.status}`);
});

await check("contact validation", async () => {
  const bad = await request("/api/contact", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "A" }),
  });
  assert(bad.status === 400, `expected 400 got ${bad.status}`);
  const good = await request("/api/contact", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Ada", email: "ada@example.com", message: "Hello from the API test" }),
  });
  assert(good.status === 201, `contact ${good.status}`);
});

await check("storage signed url", async () => {
  const res = await request("/api/uploads", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      filename: "act-smoke.txt",
      contentType: "text/plain",
      contentBase64: Buffer.from("welrent act smoke").toString("base64"),
    }),
  });
  assert(res.status === 201 && res.body.url, `upload ${res.status} ${JSON.stringify(res.body)}`);
  const file = await fetch(res.body.url);
  assert(file.status === 200, `signed get ${file.status}`);
});

await check("ai gateway", async () => {
  const res = await request("/api/ai/summarize", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: "Short rental of an Audi in Amsterdam." }),
  });
  if (process.env.NEON_AI_GATEWAY_TOKEN) {
    assert(res.status === 200 && res.body.summary, `summary ${res.status}`);
  } else {
    assert(res.status === 503, `expected 503 got ${res.status}`);
  }
});

await check("logout invalidates token", async () => {
  const out = await request("/api/auth/session", {
    method: "DELETE",
    headers: { Authorization: `Bearer ${token}` },
  });
  assert(out.status === 200, `logout ${out.status}`);
  const me = await request("/api/auth/me", { headers: { Authorization: `Bearer ${token}` } });
  assert(me.status === 401, `token still valid ${me.status}`);
});

if (failures.length) {
  console.error(`\n${failures.length} failed`);
  process.exit(1);
}
console.log("\nall api checks passed");
