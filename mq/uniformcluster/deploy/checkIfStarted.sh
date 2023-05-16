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
export QMGR_NAME=${2:-"none"}

# wait 10 minutes for queue manager to be up and running
# (shouldn't take more than 2 minutes, but just in case)
for i in {1..60}
do
  phase=`oc get qmgr -n $TARGET_NAMESPACE $QMGR_NAME -o jsonpath="{.status.phase}"`
  if [ "$phase" == "Running" ] ; then break; fi
  echo "Waiting for $QMGR_NAME...$i"
  oc get qmgr -n $TARGET_NAMESPACE $QMGR_NAME
  sleep 10
done

if [ $phase == Running ]
   then echo Queue Manager $QMGR_NAME is ready;
   exit;
fi

echo "*** Queue Manager $QMGR_NAME is not ready ***"
exit 1
