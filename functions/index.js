const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

function isDummyKey(key) {
  if (!key) return true;
  const k = String(key).trim();
  return k.length === 0 || k.startsWith("sk-dummy") || k === "DUMMY_CHATGPT_API_KEY";
}

function json(res, status, body) {
  res.status(status).set("content-type", "application/json").send(JSON.stringify(body));
}

exports.chat = onRequest(
  {
    region: "us-central1",
    cors: true,
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      return json(res, 405, { error: "Use POST" });
    }

    const { prompt, messages } = req.body || {};
    const apiKey = process.env.OPENAI_API_KEY || "DUMMY_CHATGPT_API_KEY";

    // Safe default: if key is dummy/missing, return a deterministic mock so UI can be built/tested.
    if (isDummyKey(apiKey)) {
      const text =
        typeof prompt === "string" && prompt.trim().length
          ? prompt.trim()
          : Array.isArray(messages) && messages.length
            ? String(messages[messages.length - 1]?.content ?? "").trim()
            : "";

      return json(res, 200, {
        mocked: true,
        model: "gpt-4.1-mini (mock)",
        output_text:
          text.length > 0
            ? `Mocked response (set OPENAI_API_KEY to use live ChatGPT).\n\nYou said: ${text}`
            : "Mocked response (set OPENAI_API_KEY to use live ChatGPT).",
      });
    }

    try {
      // Supports either a simple "prompt" or a full "messages" array.
      const chatMessages = Array.isArray(messages)
        ? messages
        : [{ role: "user", content: String(prompt ?? "") }];

      const resp = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          authorization: `Bearer ${apiKey}`,
          "content-type": "application/json",
        },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          temperature: 0.4,
          messages: chatMessages,
        }),
      });

      if (!resp.ok) {
        const errText = await resp.text().catch(() => "");
        logger.error("OpenAI error", { status: resp.status, errText });
        return json(res, 502, { error: "Upstream model error", status: resp.status });
      }

      const data = await resp.json();
      const outputText =
        data?.choices?.[0]?.message?.content ??
        data?.choices?.[0]?.text ??
        "";

      return json(res, 200, {
        mocked: false,
        model: data?.model ?? "unknown",
        output_text: outputText,
        raw: { id: data?.id },
      });
    } catch (e) {
      logger.error("chat function failed", e);
      return json(res, 500, { error: "Internal error" });
    }
  }
);

