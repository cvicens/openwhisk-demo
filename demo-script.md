## Deploy nodejs function

```javascript

cat << EOF > my-greeter.js
function main(params) {
    const name = params.name || params.defaultName || 'Guest';
    const place = params.place || params.defaultPlace || 'OpenShift Cloud Functions';
    return {payload: 'Welcome to ' + place + ', ' + name};
}
EOF

cat << EOF > my-word-counter.js
function main(params) {
    var message = params.payload || 'Nothing to regret...';

    const regex = /\s+/gi;
    const wordCount = message.trim().replace(regex, ' ').split(' ').length;

    return {payload: wordCount};
}
EOF

```

# Create a function

```
./bin/wsk -i package create tests

./bin/wsk -i action update --web=true tests/my-greeter my-greeter.js

./bin/wsk -i action invoke --result tests/my-greeter -p name 'Carlos' -p place 'Madrid'

export WEB_URL=$(./bin/wsk -i action get tests/my-greeter --url | awk 'FNR==2{print $1}')

curl -k ${WEB_URL}.json?name=Carlos\&place=Lisboa
```

# Setting function and package parameters

```
./bin/wsk -i action update --web=true tests/my-greeter my-greeter.js --param defaultPlace Kansas

./bin/wsk -i action invoke --result tests/my-greeter -p name 'Carlos'

curl -k ${WEB_URL}.json?name=Carlos

./bin/wsk -i package update tests --param defaultName Johnny

curl -k ${WEB_URL}.json

```

# Triggers

```
./bin/wsk -i trigger create locationUpdate

./bin/wsk -i trigger list

./bin/wsk -i trigger fire locationUpdate --param name Donald --param place "Washington, D.C."

./bin/wsk -i rule create my-rule locationUpdate tests/my-greeter

./bin/wsk -i trigger fire locationUpdate --param name Donald --param place "Washington, D.C."

./bin/wsk -i activation list --limit 1

./bin/wsk -i activation result XYZ
```

# Sequences

```
./bin/wsk -i action update --web=true tests/my-word-counter my-word-counter.js

./bin/wsk -i action invoke --result tests/my-word-counter -p payload 'En un lugar de la Mancha'

./bin/wsk -i action create wordCountGreeting --sequence tests/my-greeter,tests/my-word-counter

./bin/wsk -i action invoke wordCountGreeting -b -r -p name "Carlos" -p place "Lisbon"

```

# Java, no problem

```
./09-maven-action-qr-gen-deploy.sh
./10-maven-action-qr-gen-run.sh
```

# Delete all

```
./bin/wsk -i action delete wordCountGreeting
./bin/wsk -i action delete tests/my-word-counter
./bin/wsk -i action delete tests/my-greeter
./bin/wsk -i package delete tests
```
