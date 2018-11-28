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
 ../../bin/wsk -i package create banking

# Create an action from a Javascript function...
../../bin/wsk -i action update --web=true banking/ahoi-get-registration-token ./ahoi-get-registration-token.js
../../bin/wsk -i action update --web=true banking/ahoi-user-registration ./ahoi-user-registration.js

# Get List banking host and the SSL cert used
#export FN_HOST=`../../bin/wsk -i action get banking/ahoi-get-registration-token --url | awk 'FNR==2{print $1}' | sed -e 's/https:\/\///' | sed -e 's/\/.*$//'`
#openssl s_client -showcerts -verify 5 -connect ${FN_HOST}:443 < /dev/null
