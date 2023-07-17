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

hostname=$(oc get route el-infinite-cleanup-pipeline-trigger-route -o jsonpath={.spec.host})

response=$(curl -d "{}" $hostname)
echo $response

oc delete pvc -n $namespace git-source-workspace
oc delete pvc -n $namespace git-source-workspace2
oc delete pvc -n $namespace git-source-workspace3