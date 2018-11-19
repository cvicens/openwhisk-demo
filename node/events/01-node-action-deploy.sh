#!/bin/bash
# https://github.com/apache/incubator-openwhisk-deploy-openshift

# Environment
. ../../00-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

oc project ${PROJECT_NAME}

# Setting up OpenWhisk cli
export AUTH_SECRET=$(oc get secret whisk.auth -n ${PROJECT_NAME} -o yaml | grep "system:" | awk '{print $2}' | base64 --decode)
../../bin/wsk property set --auth ${AUTH_SECRET} --apihost $(oc get route/openwhisk --template="{{.spec.host}}" -n ${PROJECT_NAME})

# Create package
 ../../bin/wsk -i package create events

# Create an action from a Javascript function...
../../bin/wsk -i action update --web=true events/list ./list-events.js
../../bin/wsk -i action update --web=true events/current-slot ./current-slot.js
../../bin/wsk -i action update --web=true events/next-slot ./next-slot.js


