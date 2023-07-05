#!/bin/bash

# Verify kind is installed
if ! [ -x "$(command -v kind)" ]; then
    echo "kind is not installed"
    exit 1
fi

CLUSTER_NAME="otel-metrics-simple-flask-app-cluster"

# Verify if this kind cluster is present
if ! [ $(kind get clusters 2>/dev/null | grep "${CLUSTER_NAME}") ]; then
    echo "${CLUSTER_NAME} cluster does not exist"
    exit 0
fi

echo ""
# Verify if the kubectl context is set to this kind cluster
echo "> Verifying if the kubectl context is set to kind-${CLUSTER_NAME}"
if [ $(kubectl config current-context) != "kind-${CLUSTER_NAME}" ]; then
    echo "> kubectl context is not set to kind-${CLUSTER_NAME}"
    echo "> Setting the context to kind-${CLUSTER_NAME}"
    kubectl config use-context kind-$CLUSTER_NAME
    echo "> Context set to kind-${CLUSTER_NAME}"
else
    echo "> kubectl context is already set to kind-${CLUSTER_NAME}"
fi

echo ""
echo "> Deploying the flask deployment"
kubectl apply -f ./k8s/simple-flask-app-deployment.yaml
echo "> flask deployment deployed"

echo ""
echo "> Deploying the flask service"
kubectl apply -f ./k8s/simple-flask-app-service.yaml
echo "> flask service deployed"

echo ""