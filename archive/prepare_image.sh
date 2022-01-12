

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
START_BOOT=$(sfdisk -l ubuntu-20.04.1-preinstalled-server-arm64+raspi.img -o Start | sed '0,/^ Start$/d' | sed -n '1p')
START_ROOT=$(sfdisk -l ubuntu-20.04.1-preinstalled-server-arm64+raspi.img -o Start | sed '0,/^ Start$/d' | sed -n '2p')

BOOT_SIZE_LIMIT=$(fdisk --bytes -lo Size ubuntu-20.04.1-preinstalled-server-arm64+raspi.img | sed -n '9p')
ROOT_SIZE_LIMIT=$(fdisk --bytes -lo Size ubuntu-20.04.1-preinstalled-server-arm64+raspi.img | sed -n '10p')

sudo mkdir -p localboot/boot_source
sudo mkdir -p localroot/root_source
sudo mount $IMAGE -o loop,offset=$(( 512 * $START_BOOT )),sizelimit=$(( 1 * $BOOT_SIZE_LIMIT )) /kuberry/boot_source/
sudo mount $IMAGE -o loop,offset=$(( 512 * $START_ROOT )),sizelimit=$(( 1 * $ROOT_SIZE_LIMIT )) /kuberry/root_source/

