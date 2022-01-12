Setting it up...
================
1. Raspooter

a. Burn image of current 64-bit ubuntu OS (21.10 is working) to SSD
b. mount the boot partition and set the new user-data file
c. add storage-quirks to cmdline.txt usb-storage.quirks=152d:1561:u 
d. umount
e. plug SSD to new raspooter and boot
f. call ansible script to initialize raspooter
ansible-playbook -i raspooter/inventory.txt raspooter/1_setup-raspooter.yaml