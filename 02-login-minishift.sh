#!/bin/bash

# configures the host talk to DOCKER daemon of minishift
eval $(minishift docker-env)
# Adds the right version of openshift cli binary to $PATH
eval $(minishift oc-env)

oc login $(minishift ip):8443 -u admin -p admin
