# Content Repurposing Pipeline (with Buffer)

Takes a single piece of long-form content and automatically generates platform-optimized posts for LinkedIn (×3), Twitter/X (×5), and an email newsletter — then optionally schedules them via Buffer or sends drafts to Slack.

---

## Problem It Solves

Creating content for multiple platforms is time-consuming and inconsistent. This pipeline turns one article or blog post into a full week of social content in under 60 seconds.

---

## How It Works

```
n8n Form Trigger → Parse Input → Claude AI → Parse AI Response → Route: Buffer or Slack?
                                                                         ↓ Yes (Buffer)
                                                              Prepare LinkedIn Posts → Schedule via Buffer
                                                              Prepare Tweets → Schedule via Buffer
                                                                         ↓ No (Slack only)
                                                                   Build Slack Message → Send to Slack
                                                                         ↓ (always)
                                                               Build Drive Document → Save to Google Drive
                                                                         ↓
                                                                  Pipeline Complete
```

1. **Form Trigger** collects: content title, full text, niche (dropdown), target audience, and whether to post via Buffer
2. **Claude AI** generates 3 LinkedIn posts (each with hook, body, CTA, hashtags), 5 tweets, and a full email newsletter (subject, preview, body, takeaways, outro)
3. **Routing node** checks if Buffer scheduling was selected
4. **Buffer path:** LinkedIn posts staggered 2 days apart; tweets staggered 1 day apart
5. **Slack path:** All content bundled into a single formatted Slack message as a draft for review
6. **Google Drive:** Full content report saved regardless of routing choice

---

## Integrations

| Tool | Purpose |
|---|---|
| Anthropic Claude API | Multi-format content generation |
| Buffer | Automated social media scheduling (LinkedIn + Twitter/X) |
| Slack | Draft delivery for review before posting |
| Google Drive | Content archive with all generated formats |

---

## Key Technical Details

- Claude prompt enforces strict JSON output with all 4 content types in one API call
- Niche dropdown (Project Management, Tech & Automation, Business, Career) shapes AI tone and framing
- Buffer posts auto-stagger: LinkedIn every 2 days, tweets every 1 day
- Per-run choice to schedule or draft — no workflow edit required
- All content (LinkedIn + tweets + newsletter) archived to Drive as a single timestamped report
- Slack message uses full Slack markdown formatting for clean readability

---

## Content Niches Supported

- Project Management & Leadership
- Tech & Automation
- Business & Entrepreneurship
- Career & Personal Development

---

## Sample Output (per run)

- **3 LinkedIn posts** — different angles: storytelling, insight, actionable takeaway
- **5 tweets** — punchy insight, contrarian take, actionable tip, stat framing, storytelling hook
- **1 email newsletter** — subject line, preview text, body (3 paragraphs), 3 key takeaways, outro

---

## Setup Requirements

1. Anthropic API key (HTTP Header Auth credential in n8n)
2. Buffer account (free tier) + Access Token + LinkedIn and Twitter Profile IDs
3. Slack OAuth2 credential + target Channel ID
4. Google Drive OAuth2 credential + target Folder ID
