#!/bin/bash

clear
green='\033[0;32m'
lgreen='\033[1;32m'
nc='\033[0m'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export MQCCDTURL="${DIR}/ccdt_generated.json"
export MQSSLKEYR="${DIR}/key"

export ROOTURL="$(oc get routes ucqm1-ibm-mq-qm -n cp4i -o jsonpath='{.status.ingress[].routerCanonicalHostname}')"
( echo "cat <<EOF" ; cat ccdt_template.json ; echo EOF ) | sh > ccdt_generated.json

APPNAME=${2:-amqsghac}
DELAY=${3:-1s}

for (( i=0; i<100000; ++i)); do
  CONNCOUNT=`echo "dis conn(*) where(appltag eq '$APPNAME')" | /opt/mqm/bin/runmqsc -c $1 | grep "  CONN" | wc -w`
  BALANCED=`echo "dis apstatus('$APPNAME')" | /opt/mqm/bin/runmqsc $1 | grep "  BALANCED"`
  clear
  echo -e "${green}$1${nc} / ${green}$APPNAME${nc} -- ${lgreen}$CONNCOUNT${nc}"
  echo "dis conn(*) where(appltag eq '$APPNAME')" | /opt/mqm/bin/runmqsc $1 | grep "  CONN"
  sleep $DELAY
done
