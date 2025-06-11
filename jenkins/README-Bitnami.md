# Jenkins Deployment with Bitnami Helm Chart

This guide provides instructions for deploying Jenkins to EKS using the Bitnami Helm chart with Kaniko for secure container builds.

## 🚀 Quick Start

```bash
# Make the installation script executable
chmod +x install-jenkins.sh

# Run the installation
./install-jenkins.sh your-cluster-name
```

## 📋 Prerequisites

- **EKS Cluster**: Running Kubernetes cluster
- **kubectl**: Configured to access your cluster
- **Helm 3**: Package manager for Kubernetes
- **AWS CLI**: Configured with appropriate permissions
- **Credentials**: SonarQube token, Slack webhook, GitHub token

### Required AWS Permissions

Your AWS credentials need the following permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "iam:CreateRole",
        "iam:PutRolePolicy",
        "iam:GetRole",
        "sts:GetCallerIdentity",
        "ecr:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## 📦 What Gets Installed

### Jenkins Configuration
- **Image**: Bitnami Jenkins (latest stable)
- **Authentication**: Admin user with custom password
- **Persistence**: 20GB persistent volume
- **Resources**: 2 CPU cores, 4GB RAM
- **Service**: Network Load Balancer for external access

### Pre-installed Plugins
- Kubernetes Plugin (for dynamic agents)
- Pipeline Plugin (for CI/CD workflows)
- Git Plugin (for source code management)
- SonarQube Plugin (for code quality)
- Slack Plugin (for notifications)
- AWS Credentials Plugin (for ECR access)
- NodeJS Plugin (for Node.js builds)

### Kubernetes Resources Created
- **Namespace**: `jenkins`
- **ServiceAccount**: With IRSA for AWS access
- **RBAC**: Cluster role for pod management
- **Secret**: For storing credentials
- **PVC**: 20GB storage for Jenkins data
- **Service**: LoadBalancer for external access

### AWS Resources Created
- **IAM Role**: `JenkinsEKSRole` with ECR permissions
- **IAM Policy**: ECR access policy attached to the role

## 🔧 Configuration Files

### `values.yaml`
Main Helm chart values with:
- Jenkins Configuration as Code (JCasC)
- Kubernetes pod templates for Kaniko
- Tool configurations (NodeJS, SonarQube)
- Plugin installations
- Security settings

### `secrets.yaml`
Template for creating Kubernetes secrets:
- AWS Account ID
- SonarQube token
- Slack webhook URL
- GitHub credentials

### `Jenkinsfile`
Pipeline configuration using:
- Dynamic Kubernetes agents
- Multi-container pods (Kaniko, AWS CLI, Trivy, SonarScanner, NodeJS)
- Parallel execution stages
- ECR integration

## 🛠️ Manual Installation Steps

If you prefer manual installation:

### 1. Setup Prerequisites
```bash
# Add Bitnami Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create namespace
kubectl create namespace jenkins
```

### 2. Create AWS IAM Role
```bash
# Get cluster info
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CLUSTER_NAME="your-cluster-name"
OIDC_ISSUER=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | sed 's|https://||')

# Create trust policy (see install-jenkins.sh for full policy)
aws iam create-role --role-name JenkinsEKSRole --assume-role-policy-document file://trust-policy.json

# Attach ECR policy
aws iam put-role-policy --role-name JenkinsEKSRole --policy-name JenkinsECRPolicy --policy-document file://ecr-policy.json
```

### 3. Create Secrets
```bash
kubectl create secret generic jenkins-secrets \
  --from-literal=aws-account-id="YOUR_AWS_ACCOUNT_ID" \
  --from-literal=sonar-token="YOUR_SONAR_TOKEN" \
  --from-literal=slack-webhook-url="YOUR_SLACK_WEBHOOK" \
  --from-literal=github-username="YOUR_GITHUB_USERNAME" \
  --from-literal=github-token="YOUR_GITHUB_TOKEN" \
  --namespace=jenkins
```

### 4. Install Jenkins
```bash
helm install jenkins bitnami/jenkins \
  --namespace jenkins \
  --values values.yaml \
  --timeout 10m
```

## 🔍 Verification

### Check Installation Status
```bash
# Check all resources
kubectl get all -n jenkins

# Check pod logs
kubectl logs deployment/jenkins -n jenkins

# Check service status
kubectl get svc jenkins -n jenkins
```

### Access Jenkins
```bash
# Get external URL
JENKINS_URL=$(kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Jenkins URL: http://$JENKINS_URL"

# Get admin password
JENKINS_PASSWORD=$(kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-password}" | base64 -d)
echo "Password: $JENKINS_PASSWORD"
```

