# Environment
. ./0-environment.sh

TOKEN=$(oc whoami -t)

if [ -z ${TOKEN} ]; then
echo "You need to log in your Openshift cluster first..."
exit 1
fi

# Run function
./bin/wsk -i action invoke -br qr -p text 'Hello world!'