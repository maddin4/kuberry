TGT_DEVICE=$(lsblk -S | sed -n '3,3p' | sed 's/ .*//')
TGT_SIZE=$(lsblk -b | grep "^$TGT_DEVICE" | awk '{printf "+%.fG\n", ($4/2)/1024/1024/1024 - 1}')
echo $TGT_DEVICE
echo $TGT_SIZE

sudo umount tgt_root_1 || { echo "umount failed but not to worry" ; : ; } 
sudo umount tgt_root_2 || { echo "umount failed but not to worry" ; : ; } 

sudo sfdisk --delete /dev/$TGT_DEVICE

(
echo n # NEW partition 1
echo p # NEW primary partition 1
echo 1 # NEW primary partition 1
echo  # NEW primary partition 1 first sector
echo $TGT_SIZE # NEW primary partition 1 new size
echo n # NEW partition 2
echo p # NEW primary partition 2
echo 2 # NEW primary partition 2
echo  # NEW primary partition 1 first sector
echo $TGT_SIZE # NEW primary partition 1 new size
echo w # Write changes
) | sudo fdisk -W always /dev/$TGT_DEVICE

sudo partprobe

sudo mkfs.ext4 /dev/$TGT_DEVICE'1'
sudo mkfs.ext4 /dev/$TGT_DEVICE'2'

#PREPARE sync the os to the root folders
sudo mkdir -p tgt_root_1
sudo mkdir -p tgt_root_2
sudo mount /dev/$TGT_DEVICE'1' tgt_root_1
sudo mount /dev/$TGT_DEVICE'2' tgt_root_2

#sync the os to the root folders
sudo rsync -qaHAXS root_source/ tgt_root_1 &
sudo rsync -qaHAXS root_source/ tgt_root_2


#Partitionen labeln:
sudo e2label /dev/$TGT_DEVICE'1' ROOT1
sudo e2label /dev/$TGT_DEVICE'2' ROOT2

#edit tgt_root_1/etc/fstab:
sudo su -c "echo 'LABEL=ROOT1 / ext4 defaults 0 0' >> tgt_root_1/etc/fstab"
sudo su -c "sudo echo 'LABEL=ROOT2 /other_root ext4 defaults 0 0' > tgt_root_1/etc/fstab"


#edit tgt_root_2/etc/fstab:
sudo su -c "echo 'LABEL=ROOT1 /other_root ext4 defaults 0 0' >> tgt_root_2/etc/fstab"
sudo su -c "sudo echo 'LABEL=ROOT2 / ext4 defaults 0 0' > tgt_root_2/etc/fstab"

sudo cp tgt_root_1/etc/cloud/cloud.cfg tgt_root_1/etc/cloud/cloud.cfg_bkp
sudo cp tgt_root_2/etc/cloud/cloud.cfg tgt_root_2/etc/cloud/cloud.cfg_bkp

sudo su -c "cat initusr.cfg >> tgt_root_1/etc/cloud/cloud.cfg"
sudo su -c "cat initusr.cfg >> tgt_root_2/etc/cloud/cloud.cfg"

sudo umount tgt_root_1
sudo umount tgt_root_2