## 🔧 Post-Installation Configuration

### 1. Create Pipeline Job
1. Go to Jenkins → New Item
2. Select "Pipeline" and name it "nodejs-app-pipeline"
3. In Pipeline section, select "Pipeline script from SCM"
4. Configure your Git repository
5. Set Script Path to `jenkins/Jenkinsfile`

### 2. Verify Kubernetes Cloud
1. Go to Manage Jenkins → Manage Nodes and Clouds → Clouds
2. Verify "kubernetes" cloud is configured
3. Test connection should succeed

### 3. Check Tools Configuration
1. Go to Manage Jenkins → Global Tool Configuration
2. Verify NodeJS 18 is configured
3. Verify SonarQube Scanner is available

## 🚨 Troubleshooting

### Common Issues

**Pod Not Starting**
```bash
kubectl describe pod -l app.kubernetes.io/name=jenkins -n jenkins
kubectl logs -l app.kubernetes.io/name=jenkins -n jenkins
```

**LoadBalancer Not Getting External IP**
```bash
# Check AWS Load Balancer Controller
kubectl get deployment -n kube-system aws-load-balancer-controller

# Check service events
kubectl describe svc jenkins -n jenkins
```

**Authentication Issues**
```bash
# Reset admin password
kubectl exec deployment/jenkins -n jenkins -- jenkins-cli set-password admin newpassword
```

**AWS Access Issues**
```bash
# Check service account annotations
kubectl describe sa jenkins -n jenkins

# Verify IAM role
aws iam get-role --role-name JenkinsEKSRole
aws iam list-attached-role-policies --role-name JenkinsEKSRole
```

### Logs and Debugging
```bash
# Jenkins application logs
kubectl logs deployment/jenkins -n jenkins -f

# System logs
kubectl exec deployment/jenkins -n jenkins -- tail -f /var/log/jenkins/jenkins.log

# Check Jenkins configuration
kubectl exec deployment/jenkins -n jenkins -- cat /opt/bitnami/jenkins/jenkins.yaml
```

## 🔄 Updates and Maintenance

### Update Jenkins
```bash
# Update Helm repository
helm repo update

# Upgrade Jenkins
helm upgrade jenkins bitnami/jenkins \
  --namespace jenkins \
  --values values.yaml
```

### Backup Jenkins
```bash
# Backup Jenkins home
kubectl exec deployment/jenkins -n jenkins -- tar czf /tmp/jenkins-backup.tar.gz /bitnami/jenkins/home

# Copy backup locally
kubectl cp jenkins/deployment-name:/tmp/jenkins-backup.tar.gz ./jenkins-backup.tar.gz
```

### Scale Resources
```bash
# Update values.yaml with new resource limits
# Then upgrade
helm upgrade jenkins bitnami/jenkins \
  --namespace jenkins \
  --values values.yaml
```

## 🗑️ Cleanup

### Uninstall Jenkins
```bash
# Remove Helm release
helm uninstall jenkins -n jenkins

# Delete namespace
kubectl delete namespace jenkins

# Clean up AWS resources
aws iam delete-role-policy --role-name JenkinsEKSRole --policy-name JenkinsECRPolicy
aws iam delete-role --role-name JenkinsEKSRole
```

## 📊 Monitoring

### Metrics Collection
The installation includes metrics endpoints that can be scraped by Prometheus:
- Jenkins metrics: `http://jenkins/prometheus`
- JVM metrics: `http://jenkins/actuator/prometheus`

### Health Checks
- Jenkins health: `http://jenkins/login`
- Readiness: `http://jenkins/whoAmI/api/json`

## 🔐 Security Best Practices

1. **Change Default Password**: Update the admin password immediately
2. **Enable RBAC**: Use Kubernetes RBAC for fine-grained access
3. **Network Policies**: Implement network policies for isolation
4. **Secret Management**: Use AWS Secrets Manager or external secret operators
5. **Image Scanning**: Trivy scans are included in the pipeline
6. **Audit Logging**: Enable Jenkins audit trail plugin

## 📚 Additional Resources

- [Bitnami Jenkins Chart Documentation](https://github.com/bitnami/charts/tree/main/bitnami/jenkins)
- [Jenkins Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin)
- [Kubernetes Plugin Documentation](https://plugins.jenkins.io/kubernetes/)
- [Kaniko Documentation](https://github.com/GoogleContainerTools/kaniko)

---

**Last Updated**: 2024  
**Chart Version**: 12.4.3  
**Jenkins Version**: 2.426.1 