#!/bin/bash
                              
ip=$(hostname -I)
cd /datadrive; wget "https://naiglobalstrg.blob.core.windows.net/psfiles/all.tar.gz" ; tar xf all.tar.gz
# sudo apt update 
# sudo apt install jq -y


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
#cd /datadrive/; git clone -b nai_4.2_qa https://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@github.com/tarun-nt/intelligent_front.git;
#git clone -b prod_4.2_remove_source https://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@github.com/tarun-nt/intelligent_front.git;
#jq '.droolsService = $newVal' --arg newVal "http://$ip:8070/NaiWrapperBranching/naiservice/droolsService" <<< /datadrive/intelligent_front/server/config/serverDynamicConfig.json
sed -i 's/192.168.1.204/'$ip'/g' /datadrive/kafka_2.12-2.6.0/config/server.properties
sed -i 's|/home/nt/Drools/|/datadrive/Drools/|g' /datadrive/kafka_2.12-2.6.0/config/server.properties
/home/nt/Drools/drools.sh
cd /datadrive/; chmod -R 777 bashrc_set.sh; ./bashrc_set.sh
source ~/.bashrc
sleep 3
alias brc='source ~/.bashrc'
sudo apt install jq -y
# elastic search
cd /datadrive/; chmod -R 777 es.sh; ./es.sh
#sed -i 's/192.168.1.204/172.16.1.68/g' /datadrive/elasticsearch-6.5.4/config/elasticsearch.yml

# kafka 
cd /datadrive/; chmod -R 777 Kafka_Setup_Script.sh; ./Kafka_Setup_Script.sh
# sed -i 's/10.2.0.6/'$ip'g' /datadrive/confluent-6.0.0/etc/schema-registry/schema-registry.properties
# sed -i 's/10.2.0.6/'$ip'/g' /datadrive/kafka_2.12-2.6.0/config/server.properties

# Jupyter note book
cd /datadrive/; chmod -R 777 jupyternew.sh; ./jupyternew.sh
#echo 'c.NotebookApp.ip = '\''10.10.1.68\''' >> /home/azureuser/.jupyter/jupyter_notebook_config.py

# Python, R, sap 
cd /datadrive/; chmod -R 777 python_R_sap.sh; ./python_R_sap.sh

# Drool
cd /datadrive/; chmod -R 777 Drool_Step_2.sh; ./Drool_Step_2.sh
#sed -i 's/10.2.0.7/'172.16.1.68'/g' /datadrive/all_tomcat/apache-tomcat-drools-8.5/bin/setenv.sh
#cd /datadrive/all_tomcat/apache-tomcat-drools-8.5/bin; ./startup.sh

# mongodb in prog
#cd /datadrive/; chmod -R 777 mongod.sh; ./mongod.sh
#child process fail error 

# hadoop 
cd /datadrive/; chmod -R 777 install_hadoop.sh; ./install_hadoop.sh

