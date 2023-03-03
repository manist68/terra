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


File Edit Options Buffers Tools Sh-Script Help                                  

cd /datadrive; wget "https://naiglobalstrg.blob.core.windows.net/psfiles/all.tar.gz" ; tar xf all.tar.gz

#pvt ip
ip=$(hostname -I)

cd /datadrive/; tar xf node-v12.18.2-linux-x64.tar.gz; 
tar xf jdk1.8.0_144.tar.gz; tar xf hadoop-2.8.1.tar.xz; 
tar xf spark-2.4.5-bin-hadoop2.7.tar.gz; 
tar xf all_script_files_N.tar.gz; tar xf confluent-6.0.0.tar.gz; 
tar xf kafka_2.12-2.6.0.tar.gz; tar xf elasticsearch-6.5.4.tar.gz; 
tar xf Drools.tar.xz;tar xf all_tomcat.tar.xz; tar xf ssl-cert.tar.gz; 
tar xf mongodb-linux-x86_64-ubuntu1604-4.2.8.tgz;


# replace values in file
## hadoop
sed -i 's@export JAVA_HOME=${JAVA_HOME}@export JAVA_HOME='\''/datadrive/jdk1.8.0_144/jre'\''@g' /datadrive/hadoop-2.8.1/etc/hadoop/hadoop-env.sh

## es
sed -i "s|192.168.1.204|${ip}|g" /datadrive/elasticsearch-6.5.4/config/elasticsearch.yml

## kafka
sed -i "s|10.2.0.6|{$ip}|g" /datadrive/confluent-6.0.0/etc/schema-registry/schema-registry.properties
sed -i "s/10.2.0.6/{$ip}/g" /datadrive/kafka_2.12-2.6.0/config/server.properties

## Drool
sed -i "s/10.2.0.7/{$ip}/g" /datadrive/all_tomcat/apache-tomcat-drools-8.5/bin/setenv.sh

#setting up 

cd /datadrive/; chmod -R 777 bashrc_set.sh; ./bashrc_set.sh
sleep 3
source ~/.bashrc
sleep 30
alias brc='source ~/.bashrc'
sleep 15
sudo apt-get update -y

sudo apt-get install -y openjdk-11-jdk-headless
sleep 5
sudo apt install jq -y

# elastic search
cd /datadrive/; chmod -R 777 es.sh; ./es.sh
#sed -i 's/192.168.1.204/172.16.1.68/g' /datadrive/elasticsearch-6.5.4/config/elasticsearch.yml

# kafka
cd /datadrive/; chmod -R 777 Kafka_Setup_Script.sh; ./Kafka_Setup_Script.sh

# Jupyter note book
cd /datadrive/; chmod -R 777 jupyternew.sh; ./jupyternew.sh
#echo 'c.NotebookApp.ip = '\''10.10.1.68\''' >> /home/azureuser/.jupyter/jupyter_notebook_config.py

# Python, R, sap
#cd /datadrive/; chmod -R 777 python_R_sap.sh; ./python_R_sap.sh

# Drool
cd /datadrive/; chmod -R 777 Drool_Step_2.sh; ./Drool_Step_2.sh

#Tomcat
cd /datadrive/all_tomcat/apache-tomcat-drools-8.5/bin; ./startup.sh

# mongodb in prog
sudo apt install curl -y

sudo apt-get install -y mongodb


# hadoop
cd /datadrive/; chmod -R 777 install_hadoop.sh; ./install_hadoop.sh


# SAS updata in mongodb and Monitoring of services
cd /datadrive/; chmod -R 777 monitoringAndSAS.sh; ./monitoringAndSAS.sh

