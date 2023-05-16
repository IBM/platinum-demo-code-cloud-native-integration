#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export MQCCDTURL="${DIR}/ccdt_generated.json"
export MQSSLKEYR="${DIR}/key"

export ROOTURL="$(oc get IngressController default -n openshift-ingress-operator -o jsonpath='{.status.domain}')"
( echo "cat <<EOF" ; cat ccdt_template.json ; echo EOF ) | sh > ccdt_generated.json

CCDT_NAME=${2:-"*ANY_QM"}

for (( i=0; i<$1; ++i)); do
  echo "Starting amqsghac" $CCDT_NAME
  /opt/mqm/samp/bin/amqsghac APPQ $CCDT_NAME &
done
