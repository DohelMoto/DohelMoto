# it's known that every 12 hour the secret lifetime has got to an end. so every 12 hours we should run this script. 


#!/bin/bash

NAMESPACE="ecommerce"
AWS_REGION="us-east-1"
ECR_URL="463470983018.dkr.ecr.us-east-1.amazonaws.com"

echo "🔄 Refreshing ECR credentials..."
kubectl delete secret ecr-registry-secret -n $NAMESPACE --ignore-not-found

kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=$ECR_URL \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region $AWS_REGION)" \
  -n $NAMESPACE

echo "✅ ECR Secret updated."

echo "♻️ Restarting Deployment pods..."
kubectl delete pod -n $NAMESPACE -l component=backend --ignore-not-found
kubectl delete pod -n $NAMESPACE -l component=frontend --ignore-not-found

echo "⏳ Waiting for pods to start..."
kubectl wait --for=condition=Available deployment/backend-dohelmoto-backend -n $NAMESPACE --timeout=90s
kubectl wait --for=condition=Available deployment/backend-dohelmoto-frontend -n $NAMESPACE --timeout=90s

echo "🎉 Done! All services are up."
kubectl get pods -n $NAMESPACE

