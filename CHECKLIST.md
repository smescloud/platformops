# Prereq checklist

## Node/OS level
- [ ] Private NIC present and reachable on every node
- [ ] `open-iscsi` installed on all nodes
- [ ] `nfs-common` installed on all nodes
- [ ] `iscsid` enabled and running on all nodes
- [ ] `/var/lib/longhorn` mounted on all nodes
- [ ] worker labels applied

## Kubernetes level
- [ ] control plane healthy
- [ ] workers joined and `Ready`
- [ ] Calico healthy
- [ ] Argo CD installed manually

## Manual Kubernetes objects before root app
- [ ] namespace `cert-manager`
- [ ] namespace `auth`
- [ ] secret `cert-manager/cloudflare-api-token-secret`
- [ ] secret `auth/keycloak-db-secret`
- [ ] secret `auth/keycloak-admin-secret`

## Git edits before first sync
- [ ] set real Grafana admin password in `clusters/eu001/overlays/monitoring-values.yaml`
- [ ] verify repo URL and revision in `clusters/eu001/bootstrap/root-app.yaml`
- [ ] verify Keycloak hostname `auth-eu001.smescloud.com`

## Apply
- [ ] `kubectl apply -f clusters/eu001/bootstrap/root-app.yaml`
