# Environment
. ./00-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

# Run function
INVOKE_RESULT=$(./bin/wsk -i action invoke -br qr -p text 'Hello world!')
printf "\nINVOKE_RESULT\n${INVOKE_RESULT}\n\n"
echo ${INVOKE_RESULT} | jq -r '.qr' | base64 --decode > qr.png


export WEB_URL=`./bin/wsk -i action get qr --url | awk 'FNR==2{print $1}'`
export AUTH=`oc get secret whisk.auth -o yaml | grep "system:" | awk '{print $2}'`
echo "WEB_URL: ${WEB_URL}"
echo "AUTH: ${AUTH}"

# GET
GET_RESULT=$(curl -k --silent -X GET ${WEB_URL}.json?text=Hi%20from%20GET)
printf "\n\nGET\n${GET_RESULT}"

# POST
POST_RESULT=$(curl -k --silent -d '{"text":"Hi from POST", "place":"Barcelona"}' -H "Content-Type: application/json" -X POST $WEB_URL.json)
printf "\n\nPOST\n${POST_RESULT}\n"
