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
oc project $TARGET_NAMESPACE

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
# Import kdb and sth files for communication with IBM MQ
echo "Creating key db for ACE"
rm $SCRIPT_DIR/configuration
cp $SCRIPT_DIR/../mq/uniformcluster/test/key.kdb $SCRIPT_DIR/configuration
oc create secret generic mq-key-kdb --from-file=$SCRIPT_DIR/configuration -n $TARGET_NAMESPACE
rm $SCRIPT_DIR/configuration
echo "Creating key stash for ACE"
cp $SCRIPT_DIR/../mq/uniformcluster/test/key.sth $SCRIPT_DIR/configuration
oc create secret generic mq-key-sth --from-file=$SCRIPT_DIR/configuration -n $TARGET_NAMESPACE
echo "Created secret"
oc apply -f $SCRIPT_DIR/resources/mqKeyStore.yaml -n $TARGET_NAMESPACE
rm $SCRIPT_DIR/configuration

#Deploy authentication policy for bar file retrieval from githubusercontent
cp $SCRIPT_DIR/resources/GitHubCredentials $SCRIPT_DIR/configuration
oc create secret generic github-creds --from-file=$SCRIPT_DIR/configuration -n $TARGET_NAMESPACE
oc apply -f $SCRIPT_DIR/resources/credentialsForGitHub.yaml -n $TARGET_NAMESPACE
rm $SCRIPT_DIR/configuration

# Create CCDT configuration
( echo "cat <<EOF" ; cat $SCRIPT_DIR/resources/ccdt_template.json ; echo EOF ) | sh > $SCRIPT_DIR/ccdt.json

# Generate configuration yaml
echo -e "[INFO] Generating configuration yaml"
python -m zipfile -c $SCRIPT_DIR/configuration.zip ccdt.json

mv $SCRIPT_DIR/configuration.zip $SCRIPT_DIR/configuration
oc create secret generic mq-infinite-ccdt --from-file=$SCRIPT_DIR/configuration -n $TARGET_NAMESPACE
oc apply -f $SCRIPT_DIR/resources/ccdt.yaml -n $TARGET_NAMESPACE
rm $SCRIPT_DIR/configuration $SCRIPT_DIR/ccdt.json

# Create MQ Policy Project
export POLICY_PROJECT=`cat $SCRIPT_DIR/bars/InfiniteScalePolicyProject.bar | base64 -w10000`
( echo "cat <<EOF" ; cat $SCRIPT_DIR/resources/policyProject.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/policyProject.yaml
oc apply -f $SCRIPT_DIR/policyProject.yaml -n $TARGET_NAMESPACE

#Deploy integration server configuration
export SERVER_CONFIG=`cat $SCRIPT_DIR/resources/server.conf.yaml | base64 -w10000`
( echo "cat <<EOF" ; cat $SCRIPT_DIR/resources/infiniteServerConfig.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/infiniteServerConfig.yaml
oc apply -f $SCRIPT_DIR/infiniteServerConfig.yaml -n $TARGET_NAMESPACE
