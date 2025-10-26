#!/bin/bash

# DohelMoto Kubernetes Deployment Script
# This script handles ECR authentication and deploys the application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="us-east-1"
ECR_REGISTRY="463470983018.dkr.ecr.us-east-1.amazonaws.com"
NAMESPACE="ecommerce"

echo -e "${GREEN}🚀 Starting DohelMoto Kubernetes Deployment${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if aws CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install AWS CLI first.${NC}"
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ AWS credentials configured${NC}"

# Create namespace if it doesn't exist
echo -e "${YELLOW}📦 Creating namespace...${NC}"
kubectl apply -f namespace.yaml

# Create ECR secret
echo -e "${YELLOW}🔐 Creating ECR authentication secret...${NC}"
kubectl delete secret ecr-registry-secret -n $NAMESPACE --ignore-not-found=true

# Get ECR login token
ECR_TOKEN=$(aws ecr get-login-password --region $AWS_REGION)

# Create docker config
kubectl create secret docker-registry ecr-registry-secret \
    --docker-server=$ECR_REGISTRY \
    --docker-username=AWS \
    --docker-password=$ECR_TOKEN \
    --namespace=$NAMESPACE

echo -e "${GREEN}✅ ECR secret created${NC}"

# Apply all configurations
echo -e "${YELLOW}📋 Applying Kubernetes configurations...${NC}"

# Apply in order to ensure dependencies are met
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml

echo -e "${GREEN}✅ All configurations applied${NC}"

# Wait for deployments to be ready
echo -e "${YELLOW}⏳ Waiting for deployments to be ready...${NC}"

kubectl wait --for=condition=available --timeout=300s deployment/postgres -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/redis -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/backend -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n $NAMESPACE

echo -e "${GREEN}✅ All deployments are ready${NC}"

# Show service information
echo -e "${YELLOW}📊 Service Information:${NC}"
kubectl get services -n $NAMESPACE

echo -e "${YELLOW}📊 Pod Status:${NC}"
kubectl get pods -n $NAMESPACE

echo -e "${YELLOW}📊 Ingress Information:${NC}"
kubectl get ingress -n $NAMESPACE

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${YELLOW}💡 To access the application:${NC}"
echo -e "   - Frontend: http://localhost (if using port forwarding)"
echo -e "   - Backend API: http://localhost/api"
echo -e "   - Or use the LoadBalancer external IP from the ingress service"

echo -e "${YELLOW}🔧 Useful commands:${NC}"
echo -e "   - View logs: kubectl logs -f deployment/backend -n $NAMESPACE"
echo -e "   - Port forward: kubectl port-forward service/frontend-service 3000:80 -n $NAMESPACE"
echo -e "   - Scale backend: kubectl scale deployment backend --replicas=5 -n $NAMESPACE"
