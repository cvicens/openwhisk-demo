#!/bin/bash
# https://github.com/apache/incubator-openwhisk-deploy-openshift

# Environment
. ./00-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
  echo "You need to log in your Openshift cluster first..."
  exit 1
fi

# Create a project to deploy OpenWhisk
oc new-project ${PROJECT_NAME}

# Deploying OpenWhisk, choose the remote (default) or local template
oc process -f https://git.io/openwhisk-template | oc -n ${PROJECT_NAME} create -f -
#oc process -f ./openwhisk-ephemeral-template.yaml | oc -n ${PROJECT_NAME} create -f -

while oc get pods -n ${PROJECT_NAME} | grep -v -E "(Running|Completed|STATUS)"; do sleep 5; done

curl -L -o ./bin/wsk.zip https://github.com/projectodd/openwhisk-openshift/releases/download/latest/OpenWhisk_CLI-latest-${PLATFORM}-amd64.zip
unzip ./bin/wsk.zip -d ./bin
rm ./bin/wsk.zip

export AUTH_SECRET=$(oc get secret whisk.auth -n ${PROJECT_NAME} -o yaml | grep "system:" | awk '{print $2}' | base64 --decode)
./bin/wsk property set --auth ${AUTH_SECRET} --apihost $(oc get route/openwhisk --template="{{.spec.host}}" -n ${PROJECT_NAME})

# List
./bin/wsk -i list


