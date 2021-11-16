

IMAGE=ubuntu-20.04.2-preinstalled-server-arm64+raspi.img


if [ ! -e $IMAGE ]; then 
	echo "Image not found!"; 
	# get the image
	wget https://cdimage.ubuntu.com/releases/20.04.2/release/$IMAGE.xz
	# decompress:
	xz --decompress $IMAGE.xz
else 
	echo "Image found"; 
fi

# grab mount points
START_BOOT=$(sfdisk -l ubuntu-20.04.2-preinstalled-server-arm64+raspi.img -o Start | sed '0,/^ Start$/d' | sed -n '1p')
START_ROOT=$(sfdisk -l ubuntu-20.04.2-preinstalled-server-arm64+raspi.img -o Start | sed '0,/^ Start$/d' | sed -n '2p')

echo $START_BOOT
echo $START_ROOT

START_BOOT_OFFSET=$(( 512 * START_BOOT ))
START_ROOT_OFFSET=$(( 512 * START_ROOT ))

echo $START_BOOT_OFFSET
echo $START_ROOT_OFFSET

sudo mount $IMAGE -o loop,offset=$START_BOOT_OFFSET localboot/boot_source/
sudo mount $IMAGE -o loop,offset=$START_ROOT_OFFSET localroot/root_source/

