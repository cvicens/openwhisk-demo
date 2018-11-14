#!/bin/bash
# https://github.com/apache/incubator-openwhisk-deploy-openshift

# Environment
. ./0-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

# Run greeter action
./bin/wsk -i action invoke --result greeter -p name 'Carlos' -p place 'Lisbon'


