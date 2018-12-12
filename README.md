# Going serverless on Openshift with OpenWhisk
**Set of 'look ma no server' demos to enjoy OpenWhisk**

A while ago I was proposed to run a tech lab around the 'serverless' buzzword. By then I was already aware of the concept (I tried AWS back in 2015) and actually liked it, but to be honest since those experiments I had had very little contact with serveless tech, until Red Hat released some interesting labs (more on this later).

## TL;DR

I'll introduce you to a set of explained simple demos of increasing complexity.
I also give some hints to make sense of 'serverless' and 'function as a service' in the real world.

## Pre-requisites

In order to run these demos you need either an accessible [Openshift](https://www.openshift.com/learn/what-is-openshift/) environment with around 5GB RAM / 50GB disk / 3 vCPU  or a computer at hand with minishift installed and those free resources.

```
$ minishift version
minishift v1.26.1+1e20f27
```

Go [here](https://docs.okd.io/latest/minishift/getting-started/preparing-to-install.html) for instructions to install minishift.

You'll also need the Openshift CLI, go [here](https://docs.openshift.com/container-platform/latest/cli_reference/get_started_cli.html) for instructions to install it.

## Where's the code?

In order to follow the guide my suggestion is to clone, fork, download the code. The repo is [here](https://github.com/cvicens/openwhisk-demo).

```
$ git clone https://github.com/cvicens/openwhisk-demo
$ cd openwhisk-demo
```

By default I'll assume you're in folder `openwhisk-demo` unless otherwise advised.

## Setting up the minishift environment

> *If you already have an Openshift environment you can skip this.*

In order to set up our demo, we need to run `./01-setup-minishift.sh`. Please have a look to `./00-environment.sh` to confirm the default values for the minishift profile we're going to create. 

> Pay special attention to variables MINISHIFT_VM_DRIVER and PLATFORM to make then match your environment!

```
$ ./01-setup-minishift.sh
```

After a while should get a message like this.

```
...
```

Now please log in to your minishift with the next script.

```
$ ./02-login-minishift.sh
```

## Deploying OpenWhisk on Openshift

> If you have your own OpenShift environment, don't forget to login in using the `oc` tool... otherwise you'll get this message: `You need to log in your Openshift cluster first...`

Deploying OpenWhisk on OpenShift means basically applying a template, a one-liner like this.

```
oc process -f https://git.io/openwhisk-template | oc create -f -
```

To make it a little easier (I hope) I've prepared a script that creates a project/namespace (by default `openwhisk-demo`), deploys OpenWhisk in it, and downloads and sets up the OpenWhisk CLI `wsk` in `./bin`

So let's do this, please, run the script as follows.

> **Please ignore this error if hit:** unable to recognize no matches for kind "CronJob" in version "batch/v2alpha1"

> **You can also use a local version of the template** I fixed, to do so, look for '# Deploying OpenWhisk, choose the remote (default) or local template'


```
$ ./03-deploy-opewhisk.sh
Now using project "openwhisk-demo" on server "https://master.serverless-e442.openshiftworkshop.com:443".
...
to build a new example application in Ruby.
configmap/whisk.config created
...
alarmprovider-7755754445-hp2hc                0/1       Init:0/2            0          3s
controller-0                                  0/1       Init:0/2            0          5s
couchdb-0                                     0/1       ContainerCreating   0          4s
install-catalog-5jfjv                         0/1       Init:0/1            0          5s
invoker-0                                     0/1       Init:0/2            0          4s
nginx-85697b95cf-zkgzl                        0/1       Init:0/1            0          3s
...
```

Finally you should see something like this, it's a list of items you get by invoking `wsk list`. It means everything is set up correctly.

> Beware that commands are run like this `./bin/wsk -i` because `wsk` is not in your PATH, `-i` is needed because we assume you don't have an OpenShift environment using certificates signed by a recognized CA.

```
 ./bin/wsk -i list
Entities in namespace: default
packages
/whisk.system/combinators                                              shared
...
actions
/whisk.system/samples/curl                                             private nodejs:6
...
triggers
rules
```

## Running the demos

There are several Javascript and Java examples.

In general demos are divided into two scripts:

* one to deploy the function
* and another one to run it

Let's start with the basics.

### NodeJS greeter.js demo

The idea is to deploy a function like this one below, file `./node/greeter.js`.

```javascript
function main(params) {
    var name = params.name || 'Guest';
    var place = params.place || 'OpenShift Cloud Functions';
    return {payload: 'Welcome to ' + place + ', ' + name};
}
```

To deploy the function you only need to to this.

> Pay attention to the `--web` flag, this means we can invoke this action using HTTP

```
$ ./bin/wsk -i action update --web=true greeter ./node/greeter.js
ok: updated action greeter
```

> The provided script `04-node-action-deploy.sh` makes sure `wsk` is set up properly but it's not mandatory to use it

There are several way to run our function, using `wsk` synchronously/asynchronously, HTTP GET/POST, ...

Calling our function synchronously, `--result` instructs to wait for the result.

```
$ ./bin/wsk -i action invoke --result greeter -p name 'Carlos' -p place 'Lisbon'
{
    "payload": "Welcome to Lisbon, Carlos"
}
```

Same, call, but this time in an asynchronous way

```
$ ./bin/wsk -i action invoke greeter -p name 'Carlos' -p place 'Lisbon'
ok: invoked /_/greeter with id 6c64b7206b5e483fa4b7206b5e483fad
```

Now to get the result we do as follows.

```
$ ./bin/wsk -i activation result 6c64b7206b5e483fa4b7206b5e483fad
{
    "payload": "Welcome to Lisbon, Carlos"
}

```

If we want to use HTTP, first we need the URL.

```
$ ./bin/wsk -i action get greeter --url | awk 'FNR==2{print $1}'
https://openwhisk-openwhisk-demo.apps.serverless-e442.openshiftworkshop.com/api/v1/web/whisk.system/default/greeter
```

If we store the result in a variable, we can then use `curl` for testing.

> **Pay attention!** You need to add '.json' to the URL for the action to return JSON. '.text' would return text, etc. Go [here](https://medium.com/openwhisk/serverless-http-handlers-with-openwhisk-90a986cc7cdd) for nice article mentioning web actions and other content types.

```
$ export WEB_URL=`./bin/wsk -i action get greeter --url | awk 'FNR==2{print $1}'`
$ curl -k --silent -X GET ${WEB_URL}.json?name=Carlos\&place=Madrid
{
  "payload": "Welcome to Madrid, Carlos"
}
$ curl -k --silent -d '{"name":"Carlos", "place":"Barcelona"}' -H "Content-Type: application/json" -X POST $WEB_URL.json
{
  "payload": "Welcome to Barcelona, Carlos"
}
```

You can run all these calls with `05-node-action-run.sh`

### Java simple demo

The OpenWhisk Java runtime needs your function to have this exact signature.

```
public static com.google.gson.JsonObject main(com.google.gson.JsonObject);
```

Although it's not necessary, as we just said the only requirement is to have a Java class including a method as specified, in this example we're going to use a Maven archetype.

**Our first task is to install the archetype**

> This can also be done by running the script `./06-maven-install-archetype.sh`

```
$ git clone https://github.com/apache/incubator-openwhisk-devtools ./tmp/incubator-openwhisk-devtools
$ cd ./tmp/incubator-openwhisk-devtools/java-action-archetype
$ mvn -DskipTests=true -Dmaven.javadoc.skip=true -B -V clean install
```

**Let's create and deploy a Java function using the archetype as follows**

> You can use the script `07-maven-action-deploy.sh` to do this task or you can also adapt it to your needs, java package name, artifact ID, etc.

```
$ export ARTIFACT_ID="demo-function"
$ mvn archetype:generate \
  -DinteractiveMode=false \
  -DarchetypeGroupId=org.apache.openwhisk.java \
  -DarchetypeArtifactId=java-action-archetype \
  -DarchetypeVersion=1.0-SNAPSHOT \
  -DgroupId=com.redhat.serverless \
  -DartifactId=${ARTIFACT_ID}
 
$ cd ${ARTIFACT_ID}
$ mvn clean package
```

After generating and packaging the sample function a jar file should have been generated at `./${ARTIFACT_ID}/target/${ARTIFACT_ID}.jar`

Next step is to deploy our function in OpenWhisk, to do so we need the name of the action (in the next example is `demo`) the path to the jar file and the fully qualified name of the class that contains our function.

> By default when using the archetype`-DgroupId=com.redhat.serverless` means `--main com.redhat.serverless.FunctionApp`

```
./bin/wsk -i action update demo ./${ARTIFACT_ID}/target/${ARTIFACT_ID}.jar --main com.redhat.serverless.FunctionApp
```

**Running the action**

Running the action is as easy as before.

> Again you can use this script `08-maven-action-run.sh`

```
./bin/wsk -i action invoke demo --result
```

### Java QR generator demo

I've taken the code by Philippe Suter and used it in a Java class generated using the archetype I introduced before.

> The code of the QR generator class is original from Philippe Suter, and can be found [here](https://github.com/psuter/openwhisk-java-gradle).

The mechanics are the same as before, the only change is the code of the function itself.

To deploy the function run the deploy script.

```
$ ./09-maven-action-qr-gen-deploy.sh
...
------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.288 s
[INFO] Finished at: 2018-12-11T19:09:11+01:00
[INFO] Final Memory: 22M/210M
[INFO] ------------------------------------------------------------------------
ok: whisk auth set. Run 'wsk property get --auth' to see the new value.
ok: whisk API host set to openwhisk-openwhisk-demo.apps.serverless-e442.openshiftworkshop.com
ok: updated action qr
```

To run the action you can either call the action like this...

> By adding ` | jq -r '.qr' | base64 --decode > qr.png` you can decode the base64 into a proper PNG

```
$ ./bin/wsk -i action invoke -br qr -p text 'Hola mundo!' 
{
    "qr": "iVBORw0KGgoAAAANSUhEUgAAASwAAAEsAQAAAABRBrPYAAABGklEQVR42u3aOxLCIBCAYag8BkdNjsoRLK1A3hBNokWA0fkpHBI+q51lYSfCfjPuAgaDwWCwn2IPkYaKM2nX9ELCxrH4ZFflZumnXYANYmsIkWr+EGIHm8J8ntxgc1l5hM1gNVEWHYJ1vr/BOrBaxHP5+FDrYdezZpi6eHbuhV3PfKKEiCnHQspYfTN7MYV1Za50B1EW8xYGG8akj44rGsnmC4aAjWSpWCw6nqeMzyB52OiA9WFyc7su2fKeMrB+rI5YSNJRKsQONorVA60/SsUr3VGVgXVjbdPPapEiZvVJ6xXWgW3aTSZly87+BhvAauzyO9gEZmKwSr8PNpI1Tb8wjbsXbCR7afoVcd56hV3K+BwCBoPBYH/DntCZZzz1A5uaAAAAAElFTkSuQmCC"
}
```

...or run this script (again includes several ways to invoke the same action)

```
./10-maven-action-qr-gen-run.sh
```

# Live lab environment

https://learn.openshift.com/serverless/