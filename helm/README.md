# DohelMoto Helm Chart

This Helm chart deploys the DohelMoto e-commerce platform on Kubernetes.

> **Note**: The automated deployment script has been removed. Please follow the manual deployment steps below for better control and understanding of the deployment process.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- kubectl configured to connect to your cluster
- AWS CLI configured for ECR access

## Quick Start

### 1. Prerequisites Setup

Before deploying, make sure you have:

```bash
# 1. Install Helm (if not already installed)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 2. Configure AWS CLI (if not already configured)
aws configure

# 3. Verify kubectl is working
kubectl cluster-info
```

### 2. ECR Authentication Setup

```bash
# Create ECR secret for image pulling
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=463470983018.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=default
```

### 3. Deploy the Application

```bash
# Navigate to helm directory
cd helm

# Option 1: Install to existing namespace
helm install dohelmoto . -n my-app

# Option 2: Install to default namespace
helm install dohelmoto . -n default

# Option 3: Install with custom values
helm install dohelmoto . -n production \
  --set frontend.replicaCount=5 \
  --set backend.replicaCount=5

# Option 4: Install with custom values file
helm install dohelmoto . -n staging -f custom-values.yaml
```

**Note**: This chart requires an existing namespace. Create the namespace first if it doesn't exist:
```bash
kubectl create namespace my-app
helm install dohelmoto . -n my-app
```

### 4. Verify Deployment

```bash
# Check pods status
kubectl get pods -n default

# Check services
kubectl get services -n default

# Check Helm release
helm status dohelmoto -n default
```

### 5. Access the Application

```bash
# Port forward for local access
kubectl port-forward service/frontend-service 3000:80 -n default &
kubectl port-forward service/backend-service 8000:8000 -n default &

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
```

### 6. Manual Deployment (Alternative)

```bash
# Create namespace
kubectl create namespace ecommerce

# Create ECR secret
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=463470983018.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=ecommerce

# Install the chart
helm install dohelmoto ./dohelmoto -n ecommerce

# Or upgrade if already installed
helm upgrade dohelmoto ./dohelmoto -n ecommerce
```

## Configuration

The chart can be configured using the `values.yaml` file or by passing values via `--set` or `--values` flags.

### Key Configuration Options

#### Image Configuration
```yaml
image:
  registry: 463470983018.dkr.ecr.us-east-1.amazonaws.com
  pullPolicy: Always

frontend:
  image:
    repository: dohelmoto-frontend
    tag: latest

backend:
  image:
    repository: dohelmoto-backend
    tag: latest
```

#### Scaling Configuration
```yaml
frontend:
  replicaCount: 3
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10

backend:
  replicaCount: 3
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
```

#### Storage Configuration
```yaml
postgresql:
  persistence:
    enabled: true
    size: 20Gi
    storageClass: "local-path"

redis:
  persistence:
    enabled: true
    size: 10Gi
    storageClass: "local-path"
```

#### Ingress Configuration
```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: dohelmoto.com
      paths:
        - path: /api(/|$)(.*)
          pathType: ImplementationSpecific
          service:
            name: backend-service
            port: 8000
        - path: /
          pathType: Prefix
          service:
            name: frontend-service
            port: 80
```

## Chart Components

### Core Components
- **Namespace**: `ecommerce` namespace
- **ConfigMap**: Non-sensitive configuration data
- **Secret**: Sensitive data (passwords, API keys)
- **ECR Secret**: ECR authentication secret

### Application Components
- **Frontend**: React application with Nginx
- **Backend**: Python FastAPI application
- **PostgreSQL**: Database with persistent storage
- **Redis**: Cache with persistent storage
- **Ingress**: External access configuration

### Optional Components
- **HorizontalPodAutoscaler**: Auto-scaling for frontend and backend
- **PersistentVolumeClaim**: Persistent storage for database and cache

## Values Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `frontend.enabled` | Enable frontend deployment | `true` |
| `frontend.replicaCount` | Number of frontend replicas | `3` |
| `frontend.image.repository` | Frontend image repository | `dohelmoto-frontend` |
| `frontend.image.tag` | Frontend image tag | `latest` |
| `backend.enabled` | Enable backend deployment | `true` |
| `backend.replicaCount` | Number of backend replicas | `3` |
| `backend.image.repository` | Backend image repository | `dohelmoto-backend` |
| `backend.image.tag` | Backend image tag | `latest` |
| `postgresql.enabled` | Enable PostgreSQL deployment | `true` |
| `postgresql.persistence.size` | PostgreSQL storage size | `20Gi` |
| `redis.enabled` | Enable Redis deployment | `true` |
| `redis.persistence.size` | Redis storage size | `10Gi` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `nginx` |
| `global.storageClass` | Global storage class | `local-path` |

