# Jenkins CI/CD Pipeline

This Jenkins pipeline implements a complete CI/CD workflow for the NodeJS application with security scanning, code quality analysis, and automated deployments to AWS ECR.

## 🚀 Pipeline Overview

The pipeline performs the following stages:

1. **Clone Repository** - Clones the NodeJS application from GitHub
2. **Code Quality Analysis** - Runs SonarQube analysis for code quality
3. **Build Docker Image** - Creates a containerized version of the application
4. **Security Scan** - Uses Trivy to scan for vulnerabilities
5. **Push to ECR** - Pushes the Docker image to AWS ECR
6. **Cleanup** - Removes local Docker images

## 📋 Prerequisites

### Jenkins Plugins Required
- Pipeline
- Git
- Docker Pipeline
- AWS Credentials
- NodeJS Plugin
- SonarQube Scanner
- Slack Notification

### Jenkins Tools Configuration
- NodeJS 18 (named: `nodejs-18`)
- SonarQube Scanner

### Jenkins Credentials Required

| Credential ID | Type | Description |
|--------------|------|-------------|
| `aws-account-id` | Secret text | AWS Account ID (12 digits) |
| `sonarqube-url` | Secret text | SonarQube server URL |
| `sonar-token` | Secret text | SonarQube authentication token |
| `slack-webhook-url` | Secret text | Slack webhook URL for notifications |
| `github-credentials` | Username/Password | GitHub credentials for repo access |

## 🔧 Setup Instructions

### 1. Install Required Jenkins Plugins

```bash
# Using Jenkins CLI
jenkins-cli install-plugin \
    pipeline-stage-view \
    git \
    docker-workflow \
    nodejs \
    sonar \
    slack \
    aws-credentials
```

### 2. Configure Jenkins Tools

Go to **Manage Jenkins** → **Global Tool Configuration**:

#### NodeJS
- Name: `nodejs-18`
- Version: `18.17.0` or latest
- Global npm packages: `npm@latest`

#### SonarQube Scanner
- Name: `SonarQubeScanner`
- Install automatically from Maven Central

### 3. Configure SonarQube Server

Go to **Manage Jenkins** → **Configure System** → **SonarQube servers**:
- Name: `SonarQube`
- Server URL: `http://your-sonarqube-server:9000`
- Authentication token: Reference the `sonar-token` credential

### 4. Set Up AWS Credentials

Ensure your Jenkins instance has AWS CLI installed and configured:

```bash
# Install AWS CLI on Jenkins
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials (if using EC2 instance role, skip this)
aws configure
```

### 5. Configure Slack Integration

1. Create a Slack App and get webhook URL:
   - Go to https://api.slack.com/apps
   - Create new app → Incoming Webhooks
   - Add webhook to workspace
   - Copy webhook URL

2. Add webhook URL to Jenkins credentials

## 🏃 Running the Pipeline

### Manual Trigger
1. Go to the job in Jenkins
2. Click "Build Now"
3. Monitor progress in "Console Output"

### Automatic Triggers
Configure in job settings:
- **Poll SCM**: `H/5 * * * *` (every 5 minutes)
- **Webhook**: Configure GitHub webhook for push events

## 📊 Pipeline Stages Explained

### Clone Repository
- Clones the NodeJS application from the configured GitHub repository
- Sends Slack notification when build starts
- Displays commit information

### Code Quality Analysis
- Installs npm dependencies
- Runs SonarQube scanner
- Checks quality gates
- Reports to Slack if quality gate fails

### Build Docker Image
- Creates Dockerfile if not present
- Builds optimized Docker image
- Tags with build number and latest

### Security Scan
- Runs Trivy vulnerability scanner
- Scans for HIGH and CRITICAL vulnerabilities
- Generates JSON report
- Sends Slack alert if vulnerabilities found

### Push to ECR
- Logs into AWS ECR
- Creates repository if it doesn't exist
- Pushes tagged images
- Notifies Slack on success

## 🔍 Monitoring & Troubleshooting

### View Build Logs
```bash
# From Jenkins UI
Job → Build History → Console Output

# From CLI
jenkins-cli console JOB_NAME BUILD_NUMBER
```

### Common Issues

**AWS Authentication Failed**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify ECR login
aws ecr get-login-password --region us-east-1
```

**Docker Build Failed**
```bash
# Check Docker daemon
systemctl status docker

# Verify Dockerfile syntax
docker build -t test .
```

**SonarQube Connection Failed**
```bash
# Test SonarQube connection
curl -u admin:token http://sonarqube-server:9000/api/system/status
```

## 📈 Metrics & Reports

### Available Reports
- **SonarQube Dashboard**: Code quality metrics
- **Trivy Security Report**: `trivy-report.json` in build artifacts
- **Build Trends**: Jenkins build history graph
- **Slack Notifications**: Real-time build status

### Accessing Reports
1. **SonarQube**: http://your-sonarqube-server:9000/projects
2. **Build Artifacts**: Job → Build → Artifacts
3. **Slack Channel**: #devops-notifications

## 🔒 Security Best Practices

1. **Credentials Management**
   - Use Jenkins credentials store
   - Rotate tokens regularly
   - Never hardcode secrets

2. **Image Scanning**
   - Review Trivy reports
   - Fix critical vulnerabilities
   - Update base images regularly

3. **Access Control**
   - Limit Jenkins job permissions
   - Use IAM roles for AWS access
   - Implement branch protection

## 📝 Customization

### Modify Trivy Severity Levels
```groovy
environment {
    TRIVY_SEVERITY = 'CRITICAL,HIGH,MEDIUM'  // Add MEDIUM
    TRIVY_EXIT_CODE = '1'  // Fail build on vulnerabilities
}
```

### Add Additional Stages
```groovy
stage('Integration Tests') {
    steps {
        sh 'npm run test:integration'
    }
}
```

### Custom Slack Messages
```groovy
slackSend(
    channel: '#custom-channel',
    color: 'good',
    message: "Custom notification",
    attachments: [[
        title: 'Build Details',
        fields: [[
            title: 'Version',
            value: "${IMAGE_TAG}"
        ]]
    ]]
)
```

## 🆘 Support

For issues or questions:
- Check Jenkins logs: `/var/log/jenkins/jenkins.log`
- Review pipeline syntax: Pipeline Syntax Generator in Jenkins
- Contact: DevOps team

---

**Last Updated**: 2024
**Pipeline Version**: 1.0.0 