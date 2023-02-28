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



#NODE.js
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs

# #MONGOdb
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
# echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
# sudo apt update && sudo apt install -y mongodb-org

#java
sudo apt install openjdk-8-jdk-headless 

#NGINX
sudo apt-get install nginx
sudo ufw enable
sudo ufw app list
sudo ufw allow ‘Nginx Full’
sudo ufw allow OpenSSH


#Mongo

# mkdir mongodb
# cd mongodb

# curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.4.7.tgz
# tar xvf mongodb-linux-x86_64-3.4.7.tgz

# mv mongodb-linux-x86_64-3.4.7 mongodb
# cd mongodb
# echo $PATH
# export PATH=$PATH:/home/journal/mongodb/mongodb/bin

# mkdir data
# cd bin
# ./mongod --dbpath /home/journal/mongodb/mongodb/data 

# ps -eaf | grep mongo


echo Finished Installing Programs!
