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
file_storage=${2:-"ocs-storagecluster-cephfs"}

oc new-project $namespace
oc project $namespace

setup/deploy.sh $namespace

oc create serviceaccount pipeline-admin -n $namespace
oc create clusterrolebinding cicd-pipeline-admin-crb-$namespace --clusterrole=cluster-admin --serviceaccount=$namespace:pipeline-admin

cat pipeline/cicd-environment-setup.yaml_template |
       sed "s#{{DEFAULT_FILE_STORAGE}}#$file_storage#g;" |
       sed "s#{{NAMESPACE}}#$namespace#g;" > cicd-environment-setup$namespace.yaml
oc apply -f cicd-environment-setup$namespace.yaml
rm cicd-environment-setup$namespace.yaml

cat pipeline/cicd-storage.yaml_template |
       sed "s#{{DEFAULT_FILE_STORAGE}}#$file_storage#g;" |
       sed "s#{{NAMESPACE}}#$namespace#g;" > cicd-storage$namespace.yaml

oc apply -f cicd-storage$namespace.yaml
rm cicd-storage$namespace.yaml

sleep 30

URL=$( oc get routes -n $namespace el-environment-setup-pipeline-trigger-route -o jsonpath={.spec.host})
echo {\"namespace\": \"$namespace\"} >> JSON$namespace
curl -d @JSON$namespace http://$URL
rm JSON$namespace