# AI Sprint Planner (with Jira)

Takes a plain English product requirement and automatically generates 
a structured sprint plan; creating Epics, Stories, and Subtasks 
directly in your Jira project in under 60 seconds.

## Problem It Solves
Writing Jira tickets manually is slow, inconsistent, and often skipped. 
This pipeline turns a one paragraph requirement into a fully populated 
Jira board ready for your team to start working with no ticket writing needed.

## How It Works
n8n Form Trigger → Call Claude API → Parse AI Response → Create Epics in Jira
                                                                ↓
                                                      Prepare Stories → Create Stories in Jira
                                                                ↓
                                                      Prepare Subtasks → Create Subtasks in Jira
                                                                ↓
                                                         Build Summary → Form Ending

- Form Trigger collects: project name, Jira project key, and plain English requirement
- Claude AI generates up to 3 epics, 3 stories per epic, and 4 subtasks per story in strict JSON
- n8n parses the JSON and loops through each level of the hierarchy
- Jira API creates all tickets in the correct parent-child structure automatically
- Form Ending confirms successful creation to the user

## Integrations
| Tool               | Purpose                                      |
|--------------------|----------------------------------------------|
| Anthropic Claude API | AI-powered sprint breakdown into JSON      |
| Jira Cloud API     | Automated ticket creation (Epic/Story/Subtask)|
| n8n Form           | User input trigger and confirmation response |

## Key Technical Details
- Claude prompt enforces strict JSON output with epics, stories, and subtasks in one API call
- Jira tickets are created sequentially — epic key passed to stories, story key passed to subtasks
- Epic Link field (customfield_10014) used to link stories to their parent epic
- Subtasks linked to parent story via the `parent.key` field in Jira REST API v3
- Works with any Jira Cloud project — just provide the project key at runtime

## Sample Output (per run)
- 3 Epics — high-level feature groupings
- Up to 9 Stories — user-facing functionality broken down per epic
- Up to 36 Subtasks — granular technical tasks per story

