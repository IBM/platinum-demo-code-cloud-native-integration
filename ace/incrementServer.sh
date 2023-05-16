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
export IS_NAME=${2:-"echo"}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Going to increment integrationServer $IS_NAME in namespace $TARGET_NAMESPACE"
currentReplicas=$(oc get integrationserver $IS_NAME -n $TARGET_NAMESPACE -o jsonpath={.spec.replicas})
export newReplica=$((currentReplicas+1))
echo "Changing from $currentReplicas to $newReplica"

( echo "cat <<EOF" ; cat $SCRIPT_DIR/resources/integrationServerPatch.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/integrationServerPatch.yaml

oc patch IntegrationServer $IS_NAME --patch-file $SCRIPT_DIR/integrationServerPatch.yaml -n $TARGET_NAMESPACE --type=merge

rm $SCRIPT_DIR/integrationServerPatch.yaml
