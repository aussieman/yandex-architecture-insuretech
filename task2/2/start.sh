#!/usr/bin/env bash
set -euo pipefail

# Script to start port-forwarding for services.
# Assumes services are already deployed via install.sh

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -i :$port >/dev/null 2>&1; then
        echo "Port $port is in use. Freeing it..."
        local pid=$(lsof -t -i :$port)
        kill -9 $pid
        sleep 2
    else
        echo "Port $port is free."
    fi
}

# Check and free ports
check_port 9090  # prometheus
check_port 3333  # grafana

# Ensure minikube is running
if ! minikube status >/dev/null 2>&1; then
    echo "Minikube is not running. Please run ./install.sh first."
    exit 1
fi

# Wait for monitoring pods to be ready
echo "Waiting for monitoring pods to be ready..."
kubectl wait --for=condition=ready pod --all -n monitoring --timeout=300s || true

# Start port-forwarding in background
echo "Starting port-forwarding..."
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &
kubectl port-forward -n monitoring svc/prometheus-grafana 3333:80 &

echo "All services are running:"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3333"

# Get and display Grafana password
grafana_password=$(kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)
echo "Grafana admin password: $grafana_password"