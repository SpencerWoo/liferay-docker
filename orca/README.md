# Managed DXP - Orca

Simple default configuration to deploy Liferay DXP Clusters on Linux servers, only using simple tools.

# Requirements

## Ubuntu

Create a new mounted filesystem (xfs recommended) to /opt/gluster-data/gv0

Execute the following commands on all servers:

    $ curl https://raw.githubusercontent.com/liferay/liferay-docker/master/orca/scripts/install_orca.sh -o /tmp/install_orca.sh
    $ . /tmp/install_orca.sh

Then log in to the first server and execute the following:

    $ gluster peer probe <host-name of the second server>
    $ gluster peer probe <host-name of the third server>
    $ ...
    $ gluster volume create gv0 replica 3 <vm-1>:/opt/gluster-data/gv0/ <vm-2>:/opt/gluster-data/gv0/ <vm-3>:/opt/gluster-data/gv0/
    $ gluster volume start gv0
    $ gluster volume info
    $ mount /opt/liferay/shared-volume

## Vault

Setup the vault service on the host

	orca up -d vault

SSH into the vault container to init

	orca ssh vault
	. /usr/local/bin/init_operator.sh

On the host unseal the vault

	orca unseal

SSH into the vault container to generate secrets

	orca ssh vault
	. /usr/local/bin/init_secrets.sh

On the host create the following files with the relevant secrets:

	/opt/liferay/passwords/BACKUP
	/opt/liferay/passwords/DB
	/opt/liferay/passwords/LIFERAY

# Usage

1. [Install ORCA](#ubuntu)
2. [Setup Vault](#vault)
3. `orca build latest`
4. `orca all`
5. `orca up`