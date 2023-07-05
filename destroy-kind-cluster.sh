#!/bin/bash

CLUSTER_NAME="otel-metrics-simple-flask-app-cluster"

# Verify kind is installed
if ! [ -x "$(command -v kind)" ]; then
    echo "kind is not installed"
    exit 1
fi

# Do nothing if the cluster is already destroyed
if ! [ $(kind get clusters 2>/dev/null | grep "${CLUSTER_NAME}") ]; then
    echo "${CLUSTER_NAME} cluster does not exist"
    exit 0
fi

# Destroy the cluster
while true; do
    read -p "Are you sure you want to destroy the ${CLUSTER_NAME} cluster? (y/n) " yn
    case $yn in
        [Yy]* ) kind delete cluster --name $CLUSTER_NAME; break;;
        [Nn]* ) exit 0;;
        * ) echo "Please answer y or n.";;
    esac
done

echo "> Cluster $CLUSTER_NAME destroyed"