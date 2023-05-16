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

( echo "cat <<EOF" ; cat $SCRIPT_DIR/uniformclusterQMConfig.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/uniformclusterQMConfig.yaml
( echo "cat <<EOF" ; cat $SCRIPT_DIR/uniformclusterQM1.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/uniformclusterQM1.yaml
( echo "cat <<EOF" ; cat $SCRIPT_DIR/uniformclusterQM2.yaml_template ; echo EOF ) | sh > $SCRIPT_DIR/uniformclusterQM2.yaml

oc apply -f $SCRIPT_DIR/uniformclusterQMConfig.yaml
oc apply -f $SCRIPT_DIR/uniformclusterQM1.yaml
oc apply -f $SCRIPT_DIR/uniformclusterQM2.yaml
