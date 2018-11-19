#!/bin/bash

# Environment
. ./00-environment.sh

# add the location of minishift executable to PATH
# I also keep other handy tools like kubectl and kubetail.sh
# in that directory

minishift profile set ${MINISHIFT_PROFILE}

minishift config set openshift-version ${MINISHIFT_VERSION}

minishift config set memory ${MINISHIFT_MEMORY}
minishift config set cpus ${MINISHIFT_CPUS}
minishift config set vm-driver ${MINISHIFT_VM_DRIVER} ## or virtualbox, or kvm, for Fedora
minishift config set disk-size ${MINISHIFT_DISK_SIZE} # extra disk size for the vm
minishift config set image-caching true

minishift addons enable admin-user

minishift addons enable anyuid

minishift start
minishift ssh -- sudo setenforce 0
