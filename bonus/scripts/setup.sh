#!/bin/bash

kubectl create namespace gitlab

# Install Gitlab using Helm
helm repo add gitlab -n gitlab https://charts.gitlab.io/
helm repo update
sudo helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f confs/gitlab/values.yaml \
  --set global.hosts.domain=k3d.gitlab.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

sleep 5

echo "Waiting for Gitlab to be ready..."
kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode; echo

kubectl port-forward svc/gitlab-webservice-default -n gitlab 80:8181 2>&1 >/dev/null &
