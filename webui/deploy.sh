#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
namespace=${1:-"cp4i"}
hostname=`oc get route console -n openshift-console -o jsonpath='{.spec.host}' | cut -d "." -f2-`
echo $hostname

cat $SCRIPT_DIR/src/main/java/com/ibm/demo/StartTests.java_template |
  sed "s#{{HOSTNAME}}#$hostname#g;" > $SCRIPT_DIR/src/main/java/com/ibm/demo/StartTests.java

echo "Deploying to $namespace"

oc new-project $namespace
oc project $namespace
oc new-build --name webui --binary --strategy docker
oc start-build webui --from-dir $SCRIPT_DIR/. --follow

oc create serviceaccount webuisa -n $namespace
oc create clusterrolebinding webuisa-crb --clusterrole=cluster-admin --serviceaccount=$namespace:webuisa

cat $SCRIPT_DIR/deployment.yaml_template |
  sed "s#{{NAMESPACE}}#$namespace#g;" > $SCRIPT_DIR/deployment.yaml

oc apply -f $SCRIPT_DIR/deployment.yaml -n $namespace
oc apply -f $SCRIPT_DIR/service.yaml -n $namespace
