# Meeting Intelligence Pipeline

Automatically transforms meeting transcripts into structured action items, Trello cards, and a saved Google Drive report — eliminating the manual work of post-meeting follow-up.

---

## Problem It Solves

After meetings, action items get lost, notes stay unorganized, and follow-through falls through the cracks. This pipeline turns a raw transcript into organized outputs the moment a meeting ends.

---

## How It Works

```
Fireflies Webhook → Parse Payload → Claude AI Analysis → Parse AI Response
                                                               ↓
                                           ┌───────────────────┴────────────────────┐
                                    Split Action Items                    Build Document Content
                                           ↓                                         ↓
                                    Create Trello Cards                   Save to Google Drive
                                           └───────────────────┬────────────────────┘
                                                        Pipeline Complete
```

1. **Fireflies.ai** sends a webhook when a meeting transcript is ready
2. **Parse Payload** extracts meeting title, transcript, attendees, and date
3. **Claude AI** analyzes the transcript and returns structured JSON: summary, decisions, action items (with owner + priority + due date), blockers, and next meeting topics
4. **Split Action Items** fans out each action item into its own execution path
5. **Create Trello Cards** creates one card per action item with full context in the description
6. **Build Document Content** formats a complete meeting intelligence report
7. **Save to Google Drive** archives the report as a timestamped text file

---

## Integrations

| Tool | Purpose |
|---|---|
| Fireflies.ai | Meeting transcription, webhook trigger |
| Anthropic Claude API | AI extraction of action items, decisions, summary |
| Trello | Task card creation per action item |
| Google Drive | Meeting report archival |

---

## Key Technical Details

- Claude prompt returns strict JSON — no markdown, no preamble — parsed safely with a try/catch fallback
- Action items include: task description, owner, due date, and priority (High/Medium/Low)
- Handles empty transcripts and missing fields gracefully
- Trello cards include meeting context (title, date, owner, priority) in the card description
- Google Drive file naming: `Meeting Notes - [Title] - [Date].txt`

---

## Sample Output

**Claude AI extracts:**
```json
{
  "summary": "Team aligned on Q3 launch timeline. Three blockers identified around design review.",
  "key_decisions": ["Launch pushed to Aug 15", "Design sign-off required before dev handoff"],
  "action_items": [
    { "task": "Complete design mockups for checkout flow", "owner": "Sarah", "due_date": "July 28", "priority": "High" },
    { "task": "Schedule stakeholder review meeting", "owner": "XON", "due_date": "July 25", "priority": "Medium" }
  ],
  "blockers": ["Waiting on legal review of terms copy"],
  "next_meeting_topics": ["Design review sign-off", "Dev sprint planning"]
}
```

---

## Setup Requirements

1. Fireflies.ai account (paid plan for webhooks) — or use the manual Form Trigger alternative
2. Anthropic API key (HTTP Header Auth credential in n8n)
3. Trello account + target List ID
4. Google Drive OAuth2 credential + target Folder ID
