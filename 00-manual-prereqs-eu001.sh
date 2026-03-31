#!/usr/bin/env bash
set -euo pipefail

kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace auth --dry-run=client -o yaml | kubectl apply -f -

echo "Create/update Cloudflare token secret"
kubectl -n cert-manager create secret generic cloudflare-api-token-secret   --from-literal=api-token='REPLACE_WITH_CLOUDFLARE_API_TOKEN'   --dry-run=client -o yaml | kubectl apply -f -

echo "Create/update Keycloak database secret"
kubectl -n auth create secret generic keycloak-db-secret   --from-literal=username='keycloak'   --from-literal=password='REPLACE_WITH_DB_PASSWORD'   --from-literal=database='keycloak'   --dry-run=client -o yaml | kubectl apply -f -

echo "Create/update Keycloak admin secret"
kubectl -n auth create secret generic keycloak-admin-secret   --from-literal=username='admin'   --from-literal=password='REPLACE_WITH_ADMIN_PASSWORD'   --dry-run=client -o yaml | kubectl apply -f -

echo "Create/update Grafana admin secret"
kubectl -n monitoring create secret generic grafana-admin-secret \
  --from-literal=admin-user='admin' \
  --from-literal=admin-password='REPLACE_WITH_GRAFANA_PASSWORD' \
  --dry-run=client -o yaml | kubectl apply -f -