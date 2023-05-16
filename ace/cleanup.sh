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

oc delete integrationserver.appconnect.ibm.com echo -n $TARGET_NAMESPACE
oc delete integrationserver.appconnect.ibm.com infinite -n $TARGET_NAMESPACE
oc delete integrationserver.appconnect.ibm.com notification -n $TARGET_NAMESPACE

# Import kdb and sth files for communication with IBM MQ
oc delete secret mq-key-kdb -n $TARGET_NAMESPACE
oc delete secret mq-key-sth -n $TARGET_NAMESPACE
oc delete secret mq-infinite-ccdt -n $TARGET_NAMESPACE

oc delete configuration mq-uc-key-store.kdb mq-uc-key-store.sth -n $TARGET_NAMESPACE
oc delete configuration mq-infinite-ccdt -n $TARGET_NAMESPACE
oc delete configuration infinite-serverconf -n $TARGET_NAMESPACE
oc delete configuration mq-policy-project -n $TARGET_NAMESPACE

oc delete secret github-creds -n $TARGET_NAMESPACE
oc delete configuration cred-for-github -n $TARGET_NAMESPACE
