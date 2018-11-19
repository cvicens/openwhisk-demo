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
../../bin/wsk -i action update --web=true events/skill-gw ./skill-gw.js
../../bin/wsk -i action update --web=true events/skill-list ./skill-list-events.js
../../bin/wsk -i action update --web=true events/skill-current-slot ./skill-current-slot.js
../../bin/wsk -i action update --web=true events/skill-next-slot ./skill-next-slot.js

# Get List Events host and the SSL cert used
export FN_HOST=`../../bin/wsk -i action get events/skill-gw --url | awk 'FNR==2{print $1}' | sed -e 's/https:\/\///' | sed -e 's/\/.*$//'`
openssl s_client -showcerts -verify 5 -connect ${FN_HOST}:443 < /dev/null
