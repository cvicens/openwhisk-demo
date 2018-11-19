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
export WEB_URL=`../../bin/wsk -i action get events/list --url | awk 'FNR==2{print $1}'`
GET_RESULT=$(curl -k --silent -X GET ${WEB_URL}.json?city=Madrid)
printf "\nList Events\n${GET_RESULT}"

# Current Slot
export WEB_URL=`../../bin/wsk -i action get events/current-slot --url | awk 'FNR==2{print $1}'`
GET_RESULT=$(curl -k --silent -X GET ${WEB_URL}.json)
printf "\nCurrent Slot\n${GET_RESULT}"

# Next Slot
export WEB_URL=`../../bin/wsk -i action get events/next-slot --url | awk 'FNR==2{print $1}'`
GET_RESULT=$(curl -k --silent -X GET ${WEB_URL}.json)
printf "\nNext Slot\n${GET_RESULT}"
