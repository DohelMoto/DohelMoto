#!/bin/bash

# DohelMoto Kubernetes Cleanup Script
# This script removes all Kubernetes resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

NAMESPACE="ecommerce"

echo -e "${YELLOW}🧹 Starting DohelMoto Kubernetes Cleanup${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig.${NC}"
    exit 1
fi

echo -e "${YELLOW}🗑️  Deleting all resources in namespace: $NAMESPACE${NC}"

# Delete all resources in the namespace
kubectl delete all --all -n $NAMESPACE --ignore-not-found=true
kubectl delete pvc --all -n $NAMESPACE --ignore-not-found=true
kubectl delete configmap --all -n $NAMESPACE --ignore-not-found=true
kubectl delete secret --all -n $NAMESPACE --ignore-not-found=true
kubectl delete ingress --all -n $NAMESPACE --ignore-not-found=true
kubectl delete hpa --all -n $NAMESPACE --ignore-not-found=true

echo -e "${GREEN}✅ All resources deleted from namespace: $NAMESPACE${NC}"

# Ask if user wants to delete the namespace
read -p "Do you want to delete the namespace '$NAMESPACE' as well? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    echo -e "${GREEN}✅ Namespace '$NAMESPACE' deleted${NC}"
else
    echo -e "${YELLOW}ℹ️  Namespace '$NAMESPACE' kept (empty)${NC}"
fi

echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"
