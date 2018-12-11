# Environment
. ./00-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

BASE_DIR=$(pwd)

ARTIFACT_ID="qr-gen"

cd maven

# Deploy function
cd ${ARTIFACT_ID}
mvn clean package

cd ${BASE_DIR}

# Setting up OpenWhisk cli
export AUTH_SECRET=$(oc get secret whisk.auth -n ${PROJECT_NAME} -o yaml | grep "system:" | awk '{print $2}' | base64 --decode)
./bin/wsk property set --auth ${AUTH_SECRET} --apihost $(oc get route/openwhisk --template="{{.spec.host}}" -n ${PROJECT_NAME})

# Create function
./bin/wsk -i action update --web=true qr maven/${ARTIFACT_ID}/target/${ARTIFACT_ID}.jar --main com.redhat.serverless.FunctionApp

