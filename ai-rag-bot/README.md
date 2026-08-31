# # RETRIEVAL AUGMENTED GENERATION - AI Support Bot

**Stack:** n8n · Claude API · Voyage AI · Supabase (pgvector) · Telegram

## The problem

Small businesses lose leads and time answering the same questions — pricing, product specs, availability — over and over on messaging apps. Off-the-shelf chatbots either can't answer from a business's actual pricing/catalog data, or require expensive per-message platforms to set up.

## What this is

An AI support assistant that answers customer questions on Telegram using a business's real pricing and product data — not a generic script, and not hallucinated answers.

The system has two parts:

**1. Knowledge base ingestion**
Business content (pricing tiers, FAQs, product specs) is chunked, converted into vector embeddings via Voyage AI, and stored in a Supabase (Postgres + pgvector) database. Runs whenever the knowledge base needs updating — no redeploy required.

**2. Live query pipeline**
When a customer messages the bot on Telegram, their question is embedded the same way and matched against the stored knowledge base via vector similarity search. The most relevant chunks are passed to Claude, which generates a grounded, on-brand reply. Questions outside the bot's confidence — pricing negotiation, complaints — are flagged for human handoff rather than answered blindly.

## Why this architecture

- **Retrieval-augmented generation (RAG)** means the bot answers from real business data, not just what Claude was trained on — critical for accuracy on pricing and specs that change over time.
- **Telegram over WhatsApp** for choice/test purposes, while keeping the same conversational UX.
- **Escalation logic** keeps the business in control: the bot handles routine questions and hands off anything it shouldn't answer alone.
- **Decoupled ingestion and retrieval** means updating the knowledge base (new pricing, new products) never requires touching the bot's logic.

## Architecture

```
Ingestion (offline, run on demand)
  Content source → Chunk & embed (Voyage AI) → Supabase (pgvector)

Live query (runs per customer message)
  Telegram message → Embed query (Voyage AI) → Supabase vector search
      → Claude API (generates reply) → Telegram reply
```

Both flows read/write the same Supabase `documents` table, so updating the knowledge base never requires touching the live bot.

## Repo contents

| File | Purpose |
|---|---|
| `supabase-setup.sql` | One-time Supabase setup — enables pgvector, creates the `documents` table and the `match_documents()` search function. Customizable per client (see comment in file). |
| `rag-01-ingest.json` | n8n workflow — chunks and embeds knowledge base content, stores it in Supabase |
| `rag-02-retrieve.json` | n8n workflow (sub-workflow) — embeds a query and retrieves the most relevant stored content |
| `telegram-ai-support.json` | n8n workflow — the live Telegram bot: receives messages, calls the retrieval sub-workflow, generates a reply via Claude, sends it back |

## Setup

1. Run `supabase-setup.sql` in your Supabase project's SQL Editor
2. Get API keys: [Voyage AI](https://dash.voyageai.com) (embeddings), [Anthropic Console](https://console.anthropic.com) (Claude API), and a Telegram bot token via [@BotFather](https://t.me/BotFather)
3. Import all three n8n workflows (`rag-01-ingest`, `rag-02-retrieve`, `telegram-ai-support`) into n8n, each as its own workflow
4. Wire up credentials on each HTTP/Telegram node (Voyage Auth, Supabase API, Anthropic API, Telegram API)
5. Run `rag-01-ingest` once with real content to populate the knowledge base
6. Test `rag-02-retrieve` standalone to confirm retrieval works
7. Activate `telegram-ai-support` and message the bot to test end-to-end

## Cost

Runs on free tiers for testing and low volume: Telegram is free, Supabase's free tier covers moderate content sizes, and Voyage/Claude usage-based pricing costs fractions of a cent per conversation. See the architecture notes for a full cost breakdown at scale.

## Status

Built and tested end-to-end: ingestion, retrieval, and live Telegram response confirmed working.
