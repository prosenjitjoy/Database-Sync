#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

# Check if buildah is present in host os
if [ -z "$(command -v podman)" ]; then
  echo "ERR: podman is not installed"
  echo "RUN: sudo apt install podman"
  exit 1
fi

podman network create cluster

podman run --name nodeX --network cluster --hostname nodeX -v ./cassandra/cassandra.yaml:/etc/cassandra/cassandra.yaml -v ./cassandra/nodeX:/var/lib/cassandra -m 1.2G -d cassandra:latest && sleep 60

podman run --name nodeY --network cluster --hostname nodeY -v ./cassandra/cassandra.yaml:/etc/cassandra/cassandra.yaml -v ./cassandra/nodeY:/var/lib/cassandra -e CASSANDRA_SEEDS=nodeX -m 1.2G -d cassandra:latest && sleep 60

podman run --name nodeZ --network cluster --hostname nodeZ -v ./cassandra/cassandra.yaml:/etc/cassandra/cassandra.yaml -v ./cassandra/nodeZ:/var/lib/cassandra -e CASSANDRA_SEEDS=nodeX,nodeY -m 1.2G -d cassandra:latest && sleep 60

podman exec -it nodeX nodetool status

# podman exec -it nodeX cqlsh

# go get -u github.com/gocql/gocql

