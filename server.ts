import { serve } from "@hono/node-server";
import app from "./src/app";

const port = Number(process.env.PORT || 8787);

serve({ fetch: app.fetch, port }, (info) => {
  console.log(`[act] listening on http://127.0.0.1:${info.port}`);
});
