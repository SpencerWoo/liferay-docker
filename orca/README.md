# Managed DXP - Orca

Simple default configuration to deploy Liferay DXP Clusters on Linux servers, only using simple tools.

## Ubuntu reqirements

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


## GCP Setup

We use alpha multi-writer persistent disk as the shared disk.
Therefore we use N2 Virtual Machines.  A limitation of trial is 8 N2 CPU quota as well as multi-writer PD max connection of 2.


```
export GCP_PROJECT=sage-passkey-359001
export GCP_ZONE=

gcloud auth login
gcloud config set project $GCP_PROJECT
```

* create shared PD
  `gcloud beta compute disks create orca-pd --project=$GCP_PROJECT --type=pd-ssd --size=100GB --zone=us-west1-b --multi-writer`

* create two ubuntu VMs
```

n2-standard-4

gcloud compute instances create orca-1 --project=$GCP_PROJECT --zone=us-west1-b --machine-type=n2-custom-6-49152 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=148264713778-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=orca-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20220928,mode=rw,size=10,type=projects/$GCP_PROJECT/zones/us-west4-b/diskTypes/pd-balanced --disk=boot=no,device-name=orca-pd,mode=rw,name=orca-pd --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

gcloud compute instances create orca-2 --project=$GCP_PROJECT --zone=us-west1-b --machine-type=n2-custom-2-11008 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=148264713778-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=orca-2,image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20220928,mode=rw,size=10,type=projects/$GCP_PROJECT/zones/us-west4-b/diskTypes/pd-balanced --disk=boot=no,device-name=orca-pd,mode=rw,name=orca-pd --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
```

* setup orca in both VMs
```
gcloud compute ssh --zone "us-west1-b" "orca-1"  --project $GCP_PROJECT
gcloud compute ssh --zone "us-west1-b" "orca-2"  --project $GCP_PROJECT

sudo su -

curl https://raw.githubusercontent.com/SpencerWoo/orca/master/scripts/install_orca.sh -o /tmp/install_orca.sh
curl https://raw.githubusercontent.com/liferay/liferay-docker/master/orca/scripts/install_orca.sh -o /tmp/install_orca.sh
. /tmp/install_orca.sh

export MOUNT_DIR=/opt/gluster-data/gv0
export DEVICE_NAME=sdb

sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DEVICE_NAME

sudo mkdir -p /mnt/disks/$MOUNT_DIR
sudo mkdir -p $MOUNT_DIR
sudo mount -o discard,defaults /dev/$DEVICE_NAME /mnt/disks/$MOUNT_DIR
sudo chmod a+w /mnt/disks/$MOUNT_DIR

orca setup_shared_volume
orca install
```

* connect gcluster in VM 1
```
export VM1=10.138.0.12
export VM2=10.138.0.13

gluster peer probe $VM2
gluster volume create gv0 replica 2 $VM1:/opt/gluster-data/gv0/ $VM2:/opt/gluster-data/gv0/ force
gluster volume start gv0
gluster volume info

mount /opt/liferay/shared-volume
```

* upload liferay-license to VM 1
```
gcloud compute scp activation-key-dxpdevelopment-7.4-liferaymanagedit.xml orca-1:/tmp/liferay-license.xml
mv /tmp/liferay-license.xml /opt/liferay/orca/configs/.
```

* run vault
```
orca up -d vault
orca ssh vault
./usr/local/bin/init_operator.sh
export ORCA_VAULT_TOKEN=

orca unseal
./usr/local/bin/init_secrets.sh

```

* run orca
```
orca all

sysctl -w vm.max_map_count=262144

orca up
```

* download logs from VM 1
```
chmod +r
gcloud compute scp --recurse orca-1:/opt/liferay/shared-volume/logs .
```

* troubleshoot
```
gcloud compute instances tail-serial-port-output orca-1
gcloud compute instances stop orca-1 --zone=us-west1-b
gcloud compute disks resize orac-1 --size=100GB

```