#!/bin/bash

# <SHARE-CONTAINER-NAME> and <ALFRESCO-CONTAINER-NAME> replace with actual container names of your Alfresco setup.

export BASEPROY=zk-zpm-statusable
export D_ALFRESCO=<ALFRESCO-CONTAINER-NAME>
export D_SHARE=<SHARE-CONTAINER-NAME>

# Compile and generate repo AMP
cd ${BASEPROY}-repo
mvn clean -Ppurge
mvn package -DskipTests=true

# Compile and generate repo AMP
cd ../${BASEPROY}-share
mvn clean -Ppurge
mvn package -DskipTests=true

# Copy AMPs to corresponding containers
cd ..
docker cp zk-zpm-statusable-share/target/*.amp ${D_SHARE}:/usr/local/tomcat/amps_share
docker cp zk-zpm-statusable-repo/target/*.amp ${D_ALFRESCO}:usr/local/tomcat/amps

# Apply AMP in <SHARE-CONTAINER-NAME> container
docker exec -ti ${D_SHARE} sh -c "java -jar /usr/local/tomcat/alfresco-mmt/alfresco-mmt*.jar install /usr/local/tomcat/amps_share /usr/local/tomcat/webapps/share -directory -nobackup -force"

# Apply AMP in <ALFRESCO-CONTAINER-NAME> container
docker exec -ti ${D_ALFRESCO} sh -c "java -jar /usr/local/tomcat/alfresco-mmt/alfresco-mmt*.jar install /usr/local/tomcat/amps /usr/local/tomcat/webapps/alfresco -directory -nobackup -force"

# Restart both containers
docker container restart ${D_ALFRESCO} ${D_SHARE}
