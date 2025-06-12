#!/bin/bash

# Minimal Jenkins Installation Script
# Quick deployment with basic configuration

set -e

NAMESPACE="jenkins"
RELEASE_NAME="jenkins"
CLUSTER_NAME=${1:-"grad-proj-cluster"}
AWS_REGION=${AWS_DEFAULT_REGION:-"us-east-1"}

echo "🚀 Installing Jenkins (Minimal Setup)"
echo "===================================="

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $AWS_ACCOUNT_ID"

# Update values file with AWS Account ID
sed -i "s/YOUR_AWS_ACCOUNT_ID/$AWS_ACCOUNT_ID/g" /root/jenkinsInstall/values-minimal.yaml


# Create namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Create IAM role (basic ECR permissions)
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$AWS_ACCOUNT_ID:oidc-provider/$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | sed 's|https://||')"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | sed 's|https://||'):sub": "system:serviceaccount:$NAMESPACE:$RELEASE_NAME"
        }
      }
    }
  ]
}
EOF

aws iam create-role \
    --role-name JenkinsEKSRole \
    --assume-role-policy-document file://trust-policy.json 2>/dev/null || echo "Role exists"

aws iam attach-role-policy \
    --role-name JenkinsEKSRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser 2>/dev/null || echo "Policy attached"

# Add Helm repo and install
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install $RELEASE_NAME bitnami/jenkins \
    --namespace $NAMESPACE \
    --values /root/jenkinsInstall/values.yaml \
    --wait

# Get access info
JENKINS_URL=$(kubectl get svc $RELEASE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
JENKINS_PASSWORD=$(kubectl get secret $RELEASE_NAME -n $NAMESPACE -o jsonpath="{.data.jenkins-password}" | base64 -d)

# Cleanup
rm -f trust-policy.json

echo ""
echo "✅ Jenkins installed!"
echo "URL: http://$JENKINS_URL"
echo "Username: admin"  
echo "Password: $JENKINS_PASSWORD"
echo ""
echo "Next: Create a pipeline job using your Jenkinsfile" 