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
export BRANCH=${2:-"main"}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Deploying $BRANCH branch"

if [ "$BRANCH" == "main" ]; then
    $SCRIPT_DIR/deploy/deploy2QM.sh $TARGET_NAMESPACE
    $SCRIPT_DIR/deploy/checkIfStarted.sh $TARGET_NAMESPACE ucqm1
    $SCRIPT_DIR/deploy/checkIfStarted.sh $TARGET_NAMESPACE ucqm2
fi

if [ "$BRANCH" == "notification" ]; then
    ( echo "cat <<EOF" ; cat $SCRIPT_DIR/deploy/uniformclusterQM1.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/deploy/uniformclusterQM1.yaml
    ( echo "cat <<EOF" ; cat $SCRIPT_DIR/deploy/uniformclusterQM2.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/deploy/uniformclusterQM2.yaml
    ( echo "cat <<EOF" ; cat $SCRIPT_DIR/deploy/uniformclusterQMConfig.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/deploy/uniformclusterQMConfig.yaml
    oc apply -f $SCRIPT_DIR/deploy/uniformclusterQMConfig.yaml
    oc apply -f $SCRIPT_DIR/deploy/uniformclusterQM1.yaml
    $SCRIPT_DIR/deploy/checkIfUpdated.sh $TARGET_NAMESPACE ucqm1
    oc apply -f $SCRIPT_DIR/deploy/uniformclusterQM2.yaml
    $SCRIPT_DIR/deploy/checkIfUpdated.sh $TARGET_NAMESPACE ucqm2
fi

if [ "$BRANCH" == "scale" ]; then
    $SCRIPT_DIR/deploy/deploy3QM.sh $TARGET_NAMESPACE
    $SCRIPT_DIR/deploy/checkIfStarted.sh $TARGET_NAMESPACE ucqm1
    $SCRIPT_DIR/deploy/checkIfStarted.sh $TARGET_NAMESPACE ucqm2
    $SCRIPT_DIR/deploy/checkIfStarted.sh $TARGET_NAMESPACE ucqm3
fi

if [ "$BRANCH" == "upgrademq" ]; then
    ( echo "cat <<EOF" ; cat $SCRIPT_DIR/deploy/uniformclusterQM1.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/deploy/uniformclusterQM1.yaml
    ( echo "cat <<EOF" ; cat $SCRIPT_DIR/deploy/uniformclusterQM2.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/deploy/uniformclusterQM2.yaml
    ( echo "cat <<EOF" ; cat $SCRIPT_DIR/deploy/uniformclusterQM3.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/deploy/uniformclusterQM3.yaml
    ( echo "cat <<EOF" ; cat $SCRIPT_DIR/deploy/uniformclusterQMConfig.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/deploy/uniformclusterQMConfig.yaml
    oc apply -f $SCRIPT_DIR/deploy/uniformclusterQMConfig.yaml
    oc apply -f $SCRIPT_DIR/deploy/uniformclusterQM1.yaml
    $SCRIPT_DIR/deploy/checkIfUpdated.sh $TARGET_NAMESPACE ucqm1
    oc apply -f $SCRIPT_DIR/deploy/uniformclusterQM2.yaml
    $SCRIPT_DIR/deploy/checkIfUpdated.sh $TARGET_NAMESPACE ucqm2
    oc apply -f $SCRIPT_DIR/deploy/uniformclusterQM3.yaml
    $SCRIPT_DIR/deploy/checkIfUpdated.sh $TARGET_NAMESPACE ucqm3
fi
