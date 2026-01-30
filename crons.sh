#!/bin/bash

openclaw cron add  \
  --name "Daily Session Review"  \
  --cron "0 23 * * *"  \
  --tz "America/Chicago"  \
  --session isolated  \
  --wake now  \
  --deliver  \
  --message "Review all sessions from the last 24 hours for each agent individually. For each session, extract: 1) Key learnings and patterns, 2) Mistakes or gotchas to avoid, 3) User preferences discovered, 4) Unfinished items. Update MEMORY.md with a summary. Update memory/YYYY-MM-DD.md with details. Commit changes to git and push. Report what was updated to @lukeshay1 on Telegram."

openclaw cron add  \
  --name "Daily Audit"  \
  --cron "0 5 * * *"  \
  --tz "America/Chicago"  \
  --session isolated  \
  --wake now  \
  --deliver  \
  --message "Run daily auto-updates: check for Openclaw updates and update all skills. Report what was updated to @lukeshay1 on Telegram."

openclaw cron add  \
  --name "Daily Audit"  \
  --cron "30 5 * * *"  \
  --tz "America/Chicago"  \
  --session isolated  \
  --wake now  \
  --deliver  \
  --message "Run openclaw doctor and openclaw security audit --deep. Send the summary of the results to @lukeshay1 on Telegram."