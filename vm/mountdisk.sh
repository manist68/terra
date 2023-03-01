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

ip=$(hostname -I)

# extract folder
cd /datadrive/; chmod -R 777 extractfiles.sh; ./extractfiles.sh

# replace values in file
## hadoop
sed -i 's@export JAVA_HOME=${JAVA_HOME}@export JAVA_HOME='\''/datadrive/jdk1.8.0_144/jre'\''@g' /datadrive/hadoop-2.8.1/etc/hadoop/hadoop-env.sh

## es
sed -i 's/192.168.1.204/'$ip'/g' /datadrive/elasticsearch-6.5.4/config/elasticsearch.yml

## kafka
sed -i 's/10.2.0.6/'$ip'/g' /datadrive/confluent-6.0.0/etc/schema-registry/schema-registry.properties
sed -i 's/10.2.0.6/'$ip'/g' /datadrive/kafka_2.12-2.6.0/config/server.properties

## Drool
sed -i 's/10.2.0.7/'$ip'/g' /datadrive/all_tomcat/apache-tomcat-drools-8.5/bin/setenv.sh

## ui
cd /datadrive/; git clone -b nai_4.2_qa https://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@github.com/tarun-nt/intelligent_front.git;
#git clone -b prod_4.2_remove_source https://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@github.com/tarun-nt/intelligent_front.git;
#jq '.droolsService = $newVal' --arg newVal "http://$ip:8070/NaiWrapperBranching/naiservice/droolsService" <<< /datadrive/intelligent_front/server/config/serverDynamicConfig.json
sed -i 's/192.168.1.204/'$ip'/g' /datadrive/kafka_2.12-2.6.0/config/server.properties
sed -i 's|/home/nt/Drools/|/datadrive/Drools/|g' /datadrive/kafka_2.12-2.6.0/config/server.properties
/home/nt/Drools/drools.sh

cd /datadrive/; chmod -R 777 bashrc_set.sh; ./bashrc_set.sh


# extract folder
cd /datadrive/; chmod -R 777 setup_all.sh; ./setup_all.sh