## Environment Variables

### Backend Environment Variables
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `ALLOWED_ORIGINS`: CORS allowed origins
- `AWS_REGION`: AWS region
- `SECRET_KEY`: JWT secret key
- `GOOGLE_CLIENT_ID`: Google OAuth client ID
- `GOOGLE_CLIENT_SECRET`: Google OAuth client secret
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_BUCKET_NAME`: S3 bucket name
- `OPENAI_API_KEY`: OpenAI API key
- `STRIPE_SECRET_KEY`: Stripe secret key
- `STRIPE_PUBLISHABLE_KEY`: Stripe publishable key

### Frontend Environment Variables
- `REACT_APP_API_URL`: Backend API URL
- `REACT_APP_API_URL_PUBLIC`: Public API URL
- `REACT_APP_STRIPE_PUBLISHABLE_KEY`: Stripe publishable key
- `NODE_ENV`: Node environment

## Scaling

The chart includes Horizontal Pod Autoscalers (HPA) for both frontend and backend:

```yaml
frontend:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80

backend:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80
```

## Monitoring

### View Logs
```bash
# Backend logs
kubectl logs -f deployment/dohelmoto-backend -n ecommerce

# Frontend logs
kubectl logs -f deployment/dohelmoto-frontend -n ecommerce

# PostgreSQL logs
kubectl logs -f deployment/dohelmoto-postgres -n ecommerce

# Redis logs
kubectl logs -f deployment/dohelmoto-redis -n ecommerce
```

### Check Status
```bash
# Pod status
kubectl get pods -n ecommerce

# Service status
kubectl get services -n ecommerce

# Ingress status
kubectl get ingress -n ecommerce

# HPA status
kubectl get hpa -n ecommerce

# Helm status
helm status dohelmoto -n ecommerce
```

## Common Operations

### Upgrade the Chart
```bash
# Basic upgrade
helm upgrade dohelmoto ./dohelmoto -n default

# Upgrade with custom values
helm upgrade dohelmoto ./dohelmoto -n default -f custom-values.yaml

# Upgrade with specific values
helm upgrade dohelmoto ./dohelmoto -n default --set frontend.replicaCount=5
```

### Scale Services
```bash
# Scale frontend
kubectl scale deployment dohelmoto-frontend --replicas=5 -n default

# Scale backend
kubectl scale deployment dohelmoto-backend --replicas=5 -n default
```

### View Logs
```bash
# Backend logs
kubectl logs -f deployment/dohelmoto-backend -n default

# Frontend logs
kubectl logs -f deployment/dohelmoto-frontend -n default

# PostgreSQL logs
kubectl logs -f deployment/dohelmoto-postgres -n default

# Redis logs
kubectl logs -f deployment/dohelmoto-redis -n default
```

### Debug Issues
```bash
# Check pod status
kubectl get pods -n default

# Describe pod for detailed info
kubectl describe pod <pod-name> -n default

# Check events
kubectl get events -n default --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n default
```

### Update ECR Secret
```bash
# Delete old secret
kubectl delete secret ecr-registry-secret -n default

# Create new secret
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=463470983018.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=default

# Restart deployments to use new secret
kubectl rollout restart deployment/dohelmoto-backend -n default
kubectl rollout restart deployment/dohelmoto-frontend -n default
```

## Uninstalling

### Uninstall the Chart
```bash
helm uninstall dohelmoto -n ecommerce
```

### Uninstall and Delete Namespace
```bash
helm uninstall dohelmoto -n ecommerce
kubectl delete namespace ecommerce
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Image Pull Errors (401 Unauthorized)
**Problem**: Pods stuck in `ImagePullBackOff` or `ErrImagePull`
**Solution**:
```bash
# Check if ECR secret exists
kubectl get secret ecr-registry-secret -n default

# If not exists, create it
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=463470983018.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=default

# Restart deployments
kubectl rollout restart deployment/dohelmoto-backend -n default
kubectl rollout restart deployment/dohelmoto-frontend -n default
```

#### 2. Frontend CrashLoopBackOff
**Problem**: Frontend pods crashing due to nginx permissions
**Solution**: This is usually resolved automatically, but if persistent:
```bash
# Check logs
kubectl logs deployment/dohelmoto-frontend -n default

# If nginx permission issues, the pod should restart and work
```

