#!/bin/bash

function init {
	. /usr/local/bin/set_java_version.sh

	mkdir --parents /opt/liferay/job-queue
}

function main {
	init

	register_crontab

	cron
}

function register_crontab {
	if [ ! -e /mnt/liferay/job-crontab ]
	then
		echo "The file /mnt/liferay/job-crontab does not exist."

		exit 2
	fi

	(
		crontab -l 2>/dev/null

		cat /mnt/liferay/job-crontab | envsubst
	) | crontab -

	echo "Registered crontab: "

	crontab -l

	echo ""
}

main