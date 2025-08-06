#!/bin/bash

# run job_runner setup script as root
bash /usr/local/bin/liferay_job_runner_setup.sh

# run job_runner entrypoint as job_runner
exec gosu job_runner tini -v -- /usr/local/bin/liferay_job_runner.sh
