---
name: progress
description: "Launch a web dashboard to view Ralph's progress in real time. Use when you want to see how Ralph is doing, check story status, or monitor an ongoing run. Triggers on: show progress, view progress, open progress dashboard, ralph status."
user-invocable: true
---

# Ralph Progress Dashboard

Launch a web dashboard that reads the project's `prd.json` and `progress.txt`.

---

## The Job

1. Copy `progress-dashboard.html` from this skill's assets to the project root
2. Start a local HTTP server on port 8420
3. Open the dashboard in the browser

---

## Step 1: Copy Dashboard

Copy the dashboard HTML to the project root:

```bash
cp "$HOME/.claude/skills/progress/assets/progress-dashboard.html" ./progress-dashboard.html
```

---

## Step 2: Start the Server

```bash
# macOS
open http://localhost:8420/progress-dashboard.html & python3 -m http.server 8420

# Linux
xdg-open http://localhost:8420/progress-dashboard.html & python3 -m http.server 8420
```

If port 8420 is in use, try 8421, 8422, etc.

Tell the user the URL and that Ctrl+C stops the server.

---

## What It Shows

- **Three-column layout**: Completed (green) | In Progress (amber) | Up Next (gray)
- Each task shows ID, title, description, acceptance criteria, notes
- Progress bar at the top
- Recent activity from `progress.txt`
- Auto-refresh every 5 seconds

---

## Checklist

- [ ] Copied progress-dashboard.html to project root
- [ ] Started HTTP server
- [ ] Opened browser to dashboard URL
- [ ] Told user the URL
