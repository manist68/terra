#!/bin/bash
while [ `ls -l /dev/disk/azure/scsi1 | grep lun10 | wc -l` -lt 1 ]; do echo waiting on disks...; sleep 5; done
str=$(ls -l /dev/disk/azure/scsi1 | grep lun10)
drive=${str: -1}
#drive="c"
sudo parted /dev/sd${drive} --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo mkfs.xfs /dev/sd${drive}1
sudo partprobe /dev/sd${drive}1
sudo mkdir -p /datadrive
sudo mount /dev/sd${drive}1 /datadrive
sudo echo UUID=\"`(blkid /dev/sd${drive}1 -s UUID -o value)`\" /datadrive       xfs     defaults,nofail         1       2 >> /etc/fstab
sudo chown azureuser:azureuser /datadrive

