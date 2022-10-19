# this script configures a GCP VM with the necessary requirements

export GCP_PROJECT=sage-passkey-359001

export MOUNT_DIR=/opt/gluster-data/gv0
export DEVICE_NAME=sdb

sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DEVICE_NAME

sudo mkdir -p /mnt/disks/$MOUNT_DIR
sudo mkdir -p $MOUNT_DIR
sudo mount -o discard,defaults /dev/$DEVICE_NAME /mnt/disks/$MOUNT_DIR
sudo chmod a+w /mnt/disks/$MOUNT_DIR

orca setup_shared_volume
orca install

install -d -m 0755 -o 1001 /opt/liferay/db-data
install -d -m 0755 -o 1000 /opt/liferay/jenkins-home
install -d -m 0755 -o 1000 /opt/liferay/shared-volume
# install -d -m 0755 -o 1000 /opt/liferay/vault

install -d -m 0755 -o 1000 /opt/liferay/vault/data
install -d -m 0755 -o 1000 /opt/liferay/shared-volume/document-library
install -d -m 0755 -o 1000 /opt/liferay/shared-volume/secrets

# local backup="/opt/liferay/shared-volume/secrets/mysql_backup_password.txt"
# local liferay="/opt/liferay/shared-volume/secrets/mysql_liferay_password.txt"
# local root="/opt/liferay/shared-volume/secrets/mysql_root_password.txt"

# touch "${backup}" "${liferay}" "${root}"

# echo "tmp" | tee "${backup}" "${liferay}" "${root}"

# chmod 644 "${backup}" "${liferay}" "${root}"
# chown 1000:1000 "${backup}" "${liferay}" "${root}"

sysctl -w vm.max_map_count=262144
