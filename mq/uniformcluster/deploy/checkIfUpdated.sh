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
export VERSION=${2:-"9.3.1.0-r1"}

# wait 10 minutes for queue manager to be up and running
# (shouldn't take more than 2 minutes, but just in case)
for i in {1..60}
do
  runningContainers=`kubectl get pod -n $TARGET_NAMESPACE -l app.kubernetes.io/instance=$QMGR_NAME --field-selector=status.phase==Running | wc -l`
  if [ "$runningContainers" == "3" ] ; then break; fi
  echo "Waiting for $QMGR_NAME...to drop to 2 running containers $i"
  sleep 1
done


for i in {1..120}
do
  runningContainers=`kubectl get pod -n $TARGET_NAMESPACE -l app.kubernetes.io/instance=$QMGR_NAME --field-selector=status.phase==Running | wc -l`
  if [ "$runningContainers" == "4" ] ; then break; fi
  echo "Waiting for $QMGR_NAME... container 1 to be finished $i"
  sleep 1
done

for i in {1..60}
do
  runningContainers=`kubectl get pod -n $TARGET_NAMESPACE -l app.kubernetes.io/instance=$QMGR_NAME --field-selector=status.phase==Running | wc -l`
  if [ "$runningContainers" == "3" ] ; then break; fi
  echo "Waiting for $QMGR_NAME...to drop to 2 running containers $i"
  sleep 1
done

for i in {1..120}
do
  runningContainers=`kubectl get pod -n $TARGET_NAMESPACE -l app.kubernetes.io/instance=$QMGR_NAME --field-selector=status.phase==Running | wc -l`
  if [ "$runningContainers" == "4" ] ; then break; fi
  echo "Waiting for $QMGR_NAME... container 2 to be finished $i"
  sleep 1
done

for i in {1..60}
do
  runningContainers=`kubectl get pod -n $TARGET_NAMESPACE -l app.kubernetes.io/instance=$QMGR_NAME --field-selector=status.phase==Running | wc -l`
  if [ "$runningContainers" == "3" ] ; then break; fi
  echo "Waiting for $QMGR_NAME...to drop to 2 running containers $i"
  sleep 1
done

exit
