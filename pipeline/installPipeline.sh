#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2023. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

export REPO=https://github.com/IBM/platinum-demo-code-cloud-native-integration.git
export BRANCH=main
export TARGET_NAMESPACE=${1:-"cp4i"}
export QMGR_NAME_1=ucqm1
export QMGR_NAME_2=ucqm2
export QMGR_NAME_3=ucqm3
export DEFAULT_FILE_STORAGE=ibmc-file-gold-gid
export VERSION=9.3.1.0-r1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cat $SCRIPT_DIR/cicd-pipeline.yaml_template |
       sed "s#{{REPO}}#$REPO#g;" |
       sed "s#{{NAMESPACE}}#$TARGET_NAMESPACE#g;" |
       sed "s#{{BRANCH}}#$BRANCH#g;" |
       sed "s#{{QMGR_NAME_1}}#$QMGR_NAME_1#g;" |
       sed "s#{{QMGR_NAME_2}}#$QMGR_NAME_2#g;" > $SCRIPT_DIR/cicd-pipeline.yaml

oc apply -f $SCRIPT_DIR/cicd-pipeline.yaml

cat $SCRIPT_DIR/cicd-pipeline-notification.yaml_template |
       sed "s#{{REPO}}#$REPO#g;" |
       sed "s#{{NAMESPACE}}#$TARGET_NAMESPACE#g;" |
       sed "s#{{BRANCH}}#$BRANCH#g;" |
       sed "s#{{QMGR_NAME_1}}#$QMGR_NAME_1#g;" |
       sed "s#{{QMGR_NAME_2}}#$QMGR_NAME_2#g;" > $SCRIPT_DIR/cicd-pipeline-notification.yaml

oc apply -f $SCRIPT_DIR/cicd-pipeline-notification.yaml

cat $SCRIPT_DIR/cicd-pipeline-cleanup.yaml_template |
       sed "s#{{REPO}}#$REPO#g;" |
       sed "s#{{NAMESPACE}}#$TARGET_NAMESPACE#g;" |
       sed "s#{{BRANCH}}#$BRANCH#g;" |
       sed "s#{{QMGR_NAME_1}}#$QMGR_NAME_1#g;" |
       sed "s#{{QMGR_NAME_2}}#$QMGR_NAME_2#g;" > $SCRIPT_DIR/cicd-pipeline-cleanup.yaml

oc apply -f $SCRIPT_DIR/cicd-pipeline-cleanup.yaml


sleep 60 

endpoint=""
wait_time=1
time=0

while [[ -z "$endpoint" ]]; do
   endpoint=$(oc get route el-infinite-base-pipeline-trigger-route -o jsonpath={.spec.host} 2>/dev/null)
   ((time = time + $wait_time))
   sleep $wait_time
   if [ $time -ge 300 ]; then
      echo "ERROR: Failed after waiting for 5 minutes"
      exit 1
   fi
   if [ $time -ge 180 ]; then
      echo "INFO: Waited over three minute"
      exit 1
   fi
done

echo "Calling $endpoint"
echo {\"branch\": \"main\"} >> JSON
curl -d @JSON $endpoint
rm JSON

echo "STARTED OF IBM MQ AND APP CONNECT INSTANCES"