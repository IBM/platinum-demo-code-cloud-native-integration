#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2023. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export TARGET_NAMESPACE=${1:-"cp4i"}

oc project $TARGET_NAMESPACE

#Deploy echo Integration Server
oc apply -f $SCRIPT_DIR/resources/echoIntegrationServer.yaml
oc apply -f $SCRIPT_DIR/resources/infiniteIntegrationServer.yaml
