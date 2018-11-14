# Environment
. ./0-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

# Run function
INVOKE_RESULT=$(./bin/wsk -i action invoke -br qr -p text 'Hello world!')
printf "\nINVOKE_RESULT\n${INVOKE_RESULT}\n\n"
echo ${INVOKE_RESULT} | jq -r '.qr' | base64 --decode > qr.png