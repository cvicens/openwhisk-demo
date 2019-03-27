# Environment
. ./00-environment.sh

GROUP="openwhisk-users"

USERS=""
for i in {1..99}
do
   USERS="user$i ${USERS}"
done

oc adm groups new ${GROUP} ${USERS}

oc create role secretlist --verb=list --resource=secret -n ${PROJECT_NAME}
oc adm policy add-role-to-group secretlist ${GROUP} --role-namespace=${PROJECT_NAME} -n ${PROJECT_NAME}

oc create role secretget --verb=get --resource=secret -n ${PROJECT_NAME}
oc adm policy add-role-to-group secretget ${GROUP} --role-namespace=${PROJECT_NAME} -n ${PROJECT_NAME}

oc create role routeget --verb=get --resource=route -n ${PROJECT_NAME}
oc adm policy add-role-to-group routeget ${GROUP} --role-namespace=${PROJECT_NAME} -n ${PROJECT_NAME}


