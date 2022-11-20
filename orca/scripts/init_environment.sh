#!/bin/bash

function build_orca {
	echo "====="
	echo "Running: orca build latest"
	main build latest

	echo "====="
	echo "Running: orca all"
	main all
}
function create_directories {
	echo "====="
	echo "Creating directories"
	# functionalize these
	install -d -m 0755 -o 1001 /opt/liferay/db-data
	install -d -m 0755 -o 1001 /opt/liferay/monitoring-proxy-db-data

	install -d -m 0755 -o 1000 /opt/liferay/jenkins-home
	install -d -m 0755 -o 1000 /opt/liferay/vault/data

	install -d -m 0755 -o 1000 /opt/liferay/shared-volume
	install -d -m 0755 -o 1000 /opt/liferay/shared-volume/secrets
	install -d -m 0755 -o 1000 /opt/liferay/shared-volume/document-library
}

function create_vault {
	echo "====="
	echo "Starting vault"
	main up -d vault

	echo "====="
	echo "Configuring vault"
	docker exec vault bash -c ". /usr/local/bin/init_operator.sh" &> init.out
}

function unseal_vault {
#	if [ ! -n "${ORCA_CONFIG}" ]
#	if [ -s ]
	local unseal_key=$(head -n 1 init.out | grep -oE '[^ ]+$')
	[[ -z "$unseal_key" ]] && { exit 1; }

	

	echo "${unseal_key}" | main unseal
}
}

function create_service_passwords {
	local root_token=$(head -n 3 init.out | grep -oE '[^ ]+$')

	[[ -z "root_token" ]] && { exit 1; }

	docker exec vault bash -c "export ORCA_VAULT_TOKEN=${root_token}"
	docker exec vault bash -c ". /usr/local/bin/init_secrets.sh" &> secrets.out

	while IFS= read -r line; do
		local service_directory=$(cat line | grep -oE '[^ ]+$')
		echo service_directory
#		install -d -m 0755 -o 1000 /opt/liferay/passwords/${service}
		install -d -m 0755 -o 1000 ${service_directory}

		local service_password=$(cat line | grep -oE '^.+[ $]')
		echo service_password
		echo ${service_password} > ${service_directory}
	done < secrets.out
}

function main {

	echo "1"

	build_orca

	create_directories

	# somehow check if orca install was successful

	create_vault

	unseal_vault

	create_service_passwords
#	. /usr/local/bin/init_operator.sh > o.out
#	touch test.txt
#
#	echo 'cat' > test.txt
}

main ${@}