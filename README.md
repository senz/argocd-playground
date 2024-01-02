# ArgoCD playground
Template repo used as a playground for argocd.

## Features
- Docker in docker (rootless)
- Kubectl Helm Minikube
- ArgoCd latest stable
- ArgoCd cli
- k9s
- Gitea

## Configuration
Most of the things are pre-configured on startup. Dind images, cache and data stored in the separate docker volume and will survive devcontainer recreation.

NB: if you wan to completely clean the environment - you need to delete data volumes and the devcontainer itself.

ArgoCD Server: initial password is echo'ed during container creation and could be fined in the logs. Or you can output it again with: `argocd admin initial-password -n argocd`. On attach to the container, argocd server https port is forwarded as 8080.

UI https port is exposed as `tcp 31283` inside of container.

Minikube: node IP inside of container is `"192.168.49.2`. Config is stored in the separate docker volume.

Gitea: http port - `3000`. SSH port - `2222`. Data and state is stored in the separate docker volume.
Admin user `gitea` with password `gitea` is created.
Git repo is automatically cloned as `gitea/repo` (exposed as `http://host.minikube.internal:3000/gitea/repo`) from $REPO_URL env var during container creation. Write token (scopes write:repository) for admin user is available at `/opt/gitea/admin-token`.

Data volume mounted at `/opt/gitea`. Gitea instance is managed with docker compose inside the devcontainer.
