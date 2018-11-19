#!/bin/bash
# https://github.com/apache/incubator-openwhisk-deploy-openshift

# Environment
. ./00-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

# Inovoke greeter action
INVOKE_RESULT=$(./bin/wsk -i action invoke --result greeter -p name 'Carlos' -p place 'Lisbon')
printf "\nINVOKE\n${INVOKE_RESULT}\n\n"

# Info to invoke the rest API
export WEB_URL=`./bin/wsk -i action get greeter --url | awk 'FNR==2{print $1}'`
export AUTH=`oc get secret whisk.auth -o yaml | grep "system:" | awk '{print $2}'`

echo "WEB_URL: ${WEB_URL}"
echo "AUTH: ${AUTH}"

# GET
GET_RESULT=$(curl -k --silent -X GET ${WEB_URL}.json?name=Carlos\&place=Madrid)
printf "\n\nGET\n${GET_RESULT}"

# POST
POST_RESULT=$(curl -k --silent -d '{"name":"Carlos", "place":"Barcelona"}' -H "Content-Type: application/json" -X POST $WEB_URL.json)
printf "\n\nPOST\n${POST_RESULT}\n"
