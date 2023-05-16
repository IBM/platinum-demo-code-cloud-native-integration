#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2023. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

namespace=${1:-"cp4i"}

#oc new-project $namespace
oc project $namespace

replicas=""
wait_time=10
time=0
replicas=$(oc get deployment -n $namespace webui -o jsonpath={.status.readyReplicas} 2>/dev/null)

until [[ "$replicas" == "1" ]]; do
  if [ $time -ge 900 ]; then
    echo "ERROR: Failed after waiting for 15 minutes"
    exit 1
  fi
  if [ $time -ge 600 ]; then
    echo "INFO: Waited over ten minute and the number of replicas are $replicas"
    exit 1
  fi
  ((time = time + $wait_time))
  sleep $wait_time
  replicas=$(oc get deployment -n ${TARGET_NAMESPACE} webui -o jsonpath={.status.readyReplicas} 2>/dev/null)
done

hostname=$(oc get route webui -o jsonpath={.spec.host})

echo "Access Web UI: https://$hostname/file/chart.html"