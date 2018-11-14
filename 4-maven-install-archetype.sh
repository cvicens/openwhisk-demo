#!/bin/bash
# https://github.com/apache/incubator-openwhisk-deploy-openshift

# Environment
. ./0-environment.sh

BASE_DIR=$(pwd)

# Clone archetype git repo
git clone https://github.com/apache/incubator-openwhisk-devtools ./tmp/incubator-openwhisk-devtools
cd ./tmp/incubator-openwhisk-devtools/java-action-archetype

# Install the archetype
echo "Installing OpenWhisk Java Archetype (java-action-archetype)"
mvn -DskipTests=true -Dmaven.javadoc.skip=true -B -V clean install

cd ${BASE_DIR}