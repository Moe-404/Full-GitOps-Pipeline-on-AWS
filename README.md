# Full GitOps Pipeline on AWS with Terraform and Secrets Management

## 🧭 Project Overview

This project implements a full GitOps CI/CD pipeline on AWS using Terraform and Kubernetes. It provisions cloud infrastructure using Infrastructure as Code (IaC), and automates application delivery using Jenkins for Continuous Integration and ArgoCD for Continuous Deployment.

Key highlights include:
- A highly available Amazon EKS cluster provisioned using Terraform
- Jenkins pipeline for secure image builds, security scanning, and GitOps-ready deployments
- ArgoCD and Argo Image Updater to enable automated deployments from GitHub
- Secure secret management with External Secrets Operator and AWS Secrets Manager
- A complete example application stack featuring a Node.js web app, MySQL, and Redis

---

## 📦 Project Scope

### ✅ 1. Infrastructure Provisioning – Terraform

Provision the entire cloud infrastructure using **Terraform modules**, including:

- **VPC**  
  - 3 public and 3 private subnets across 3 Availability Zones  
  - NAT Gateway and Internet Gateway  
  - Route tables and associations

- **Amazon EKS Cluster**
  - Control plane
  - Managed node groups in **private subnets**
  - EKS OIDC provider setup
  - IRSA integration for fine-grained IAM access

- **IAM Roles**
  - Cluster and node IAM roles
  - EFS CSI driver IAM role (IRSA)

- **IRSA and EFS CSI Driver**
  - `efs-csi-driver` service account with IAM role annotation
  - Helm-based deployment with IRSA

---

### ⚙️ 2. CI Tool – Jenkins

- Jenkins deployed via **Helm** on EKS
- Jenkins pipelines configured to:
  - Clone NodeJS application repository  
    [`https://github.com/moe-404/jenkins_nodejs_example.git`](https://github.com/moe-404/jenkins_nodejs_example.git)
  - Build Docker images using Dockerfiles
  - Push images to **Amazon ECR**
  - Run **Terraform** to update infrastructure

---

### 🚀 3. CD Tool – ArgoCD + Argo Image Updater

- **ArgoCD installed via Helm** in a dedicated namespace
- GitOps pipeline configured:
  - Sync Kubernetes manifests from GitHub repo
  - Auto-deploy changes on Git push

- **Argo Image Updater** configured to:
  - Track new image tags in **Amazon ECR**
  - Update image tags in GitHub manifests automatically
  - Trigger ArgoCD sync for continuous deployment

---

### 🔐 4. Secrets Management – External Secrets Operator

- **External Secrets Operator** deployed via Helm
- Integrated with **AWS Secrets Manager**
- Automatically syncs secrets into Kubernetes, including:
  - MySQL credentials
  - Redis password

---

### 🐍 5. Application: NodeJS App with MySQL and Redis

- NodeJS web application deployed on EKS  
  [`https://github.com/moe-404/jenkins_nodejs_example.git`](https://github.com/moe-404/jenkins_nodejs_example.git)

- Application dependencies:
  - **MySQL pod**: stores persistent data
  - **Redis pod**: used for caching
  - Application retrieves credentials from **Kubernetes Secrets**

- Deployments managed using **Helm**

---

## 🛠️ Technologies Used

- **Terraform** (Modularized)
- **Amazon EKS** (Elastic Kubernetes Service)
- **Helm** (Package Manager for Kubernetes)
- **Jenkins** (CI Pipelines)
- **ArgoCD + Argo Image Updater** (CD and GitOps)
- **AWS ECR** (Elastic Container Registry)
- **AWS Secrets Manager** + **External Secrets Operator**
- **NodeJS**, **MySQL**, **Redis**

---

## 🔧 Jenkins Pipeline Overview

The Jenkins pipeline automates the build and delivery process:
- **Clone Repository**: Clones the Node.js app from GitHub and logs commit info.
- **Install Dependencies & Code Quality**: Runs npm install and tests; executes SonarQube static analysis.
- **Build & Push Docker Image**: Uses Kaniko to build the Docker image and push it to Amazon ECR.
- **Security Scan**: Runs Trivy to scan the built image for vulnerabilities.
- **Verify Deployment**: Confirms images are present in the ECR repository.
- **Notifications**: Sends Slack messages on success or failure with pipeline details.
