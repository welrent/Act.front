export function aiConfigured(): boolean {
  return Boolean(process.env.NEON_AI_GATEWAY_BASE_URL && process.env.NEON_AI_GATEWAY_TOKEN);
}

export async function summarize(text: string): Promise<string> {
  const base = (process.env.NEON_AI_GATEWAY_BASE_URL || "").replace(/\/$/, "");
  const token = process.env.NEON_AI_GATEWAY_TOKEN || "";
  const response = await fetch(`${base}/v1/chat/completions`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "databricks-claude-sonnet-4-5",
      messages: [
        {
          role: "system",
          content: "Summarize this Welrent rental contract in one short paragraph. Do not invent terms.",
        },
        { role: "user", content: text.slice(0, 12000) },
      ],
    }),
  });
  if (!response.ok) {
    const detail = await response.text();
    throw Object.assign(new Error(`AI gateway returned ${response.status}`), { status: 502, detail });
  }
  const payload = (await response.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  return payload.choices?.[0]?.message?.content?.trim() || "";
}
