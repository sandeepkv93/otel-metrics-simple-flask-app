#!/bin/bash

# Verify kind is installed
if ! [ -x "$(command -v kind)" ]; then
    echo "kind is not installed"
    exit 1
fi

CLUSTER_NAME="otel-metrics-simple-flask-app-cluster"
CLUSTER_CONFIG_FILE="./k8s/three-node-cluster-config.yaml"
echo "> Creating cluster $CLUSTER_NAME from $CLUSTER_CONFIG_FILE"
kind create cluster --config $CLUSTER_CONFIG_FILE --name $CLUSTER_NAME
echo "> Cluster $CLUSTER_NAME created"

echo ""
# Set the context to the new cluster
echo "> Setting the context to the new cluster"
kubectl config use-context kind-$CLUSTER_NAME 
echo "> Context set to kind-$CLUSTER_NAME"

echo ""
# Build the flask app image
echo "> Building the flask app image"
docker build -t simpleflaskapp .

echo ""
# Load the flask app image into the cluster
echo "> Loading the flask app image into the cluster"
kind load docker-image simpleflaskapp:latest --name $CLUSTER_NAME

echo ""
# Pull the otel-collector image
echo "> Pulling the otel-collector image"
docker pull otel/opentelemetry-collector-contrib:latest

echo ""
# Load the otel-collector image into the cluster
echo "> Loading the otel-collector image into the cluster"
kind load docker-image otel/opentelemetry-collector-contrib:latest --name $CLUSTER_NAME

echo ""
echo "> Successfully created and initialized cluster $CLUSTER_NAME"