#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2023. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************
export TARGET_NAMESPACE=${1:-"cp4i"}
export INTEGRATION_SERVER_NAME=${2:-"none"}
export REPLICA_COUNT=${3:-"3"}

# wait 5 minutes for queue manager to be up and running
# (shouldn't take more than 2 minutes, but just in case)
for i in {1..60}
do
  replicasRunning=`oc get integrationserver $INTEGRATION_SERVER_NAME -o jsonpath="{.status.availableReplicas}"`
  if [ "$replicasRunning" == "$REPLICA_COUNT" ] ; then break; fi
  echo "Waiting for $INTEGRATION_SERVER_NAME...$i"
  sleep 5
done

if [ $replicasRunning == $REPLICA_COUNT ]
   then echo Integration Server $INTEGRATION_SERVER_NAME is ready;
   exit;
fi

echo "*** Integration Server $INTEGRATION_SERVER_NAME is not ready ***"
exit 1
