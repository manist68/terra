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

cd /datadrive; wget "https://naiglobalstrg.blob.core.windows.net/psfiles/all.tar.gz"; tar xf all.tar.gz
cd /datadrive/; wget "https://sinkstrgadf.blob.core.windows.net/sink/bashrc_set4.sh"
cd /datadrive/; wget "https://sinkstrgadf.blob.core.windows.net/sink/extractfile_mani.sh"


cd /datadrive/; chmod -R 777 extractfile_mani.sh; ./extractfile_mani.sh
sleep 5

sleep 5
echo "KAFKA_BROKER=node1:9092"
echo "KAFKA_BROKER=node1:9092" >> ~/.profile

echo "PATH=$PATH:$NODE_HOME/bin"
echo "PATH=$PATH:$NODE_HOME/bin" >> ~/.profile

echo "MONGO_HOME=/datadrive/mongodb-linux-x86_64-ubuntu1604-4.2.8"
echo "MONGO_HOME=/datadrive/mongodb-linux-x86_64-ubuntu1604-4.2.8" >> ~/.profile

echo "PATH=$PATH:$MONGO_HOME/bin"
echo "PATH=$PATH:$MONGO_HOME/bin" >> ~/.profile

echo "JAVA_HOME=/datadrive/jdk1.8.0_144"
echo "JAVA_HOME=/datadrive/jdk1.8.0_144" >> ~/.profile

echo "PATH=$PATH:$JAVA_HOME/bin/"
echo "PATH=$PATH:$JAVA_HOME/bin/" >> ~/.profile

echo "KAFKA_HOME=/datadrive/kafka_2.12-2.6.0"
echo "KAFKA_HOME=/datadrive/kafka_2.12-2.6.0" >> ~/.profile

echo "PATH=$PATH:/datadrive/kafka_2.12-2.6.0/bin"
echo "PATH=$PATH:/datadrive/kafka_2.12-2.6.0/bin" >> ~/.profile

sleep 3

source ~/.profile

sleep 3

cd /datadrive/; chmod -R 777 es.sh; ./es.sh
cd /datadrive/; chmod -R 777 Kafka_Setup_Script.sh; ./Kafka_Setup_Script.sh
cd /datadrive/; chmod -R 777 jupyter.sh; ./jupyter.sh
cd /datadrive/; chmod -R 777 python_R_sap.sh; ./python_R_sap.sh
cd /datadrive/; chmod -R 777 Drool_Step_2.sh; ./Drool_Step_2.sh
#sed -i 's/10.2.0.7/'172.16.1.68'/g' /datadrive/all_tomcat/apache-tomcat-drools-8.5/bin/setenv.sh
#cd /datadrive/all_tomcat/apache-tomcat-drools-8.5/bin; ./startup.sh

cd /datadrive/; chmod -R 777 mongod.sh; ./mongod.sh
cd /datadrive/; chmod -R 777 install_hadoop.sh; ./install_hadoop.sh
cd /datadrive/; chmod -R 777 nginx.sh; ./nginx.sh
cd /datadrive/; chmod -R 777 monitoringAndSAS.sh; ./monitoringAndSAS.sh
