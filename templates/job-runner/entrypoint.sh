#!/bin/bash
set -x

echo ""
echo "Starting cron."
echo ""
cron

# run entrypoint as job_runner
exec gosu job_runner tini -v -- /usr/local/bin/liferay_job_runner_entrypoint.sh