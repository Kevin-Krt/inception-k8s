#!/bin/bash
set -e

CLUSTER=inception

docker build -t inception/mariadb:v1   ./docker/mariadb
docker build -t inception/wordpress:v1 ./docker/wordpress
docker build -t inception/nginx:v1     ./docker/nginx

k3d image import \
  inception/mariadb:v1 \
  inception/wordpress:v1 \
  inception/nginx:v1 \
  -c "$CLUSTER"

kubectl apply -f k8s/
kubectl rollout restart deployment/wordpress