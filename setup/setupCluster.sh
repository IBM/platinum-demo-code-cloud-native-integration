#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2023. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

ENTITLED_REG_KEY=$1
ENCODING=$(echo "cp:$ENTITLED_REG_KEY" | base64 -w0)
echo ENCODING=$ENCODING

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Configuring the default storage class to be ceph-rbd"
kubectl patch storageclass ocs-storagecluster-cephfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass ocs-storagecluster-ceph-rbd -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

$SCRIPT_DIR/installPipelineOnly.sh

#Get currentSecret
#oc get secret -n openshift-config pull-secret -o "jsonpath={.data.\.dockerconfigjson}" | base64 -d > ORIGINAL_SECRETS
#cat ORIGINAL_SECRETS

#COUNT_ICR_SECRETS=$(cat ORIGINAL_SECRETS | jq '.auths."cp.icr.io" | length')

#if (( COUNT_ICR_SECRETS == 0 )); then
#  echo "Updating Secret to add IBM Entitlement Key"

  #UPDATE_SECRET=$(jq '.auths |= . + {"cp.icr.io": {"username": "cp", "password": "'$ENTITLED_REG_KEY'", "auth":"'$ENCODING'", "email": "callumj@uk.ibm.com"}}' ORIGINAL_SECRETS | base64 -w 0) 

  #oc patch secret pull-secret -p '{"data": {".dockerconfigjson": "'$UPDATE_SECRET'"}}' -n openshift-config --type=merge

#fi

#rm ORIGINAL_SECRETS
oc new-project student1
oc new-project student2
oc new-project student3
oc new-project student4
oc new-project student5
oc new-project student6
oc new-project student7
oc new-project student8

oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLED_REG_KEY --docker-email=callumj@uk.ibm.com -n student1
oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLED_REG_KEY --docker-email=callumj@uk.ibm.com -n student2
oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLED_REG_KEY --docker-email=callumj@uk.ibm.com -n student3
oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLED_REG_KEY --docker-email=callumj@uk.ibm.com -n student4
oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLED_REG_KEY --docker-email=callumj@uk.ibm.com -n student5
oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLED_REG_KEY --docker-email=callumj@uk.ibm.com -n student6
oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLED_REG_KEY --docker-email=callumj@uk.ibm.com -n student7
oc create secret docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$ENTITLED_REG_KEY --docker-email=callumj@uk.ibm.com -n student8


