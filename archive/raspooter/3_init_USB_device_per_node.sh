# initialize the USB-drive
# create two partitions to be used for os-updates

# get the target block device, must be the second USB drive on raspooter
# the first one is the HDD raspooter is booted from 
TGT_DEVICE=$(lsblk -S | sed -n '3,3p' | sed 's/ .*//')
TGT_SIZE=$(lsblk /dev/$TGT_DEVICE -b | sed -n '2,2p' | awk '{printf "+%.fG\n", ($4/2)/1024/1024/1024 - 1}')
echo "will prepare: " $TGT_DEVICE " with partitions of size " $TGT_SIZE 

# just to make sure...
sudo umount /kuberry/tgt_root_1 || { echo "umount failed but not to worry" ; : ; } 
sudo umount /kuberry/tgt_root_2 || { echo "umount failed but not to worry" ; : ; } 

# PREPARE sync the os to the root folders
sudo mkdir -p /kuberry/tgt_root_1
sudo mkdir -p /kuberry/tgt_root_2
echo "tgt roots created"

# remove any partitiontables from the target device
sudo sfdisk --delete /dev/$TGT_DEVICE
echo "partitions deleted" 

# use fdisk to create the new partitions
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
echo "partitions created" 

## propagate partitiontable changes to OS
sudo partprobe

# label the partitions
sudo e2label /dev/$TGT_DEVICE'1' ROOT_KUBERRY
sudo e2label /dev/$TGT_DEVICE'2' ROOT_OPS
echo "labels are set"

# create filesystems on both partitions
sudo mkfs.ext4 /dev/$TGT_DEVICE'1' &
sudo mkfs.ext4 /dev/$TGT_DEVICE'2'
echo "filesystems created" 

sudo partprobe

sudo mount /dev/$TGT_DEVICE'1' /kuberry/tgt_root_1
sudo mount /dev/$TGT_DEVICE'2' /kuberry/tgt_root_2
echo "mounts created"

# SYNC OS from image to the new partitions
sudo rsync -qaHAXS /kuberry/root_source/ /kuberry/tgt_root_1 &
sudo rsync -qaHAXS /kuberry/root_source/ /kuberry/tgt_root_2
echo "sync is done"


#edit tgt_root_1/etc/fstab:
sudo su -c "echo 'LABEL=ROOT_KUBERRY / ext4 defaults 0 0' > /kuberry/tgt_root_1/etc/fstab"
sudo su -c "sudo echo 'LABEL=ROOT_OPS /ops_root ext4 defaults 0 0' >> /kuberry/tgt_root_1/etc/fstab"

# edit tgt_root_2/etc/fstab:
sudo su -c "echo 'LABEL=ROOT_KUBERRY /kuberry_root ext4 defaults 0 0' > /kuberry/tgt_root_2/etc/fstab"
sudo su -c "sudo echo 'LABEL=ROOT_OPS / ext4 defaults 0 0' >> /kuberry/tgt_root_2/etc/fstab"
echo "fstabs configured"

# cleanup
sudo umount /kuberry/tgt_root_1
sudo umount /kuberry/tgt_root_2
echo "umount done"


# TODO for network-boot
# sudo cp -r /kuberry/boot_source/* /tftpboot/aa0c004d/

# decompress the kernel
# zcat -qf "/mnt/boot/vmlinuz" > "/mnt/boot/vmlinux"

# config.txt
#[pi4]
#max_framebuffers=2
#dtoverlay=vc4-fkms-v3d
#boot_delay
#kernel=vmlinux
#initramfs initrd.img followkernel
#arm_64bit=1

# cmdline.txt
# usb-storage.quirks=090c:1000:u dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=LABEL=ROOT_KUBBERY rootfstype=ext4 elevator=deadline rootwait fixrtc
