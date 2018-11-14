#!/bin/bash
# https://github.com/apache/incubator-openwhisk-deploy-openshift

# Environment
. ./0-environment.sh

read -p 'Master URL: ' MASTER_URL
read -sp 'Token: ' TOKEN

STATUS=$(curl -s -k -o /dev/null -w '%{http_code}' ${MASTER_URL})

if [ ${STATUS} -ne 200 ]; then
echo "Master URL doesn't seem to be a good one... status(${STATUS})"
exit 1
fi

oc login ${MASTER_URL} --token=${TOKEN}

oc new-project ${PROJECT_NAME}

oc process -f https://git.io/openwhisk-template | oc -n ${PROJECT_NAME} create -f -

while oc get pods -n ${PROJECT_NAME} | grep -v -E "(Running|Completed|STATUS)"; do sleep 5; done

curl -L -o ./bin/wsk.zip https://github.com/projectodd/openwhisk-openshift/releases/download/latest/OpenWhisk_CLI-latest-${PLATFORM}-amd64.zip
unzip ./bin/wsk.zip -d ./bin
rm ./bin/wsk.zip

export AUTH_SECRET=$(oc get secret whisk.auth -n ${PROJECT_NAME} -o yaml | grep "system:" | awk '{print $2}' | base64 --decode)
./bin/wsk property set --auth ${AUTH_SECRET} --apihost $(oc get route/openwhisk --template="{{.spec.host}}" -n ${PROJECT_NAME})

# List
./bin/wsk -i list

./bin/wsk -i action list


