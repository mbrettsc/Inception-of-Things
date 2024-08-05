#!/bin/bash

k3d cluster create mbrettsc -p "8888:80@loadbalancer" 

kubectl create namespace argocd && kubectl create namespace dev

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 5

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

kubectl apply -f confs/argocd/ -n argocd

echo -e "\n\033[1mArgoCD Admin Password:\033[0m"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode ; echo

echo -e "\n\033[1mArgoCD Port Forwarding:\033[0m"
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
echo "ArgoCD is now running on https://localhost:8080"