#### 3. Database Connection Issues
**Problem**: Backend can't connect to PostgreSQL
**Solution**:
```bash
# Check if PostgreSQL is running
kubectl get pods -l component=postgres -n default

# Check PostgreSQL logs
kubectl logs deployment/dohelmoto-postgres -n default

# Check if PVC is bound
kubectl get pvc -n default
```

#### 4. Namespace Ownership Issues
**Problem**: Helm can't manage resources due to namespace ownership
**Solution**:
```bash
# Delete and recreate namespace
kubectl delete namespace ecommerce --ignore-not-found=true
helm install dohelmoto ./dohelmoto -n ecommerce --create-namespace
```

#### 5. Storage Issues
**Problem**: PVC not binding
**Solution**:
```bash
# Check storage classes
kubectl get storageclass

# Check PVC status
kubectl get pvc -n default

# If using local-path, ensure it's available
kubectl get pods -n kube-system | grep local-path
```

### Debug Commands

```bash
# Check overall status
kubectl get all -n default

# Check specific pod
kubectl describe pod <pod-name> -n default

# Check events
kubectl get events -n default --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n default
kubectl top nodes

# Check Helm status
helm status dohelmoto -n default
helm history dohelmoto -n default

# Rollback if needed
helm rollback dohelmoto <revision> -n default
```

### Health Checks

```bash
# Backend health
kubectl port-forward service/backend-service 8000:8000 -n default &
curl http://localhost:8000/health

# Frontend
kubectl port-forward service/frontend-service 3000:80 -n default &
curl http://localhost:3000
```

## Security Notes

1. **Secrets**: Update the secret values in `values.yaml` with your actual credentials
2. **ECR Authentication**: The ECR secret needs to be refreshed periodically
3. **Network Policies**: Consider implementing network policies for additional security
4. **RBAC**: Consider implementing Role-Based Access Control for production

## Production Considerations

1. **SSL/TLS**: Configure SSL certificates for HTTPS
2. **Monitoring**: Implement proper monitoring and alerting
3. **Backup**: Set up database backups
4. **Resource Limits**: Adjust resource requests and limits based on actual usage
5. **Security**: Implement proper security policies and RBAC
6. **Logging**: Set up centralized logging
7. **CI/CD**: Implement automated deployment pipelines

## Usage Examples

### Example 1: Basic Deployment
```bash
# 1. Setup ECR secret
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=463470983018.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=default

# 2. Deploy
cd helm
helm install dohelmoto ./dohelmoto -n default

# 3. Access
kubectl port-forward service/frontend-service 3000:80 -n default &
kubectl port-forward service/backend-service 8000:8000 -n default &
```

### Example 2: Custom Namespace
```bash
# Create namespace first
kubectl create namespace production

# Deploy to custom namespace
helm install dohelmoto . -n production

# Create ECR secret in custom namespace
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=463470983018.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=production
```

### Example 2.1: Multiple Environments
```bash
# Create namespaces
kubectl create namespace development
kubectl create namespace staging
kubectl create namespace production

# Development environment
helm install dohelmoto-dev . -n development \
  --set frontend.replicaCount=1 \
  --set backend.replicaCount=1

# Staging environment
helm install dohelmoto-staging . -n staging \
  --set frontend.replicaCount=2 \
  --set backend.replicaCount=2

# Production environment
helm install dohelmoto-prod . -n production \
  --set frontend.replicaCount=5 \
  --set backend.replicaCount=5 \
  --set postgresql.persistence.size=100Gi
```

### Example 3: Custom Configuration
```bash
# Create custom values file
cat > custom-values.yaml << EOF
frontend:
  replicaCount: 5
  resources:
    limits:
      memory: 1Gi
      cpu: 500m

backend:
  replicaCount: 5
  resources:
    limits:
      memory: 2Gi
      cpu: 1000m

postgresql:
  persistence:
    size: 50Gi
EOF

# Deploy with custom values
helm install dohelmoto ./dohelmoto -n default -f custom-values.yaml
```

### Example 4: Production Deployment
```bash
# 1. Update secrets with real values
# Edit values.yaml and update secret.data section

# 2. Deploy with production settings
helm install dohelmoto ./dohelmoto -n production --create-namespace \
  --set frontend.replicaCount=5 \
  --set backend.replicaCount=5 \
  --set postgresql.persistence.size=100Gi \
  --set redis.persistence.size=20Gi

# 3. Setup ingress (if ingress controller available)
kubectl apply -f - << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dohelmoto-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: dohelmoto.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8000
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
EOF
```

## Support

For issues and questions:
- GitHub: https://github.com/DohelMoto/DohelMoto
- Email: team@dohelmoto.com
