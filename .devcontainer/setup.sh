#!/bin/bash

set -x
minikube start --apiserver-ips=192.168.49.2
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

timeout 100s bash -c 'until kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=100s; do sleep 3 ; done'
argocd admin initial-password -n argocd

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl patch service argocd-server -n argocd --type='json' -p '[{"op":"replace","path":"/spec/ports/1/nodePort","value":31283}]'
minikube service argocd-server -n argocd

# see https://docs.gitea.com/next/installation/install-with-docker-rootless#basics
sudo mkdir -p /opt/gitea/{data,config}
sudo chown -R 1000:1000 /opt/gitea/

cp -u --no-preserve=mode,ownership .devcontainer/app.ini /opt/gitea/config/app.ini

cd .devcontainer
docker compose up -d --wait --quiet-pull
docker compose run server sh -c 'gitea admin user create --username gitea --password gitea --admin --email admin@example.com'
if [ ! -f /opt/gitea/admin-token ]; then
    # gitea screws up output with warnings, so we take only the last line
    docker compose run server sh -c 'gitea admin user generate-access-token -u gitea --scopes write:repository --raw' |tail -n 1 > /opt/gitea/admin-token 
fi
cd -

export ADMIN_TOKEN="$(cat /opt/gitea/admin-token)"

timeout 100s bash -c 'until curl -s -o /dev/null http://localhost:3000; do sleep 3 ; done'

./scripts/gitea-import.sh $REPO_URL repo

echo use http://host.minikube.internal:3000/ to reach gitea from argocd
