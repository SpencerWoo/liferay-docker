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

## GCP

```
export GCP_PROJECT=sage-passkey-359001
```

* create shared PD
`gcloud beta compute disks create orca-pd --project=$GCP_PROJECT --type=pd-ssd --size=100GB --zone=us-west1-b --multi-writer`

* create two ubuntu VMs
```
gcloud compute instances create orca-1 --project=$GCP_PROJECT --zone=us-west1-b --machine-type=n2-standard-2 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=148264713778-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=orca-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20220902,mode=rw,size=10,type=projects/sage-passkey-359001/zones/us-west4-b/diskTypes/pd-balanced --disk=boot=no,device-name=orca-pd,mode=rw,name=orca-pd --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

gcloud compute instances create orca-2 --project=$GCP_PROJECT --zone=us-west1-b --machine-type=n2-standard-2 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=148264713778-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=orca-2,image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20220902,mode=rw,size=10,type=projects/sage-passkey-359001/zones/us-west4-b/diskTypes/pd-balanced --disk=boot=no,device-name=orca-pd,mode=rw,name=orca-pd --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
```

* setup orca in both VMs
```
curl https://raw.githubusercontent.com/liferay/liferay-docker/master/orca/scripts/install_orca.sh -o /tmp/install_orca.sh
./tmp/install_orca.sh

export MOUNT_DIR=/opt/gluster-data/gv0
export DEVICE_NAME=sdb

sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DEVICE_NAME

sudo mkdir -p /mnt/disks/$MOUNT_DIR
sudo mkdir -p $MOUNT_DIR
sudo mount -o discard,defaults /dev/$DEVICE_NAME /mnt/disks/$MOUNT_DIR
sudo chmod a+w /mnt/disks/$MOUNT_DIR

orca install
```

* copy liferay-license to VM
```
gcloud compute scp activation-key-dxpdevelopment-7.4-liferaymanagedit.xml orca-1:/tmp/liferay-license.xml
mv /tmp/liferay-license.xml /opt/liferay/orca/orca/configs/
```

* mount PD

* download orca
`curl https://raw.githubusercontent.com/liferay/liferay-docker/master/orca/scripts/install_orca.sh -o /tmp/install_orca.sh`

* orca
```
orca all
orca up
```