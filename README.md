# 🚀 DohelMoto Platform – Application, GitOps & Infrastructure Repositories

DohelMoto is built across three repositories:

- **Application Repository** – frontend, backend, Docker, Helm, Kubernetes  
- **Infrastructure Repository** – AWS (VPC, EKS, ECR, IAM…)  
- **GitOps Repository** – ArgoCD deployments and environment configs  

---

## 🍀 Application Repository

This repository contains the entire application layer of the DohelMoto system:

- React + NGINX frontend  
- FastAPI / Flask backend  
- PostgreSQL + Redis (via Docker Compose)  
- Local monitoring stack  
- Helm chart for Kubernetes  
- Raw Kubernetes manifests  

### 📁 Repository Structure
```text
DohelMoto/
├── backend/
├── frontend/
├── database/
├── helm/
├── k8s/
├── docker-compose.yml
└── README.md
```
### 🐳 Docker & Local Development

Run locally:

    docker compose up --build

This launches: Frontend, Backend, PostgreSQL, Redis, Prometheus, Grafana.

### ☸️ Kubernetes (k8s/)

Contains raw deployment-ready YAMLs:

- Deployments  
- Services  
- Ingress  
- ConfigMaps  
- Secrets  

### 📦 Helm Chart (helm/)

Includes templates for deployments, services, ingress, configs, probes, resource limits, and image tags.  
Helm enables reproducible, environment-specific deployments and integrates with the GitOps repo.

---

## 🏗️ GitOps Repository

This repository contains the **GitOps layer** of the DohelMoto platform.  
It defines how the application is deployed across **dev, staging, and production** using **ArgoCD**.

### 📁 Repository Structure
```text
DohelMoto-GitOps/
├── argocd/
│   ├── project-dohelmoto.yaml
│   └── applicationset-dohelmoto.yaml
└── env/
    ├── dev/values.yaml
    ├── staging/values.yaml
    └── prod/values.yaml
```
### Contents

- ArgoCD Project – repos, namespaces, permissions  
- ArgoCD ApplicationSet – auto-generates apps per environment  
- Environment values (Helm overrides) – dev, staging, prod  

ArgoCD watches this repo and syncs changes directly into **EKS**.

---

## 🧩 Infrastructure Repository (Terraform)

This repository contains the **Infrastructure as Code (IaC)** for the DohelMoto platform, built with **Terraform** and deployed on **AWS**.  
It provisions all cloud resources required for the application.

### 📁 Repository Structure


Each environment (dev, staging, prod) loads the same modules with different configurations for isolation.

### 🏗️ What Terraform Builds

- **Network Module** – VPC, subnets, route tables, gateways  
- **EKS Module** – managed cluster, node groups, IAM roles, OIDC provider  
- **EKS Addons** – VPC CNI, CoreDNS, Kube-Proxy  
- **ECR Module** – Docker registries, lifecycle policies  
- **S3 Module** – buckets for logs, storage, infra needs  
- **Monitoring Module** – CloudWatch log groups, monitoring setup  

### 🔁 Deployment Workflow

1. **Infrastructure Deployment (Terraform)**  
   - `terraform init`  
   - `terraform plan`  
   - `terraform apply`  

2. **Application CI (Application Repo)**  
   - GitHub Actions builds images  
   - Pushes to ECR created by Terraform  

3. **CD (GitOps Repo + ArgoCD)**  
   - ArgoCD applies Helm charts into EKS clusters  

➡️ Complete **Infra → CI → CD pipeline**.

### 🔐 Remote State

- **S3 bucket** – stores Terraform state  
- **DynamoDB table** – prevents concurrent state changes  

Ensures reliable, production-safe infrastructure changes.

---

## 📜 Summary

Together, these repositories provide:

- Full application layer (frontend, backend, monitoring, Docker, Kubernetes, Helm)  
- Automated deployments through **ArgoCD**  
- Fully modular AWS infrastructure with multi-environment support  
- CI/CD integration with ECR, EKS, and Terraform  
- Git-driven cluster state and environment-specific configuration  

They serve as the **foundation, delivery, and infrastructure layers** of the DohelMoto platform.