#!/bin/sh

# Apply vault-agent demo configurations

kubectl apply -f configs/vault-agent-colinapp.yaml
kubectl apply -f configs/vault-agent-lewisapp.yaml

echo ""
echo "ColinApp Minikube Service URL:"

minikube service --url vault-agent-colinapp

echo ""
echo "LewisApp Minikube Service URL:"

minikube service --url vault-agent-lewisapp