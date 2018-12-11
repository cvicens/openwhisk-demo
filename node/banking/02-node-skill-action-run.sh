#!/bin/bash
# https://github.com/apache/incubator-openwhisk-deploy-openshift

# Environment
. ../../00-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

CLIENT_ID="SBM_vmB04xxk8td"
CLIENT_SECRET="ATbzm8FtX3e9qHe"

# Info to invoke the rest API
export AUTH=`oc get secret whisk.auth -o yaml | grep "system:" | awk '{print $2}'`

# Registration Token
export WEB_URL=`../../bin/wsk -i action get banking/ahoi-get-registration-token --url | awk 'FNR==2{print $1}'`
POST_RESULT=$(curl -k --silent -d "{\"clientId\": \"${CLIENT_ID}\", \"clientSecret\": \"${CLIENT_SECRET}\"}" -H "Content-Type: application/json" -X POST $WEB_URL.json)
printf "\n\nPOST\n${POST_RESULT}\n"

RESGISTRATION_TOKEN=$(echo ${POST_RESULT} | jq -r '.access_token')

echo "RESGISTRATION_TOKEN=${RESGISTRATION_TOKEN}"

# User Registration
export WEB_URL=`../../bin/wsk -i action get banking/ahoi-user-registration --url | awk 'FNR==2{print $1}'`
POST_RESULT=$(curl -k --silent -d "{\"registrationToken\": \"${RESGISTRATION_TOKEN}\"}" -H "Content-Type: application/json" -X POST $WEB_URL.json)
printf "\n\nPOST\n${POST_RESULT}\n"