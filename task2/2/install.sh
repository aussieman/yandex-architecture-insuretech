#!/usr/bin/env bash
set -euo pipefail

# Setup and deployment script for Part 2.
# Run from the task2/2 directory: ./install.sh

root_dir="$(cd "$(dirname "$0")" && pwd)"

# Reset cluster
minikube stop && minikube delete
minikube start

# Install monitoring stack via Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Install Prometheus Adapter for custom metrics
helm install prometheus-adapter prometheus-community/prometheus-adapter -n monitoring -f adapter-values.yaml

# Deploy app manifests
kubectl apply -f "$root_dir/deployment.yaml"
kubectl apply -f "$root_dir/service.yaml"
kubectl apply -f "$root_dir/servicemonitor.yaml"

# Apply HPA
kubectl apply -f "$root_dir/hpa.yaml"

# Wait for Prometheus to become ready (best-effort)
kubectl rollout status statefulset/prometheus-prometheus-kube-prometheus-prometheus -n monitoring --timeout=180s || true

echo "Setup and deployment completed."
