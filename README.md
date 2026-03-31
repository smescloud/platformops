# SMEsCloud Foundation v2

This bundle gives you a clean starting point for `eu001` with these components only:

- Traefik (official Helm chart)
- cert-manager (official Helm chart)
- ClusterIssuers: HTTP01 and Cloudflare DNS01
- Longhorn (official Helm chart)
- Monitoring with kube-prometheus-stack
- Keycloak + PostgreSQL as plain manifests managed by Argo CD

It intentionally does **not** include tenant ApplicationSets yet. That comes later, after the platform layer is stable.

## Repo layout

```text
platform/
  infra/
    namespaces/
    traefik/
    cert-manager/
      issuers/
    longhorn/
    monitoring/
    auth/
      base/
clusters/
  eu001/
    apps/
      auth/
    overlays/
    root/
      infra-apps/
    bootstrap/
```

## Why this structure

- `platform/infra/*` = reusable platform building blocks
- `clusters/eu001/overlays/*` = cluster-specific Helm values
- `clusters/eu001/apps/auth/*` = cluster-specific app wiring for Keycloak hostname/TLS
- future tenant apps can live under `clusters/eu001/tenants/*`

## Manual prerequisites before Argo root app

1. Kubernetes cluster is already up.
2. All nodes have:
   - containerd, kubelet, kubeadm, kubectl
   - `open-iscsi`
   - `nfs-common`
   - `iscsid` enabled and running
   - `/var/lib/longhorn` mounted
3. Worker labels are applied:

```bash
kubectl label node eu001w001 smescloud.com/node-role=worker --overwrite
kubectl label node eu001w001 smescloud.com/storage=longhorn --overwrite
kubectl label node eu001w001 smescloud.com/ingress=true --overwrite

kubectl label node eu001w002 smescloud.com/node-role=worker --overwrite
kubectl label node eu001w002 smescloud.com/storage=longhorn --overwrite
kubectl label node eu001w002 smescloud.com/ingress=true --overwrite
```

4. Argo CD is installed manually in `argocd`.
5. Before applying the root app, create only these namespaces and secrets manually:

```bash
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace auth --dry-run=client -o yaml | kubectl apply -f -

kubectl -n cert-manager create secret generic cloudflare-api-token-secret   --from-literal=api-token='REPLACE_WITH_CLOUDFLARE_API_TOKEN'   --dry-run=client -o yaml | kubectl apply -f -

kubectl -n auth create secret generic keycloak-db-secret   --from-literal=username='keycloak'   --from-literal=password='REPLACE_WITH_DB_PASSWORD'   --from-literal=database='keycloak'   --dry-run=client -o yaml | kubectl apply -f -

kubectl -n auth create secret generic keycloak-admin-secret   --from-literal=username='admin'   --from-literal=password='REPLACE_WITH_ADMIN_PASSWORD'   --dry-run=client -o yaml | kubectl apply -f -
```

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl -n monitoring create secret generic grafana-admin-secret \
  --from-literal=admin-user='admin' \
  --from-literal=admin-password='REPLACE_WITH_GRAFANA_PASSWORD' \
  --dry-run=client -o yaml | kubectl apply -f -

6. Edit these files before first bootstrap:
   - `clusters/eu001/overlays/monitoring-values.yaml` → set Grafana admin password
   - `clusters/eu001/bootstrap/root-app.yaml` → set correct repo URL / revision if needed

## Bootstrap

Apply only this file after Argo CD is ready:

```bash
kubectl apply -f clusters/eu001/bootstrap/root-app.yaml
```

## Sync order

- wave -2: namespaces
- wave -1: cert-manager
- wave 0: traefik
- wave 1: ClusterIssuers
- wave 2: longhorn
- wave 3: monitoring
- wave 4: auth

## Notes

- This design keeps Traefik on worker nodes and exposes NodePorts 30080/30443. Your master can remain the only public entry node by forwarding public 80/443 to those NodePorts.
- Traefik CRDs are handled by the official Helm chart. You do not need a separate manual CRD/RBAC app unless you deliberately choose to manage Traefik without Helm.
- Keycloak is plain manifests, not Bitnami.
