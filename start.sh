#!/bin/bash

ES_RC="eventstore-controller"
ES_SVC="eventstore"
KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)

jRc=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/replicationcontrollers/${ES_RC})
replicas=$(echo $jRc | jq '.status.replicas')

jSvc=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/services/${ES_SVC})

ext_http=$(echo $jSvc | jq '.spec.ports[] | select(.name | contains("ext-http")) | .targetPort')
ext_tcp=$(echo $jSvc | jq '.spec.ports[] | select(.name | contains("ext-tcp")) | .targetPort')
int_http=$(echo $jSvc | jq '.spec.ports[] | select(.name | contains("int-http")) | .targetPort')
int_tcp=$(echo $jSvc | jq '.spec.ports[] | select(.name | contains("int-tcp")) | .targetPort')

podIp=$(ifconfig eth0 | grep "inet " | awk -F'[: ]+' '{ print $4 }')

exec $EVENTSTORE_HOME/run-node.sh --int-ip=${podIp} --ext-ip=${podIp} --int-tcp-port=${int_tcp} --ext-tcp-port=${ext_tcp} --int-http-port=${int_http} --ext-http-port=${ext_http} --cluster-size=${replicas} --cluster-dns=${ES_SVC} --cluster-gossip-port=${int_http} --int-http-prefixes="http://*:${int_http}/" --ext-http-prefixes="http://*:${ext_http}/" --add-interface-prefixes=false --run-projections=all


