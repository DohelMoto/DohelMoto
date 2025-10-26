# DohelMoto Kubernetes Configuration

This directory contains the complete Kubernetes configuration for the DohelMoto e-commerce application.

## Architecture

The application consists of the following components:

- **Frontend**: React application served by Nginx
- **Backend**: Node.js/Express API server
- **Database**: PostgreSQL with persistent storage
- **Cache**: Redis with persistent storage
- **Ingress**: Nginx Ingress Controller for external access

## Prerequisites

1. **Kubernetes Cluster**: A running Kubernetes cluster (EKS, GKE, AKS, or local)
2. **kubectl**: Kubernetes command-line tool
3. **AWS CLI**: For ECR authentication
4. **Docker**: For building and pushing images to ECR

## ECR Images

The application uses the following ECR images:
- `463470983018.dkr.ecr.us-east-1.amazonaws.com/dohelmoto-frontend:latest`
- `463470983018.dkr.ecr.us-east-1.amazonaws.com/dohelmoto-backend:latest`

## Quick Start

### 1. Configure AWS Credentials

```bash
aws configure
```

### 2. Deploy the Application

```bash
./deploy.sh
```

This script will:
- Create the namespace
- Set up ECR authentication
- Deploy all components
- Wait for deployments to be ready
- Show service information

### 3. Access the Application

After deployment, you can access the application through:
- **LoadBalancer IP**: Check the external IP of the ingress service
- **Port Forwarding**: `kubectl port-forward service/frontend-service 3000:80 -n ecommerce`

## Manual Deployment

If you prefer to deploy manually:

```bash
# Create namespace
kubectl apply -f namespace.yaml

# Create ECR secret (replace with your AWS credentials)
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=463470983018.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=ecommerce

# Apply configurations in order
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml
```

## Configuration Files

### Core Components

- **namespace.yaml**: Defines the `ecommerce` namespace
- **configmap.yaml**: Non-sensitive configuration data
- **secret.yaml**: Sensitive data (passwords, API keys)
- **ecr-secret.yaml**: ECR authentication secret

### Application Components

- **postgres.yaml**: PostgreSQL database with persistent storage
- **redis.yaml**: Redis cache with persistent storage
- **backend.yaml**: Backend API service with ECR image
- **frontend.yaml**: Frontend application with ECR image
- **ingress.yaml**: External access configuration

## Environment Variables

### Backend Environment Variables

The backend service uses the following environment variables:

**From ConfigMap:**
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `ALLOWED_ORIGINS`: CORS allowed origins
- `AWS_REGION`: AWS region
- `ALGORITHM`: JWT algorithm
- `ACCESS_TOKEN_EXPIRE_MINUTES`: JWT expiration time
- `NODE_ENV`: Node environment
- `LOG_LEVEL`: Logging level

**From Secrets:**
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

The application includes Horizontal Pod Autoscalers (HPA) for both frontend and backend:

- **Backend**: 3-10 replicas based on CPU (70%) and memory (80%) usage
- **Frontend**: 3-10 replicas based on CPU (70%) and memory (80%) usage

To manually scale:

```bash
# Scale backend
kubectl scale deployment backend --replicas=5 -n ecommerce

# Scale frontend
kubectl scale deployment frontend --replicas=5 -n ecommerce
```

## Monitoring

### View Logs

```bash
# Backend logs
kubectl logs -f deployment/backend -n ecommerce

# Frontend logs
kubectl logs -f deployment/frontend -n ecommerce

# PostgreSQL logs
kubectl logs -f deployment/postgres -n ecommerce

# Redis logs
kubectl logs -f deployment/redis -n ecommerce
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
```

## Troubleshooting

### Common Issues

1. **Image Pull Errors**: Ensure ECR credentials are correct and images exist
2. **Database Connection Issues**: Check if PostgreSQL is running and accessible
3. **Redis Connection Issues**: Check if Redis is running and accessible
4. **Ingress Issues**: Ensure ingress controller is installed and running

### Debug Commands

```bash
# Describe pod for detailed information
kubectl describe pod <pod-name> -n ecommerce

# Check events
kubectl get events -n ecommerce --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n ecommerce
kubectl top nodes
```

## Cleanup

To remove all resources:

```bash
./cleanup.sh
```

Or manually:

```bash
kubectl delete namespace ecommerce
```

## Security Notes

1. **Secrets**: Update the secret values in `secret.yaml` with your actual credentials
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
