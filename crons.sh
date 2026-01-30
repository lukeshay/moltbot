#!/bin/bash

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