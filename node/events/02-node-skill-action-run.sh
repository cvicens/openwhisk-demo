#!/bin/bash
# https://github.com/apache/incubator-openwhisk-deploy-openshift

# Environment
. ../../00-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

# Info to invoke the rest API
export AUTH=`oc get secret whisk.auth -o yaml | grep "system:" | awk '{print $2}'`

# List Events
export WEB_URL=`../../bin/wsk -i action get events/skill-gw --url | awk 'FNR==2{print $1}'`
POST_RESULT=$(curl -k --silent -d '{"request": {"intent": {"name": "ListEvents", "slots": {"city": {"value": "Lisbon"}}}}}' -H "Content-Type: application/json" -X POST $WEB_URL.json)
printf "\n\nPOST\n${POST_RESULT}\n"