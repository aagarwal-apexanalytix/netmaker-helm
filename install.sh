#!/bin/bash
set -e

echo "=========================================="
echo "Netmaker K8s Installation Script"
echo "=========================================="
echo ""

# Step 1: Install PostgreSQL HA
echo "Step 1: Installing PostgreSQL HA..."
helm install netmaker-postgres oci://registry-1.docker.io/bitnamicharts/postgresql-ha \
  --version 11.8.1 \
  --set global.imageRegistry=public.ecr.aws \
  --set postgresql.image.registry=public.ecr.aws \
  --set postgresql.image.repository=bitnami/postgresql-repmgr \
  --set postgresql.image.tag=18.0.0-debian-12-r12 \
  --set postgresql.image.pullPolicy=IfNotPresent \
  --set postgresql.database=netmaker \
  --set postgresql.username=postgres \
  --set postgresql.password=password123 \
  --set postgresql.replicaCount=2 \
  --set postgresql.repmgrUsername=repmgr \
  --set postgresql.repmgrPassword=password123 \
  --set postgresql.repmgrDatabase=repmgr \
  --set pgpool.image.registry=public.ecr.aws \
  --set pgpool.image.repository=bitnami/pgpool \
  --set pgpool.image.tag=4.6.3-debian-12-r5 \
  --set pgpool.image.pullPolicy=IfNotPresent \
  --set persistence.size=1Gi \
  --namespace netmaker \
  --create-namespace \
  --wait

echo ""
echo "PostgreSQL installed successfully!"
echo ""

# Step 2: Install Netmaker
echo "Step 2: Installing Netmaker..."
helm repo add netmaker https://gravitl.github.io/netmaker-helm/
helm repo update
helm install netmaker netmaker/netmaker \
  --set postgresql-ha.enabled=false \
  --set db.type=postgres \
  --set db.host=netmaker-postgres-postgresql-ha-pgpool \
  --set db.port=5432 \
  --set db.username=postgres \
  --set db.password=password123 \
  --set db.database=netmaker \
  --set ui.image.repository=gravitl/netmaker-ui \
  --set ui.image.pullPolicy=Always \
  --set ui.image.tag=v1.1.0 \
  --set server.image.repository=gravitl/netmaker \
  --set server.image.pullPolicy=Always \
  --set server.image.tag=v1.1.0 \
  --namespace netmaker

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "PostgreSQL service: netmaker-postgres-postgresql-ha-pgpool"
echo "Namespace: netmaker"
echo ""
echo "Check pod status with:"
echo "  kubectl get pods -n netmaker"
echo ""

