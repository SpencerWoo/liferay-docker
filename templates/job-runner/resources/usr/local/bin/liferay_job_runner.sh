#!/bin/bash

function main {
	run_jobs
}

function run_jobs {
	while true
	do
		if [ $(ls /opt/liferay/job-queue | wc --lines) -gt 0 ]
		then
			local job=$(ls --reverse --sort='time' /opt/liferay/job-queue | head --lines=1)

			rm "/opt/liferay/job-queue/${job}"

			job_wrapper.sh "${job}"
		else
			sleep 10
		fi
	done
}

main