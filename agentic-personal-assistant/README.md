# Agentic Personal Assistant Pipeline

A conversational AI assistant accessible via Telegram that can read emails, check your calendar, manage tasks, and send emails — all through natural language voice or text messages.

---

## Problem It Solves

Switching between Gmail, Google Calendar, and task apps to stay on top of your day is fragmented and slow. This pipeline puts a single intelligent assistant in your Telegram that understands context, remembers the conversation, and takes action across your tools.

---

## How It Works

```
Telegram Trigger → Voice or Text? → [Voice] → Get Voice File → Transcribe (Whisper)
                                                                        ↓
                                  → [Text] ──────────────────────────→ AI Agent (Faith)
                                                                        ↓
                                                          Tools: Gmail | Calendar | Tasks
                                                                        ↓
                                                              Telegram Reply
```

1. **Telegram Trigger** listens for incoming messages (text or voice)
2. **Routing node** checks if the message is a voice note or text
3. **Voice path:** Downloads the voice file from Telegram → transcribes with OpenAI Whisper
4. **AI Agent ("Faith")** receives the text and decides which tools to call
5. **Tools available to the agent:**
   - Read unread Gmail emails (with date filters)
   - Send Gmail emails (HTML formatted)
   - Get Google Calendar events (with date range filters)
   - Create tasks in Google Tasks
   - Retrieve task list from Google Tasks
6. **Window Buffer Memory** maintains conversation context across messages in the same session
7. **Telegram** sends the agent's response back to the user

---

## Integrations

| Tool | Purpose |
|---|---|
| Telegram | User interface (voice + text input, response delivery) |
| OpenRouter (Llama 3.1 8B) | LLM powering the AI agent |
| OpenAI Whisper | Voice-to-text transcription |
| Gmail | Read emails + send emails as tools |
| Google Calendar | Fetch calendar events as a tool |
| Google Tasks | Create and retrieve tasks as tools |

---

## Key Technical Details

- Uses n8n's LangChain AI Agent node with tool-calling capability
- Window Buffer Memory scoped to Telegram user ID — each user gets their own conversation context
- Voice messages handled end-to-end: Telegram file download → Whisper transcription → agent input
- Agent system prompt includes today's date and rules for email summarization format (Sender, Date, Subject, Summary)
- Calendar filtering: agent told to exclude events more than 1 week away unless explicitly asked
- Email sending uses HTML formatting for clean output

---

## Example Interactions

> **"What emails did I get today?"**
> → Agent fetches unread inbox, summarizes each with sender, date, subject, and brief summary

> **"What's on my calendar tomorrow?"**
> → Agent queries Google Calendar for next day's events only

> **"Create a task: Review Q3 budget by Friday"**
> → Agent creates a new task in Google Tasks

> **"Send an email to [name] about the meeting postponement"**
> → Agent composes and sends an HTML-formatted email via Gmail

---

## Setup Requirements

1. Telegram Bot Token (create via @BotFather)
2. OpenRouter API key + model: `meta-llama/llama-3.1-8b-instruct`
3. OpenAI API key (for Whisper transcription)
4. Gmail OAuth2 credential
5. Google Calendar OAuth2 credential
6. Google Tasks OAuth2 credential
