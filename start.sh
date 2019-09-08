#!/bin/bash +x
 
loadkeys ru

#DIR="/sys/firmware/efi/"
#
#if [[ "$(ls -A $DIR)" ]]; then
#	echo "[+] EFI OK"
#else
#	echo "[-] EFI not exist"
#fi

echo "Check internet connection."
 
ping -c 1 ya.ru &> /dev/null

if [[ $? -eq 0 ]]; then
	    echo -e "\033[37;1;42m[+]OK Online.\033[0m"
    else
	        echo -e "\033[37;1;43m[-]FAILED Offline link down.\033[0m"
fi
 
timedatectl set-ntp true
 
echo "
                		 Select block device.				     
"
				     
lsblk -d /dev/sd* | awk '{ print $1 "\t" $4 "\t" $6 "\t" $7 }'

echo -e "Enter you choice (for example: \033[37;1;43msda\033[0m): "
read
os_device=$REPLY

parted /dev/$os_device mklabel gpt
parted /dev/$os_device mkpart boot 1mib 261mib
parted /dev/$os_device set 1 esp on
parted /dev/$os_device mkpart / 262mib 30GIB
parted /dev/$os_device mkpart home 30GIB 100%
mkfs.fat -F 32 /dev/$os_device"1"
mkfs.ext4 /dev/$os_device"2"
mkfs.ext4 /dev/$os_device"3"

mount /dev/$os_device"2" /mnt
mkdir /mnt/{boot,home}
mount /dev/$os_device"1" /mnt/boot/
mount /dev/$os_device"3" /mnt/home

mirror_server=$(grep yandex /etc/pacman.d/mirrorlist)

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sed -i "1i $mirror_server" /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
cd /mnt/home
curl -fsSL https://raw.githubusercontent.com/NKTJVKTU/Automatic-Arch-install/master/Install2.sh -o continue.sh
chmod +x /mnt/home/continue.sh

arch-chroot /mnt /home/./continue.sh |& tee continue.log
#____________________END OF PART ONE
