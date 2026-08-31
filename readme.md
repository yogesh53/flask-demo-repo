Flask Application – AWS EKS Deployment
1. Project Overview
This project deploys a containerized Flask application on AWS EKS with PostgreSQL as the backend database.
The infrastructure is managed using Terraform, Kubernetes resources are deployed using Helm, and GitHub Actions is used for CI/CD.
Main technologies:
• AWS EKS
• Amazon RDS PostgreSQL
• Amazon ECR
• AWS Secrets Manager
• External Secrets Operator (ESO)
• Kubernetes
• Helm
• Terraform
• Docker
• GitHub Actions
• AWS IAM OIDC
• CloudWatch
• Application Load Balancer
2. How to Set Up and Run the Infrastructure
Prerequisites
Install and configure AWS CLI, Terraform, kubectl, Helm and Docker. An AWS account with the required permissions is also required.
Verify AWS access:
aws sts get-caller-identity
Step 1: Clone the Repository
git clone <repository-url>
cd <repository-name>
Step 2: Initialize Terraform
cd terraform/environments/flask-app
terraform init
Step 3: Validate the Configuration
terraform validate
Step 4: Review Infrastructure Changes
terraform plan
Step 5: Create the Infrastructure
terraform apply
Terraform provisions the required AWS infrastructure, including VPC and subnets, security groups, EKS cluster and node groups, ECR, RDS PostgreSQL, IAM resources and required EKS add-ons.
Step 6: Configure kubectl
aws eks update-kubeconfig --region <aws-region-code>--name <cluster-name>

kubectl get nodes

Step 7: Install AWS Load Balancer Controller with Helm
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json
aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
    --cluster=<cluster-name> \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region <aws-region-code> \
    --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --version 1.14.0  --set region=<aws-region-code> --set vpcId=vpc-xxxxxxxx

Replace <cluster-name>, <aws-region-code>, vpc-xxxxxxxx, <AWS_ACCOUNT_ID> with actual values

Step 8: Setup the external secret operator for secret management 

Since I have already setup pod identity association for secret to access the secret manager we can now proceed with installing the operator
cd k8s
kubectl apply -f clustersecretstore.yaml
Step 9: Deploy the Application

Im using github actions for ci/cd , in order for deploying the application through ci/cd , we need to add some varibales and secrets in repository settings .
ECR  (uri)
SERVICE complete uri
DB_HOST (endpoint of rds)
the above values can be found for terraform output

AWS_ROLE_ARN (this is the role which I am using to authenticate githubactions with aws )

For we have to create identity provider in aws . I have created through console. 
Go to iam -> Identity providers -> add provider  
Select openid Connect 
Put https://token.actions.githubusercontent.com in provider url 
Put sts.amazonaws.com in Audience .
Now create a github role 
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam:: <AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:org/repo-name:*"
                }
            }
        }
    ]
}
And policies like ecr access policy 
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECRAuthorization",
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Sid": "ECRPushAccess",
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:DescribeRepositories",
                "ecr:DescribeImages"
            ],
            "Resource": "*"
        }
    ]
}

And eks policy 
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:aws:eks:ap-south-1: <aws-region-code>:cluster/<cluster-name>"
        }
    ]
}
I have used these inline policies which are required to put the docker image in ecr and to describe the cluster . 
Also for manual approval ,  since I was using free github account , I need to make the repository public, I created the environment like prod . now go to prod . In Deployment protection rules, Tick the Required reviewers , reviewers who we want to allow to review the pipeline .  After doing this pipeline will stop before prod deployment .

These are the necessary steps to  deployment using ci/cd . just push the code to main branch pipeline will test the code  ,build the docker image  push the image to ecr, scan the image and deploy to uat namespace . after that it requires manual approval for deployment to prod namespace. It will create separate namespace for prod application . 
we can test the application using alb dns of both uat and prod  envs.

Step 10: Monitoring and logging setup :
I have used kube-prometheus stack for monitoring
helm install monitoring prometheus-community/kube-prometheus-stack \ -n monitoring
 For logging I have used amazon-cloudwatch-observability  addon for logging  which is already installed through terraform . 

3. Architecture Decisions
Terraform for Infrastructure
Terraform was selected to manage AWS infrastructure as code. It provides version control, reviewable plans, repeatable deployments and reduces manual configuration.
Amazon EKS for Kubernetes
EKS was selected to run the Flask application because it provides a managed Kubernetes control plane, AWS integration, Kubernetes scaling capabilities and reduced control-plane operational overhead.
Amazon RDS PostgreSQL
RDS PostgreSQL is used as the application database because it is managed by AWS, supports maintenance and backups, and keeps the database separate from application workloads.
Amazon ECR for Container Images
ECR stores Docker images and integrates with EKS and GitHub Actions while providing AWS-native image lifecycle capabilities.
Helm for Application Deployment
Helm packages the application and allows the same chart to be reused across UAT and PROD using environment-specific values files.
GitHub Actions for CI/CD
GitHub Actions automates pull-request testing, image building, ECR publishing and deployment, with manual approval before deployment to production.
AWS OIDC for GitHub Authentication
GitHub Actions assumes an IAM role through OIDC instead of using long-lived AWS access keys. This reduces credential exposure risk.
External Secrets Operator for Secret Management
Secrets are stored in AWS Secrets Manager and synchronized into Kubernetes. This keeps database credentials out of Git and allows separate UAT and PROD secrets.
CloudWatch for Monitoring and Logging
CloudWatch provides centralized AWS monitoring and logging and helps with infrastructure and application troubleshooting.
3. Architecture
The overall flow is:
GitHub → GitHub Actions → AWS OIDC → IAM Role → ECR / EKS
Application request flow:
User → AWS Load Balancer → Kubernetes Service → Flask Pods → PostgreSQL RDS
Secret flow:
AWS Secrets Manager → External Secrets Operator → ExternalSecret → Kubernetes Secret → Flask Pod
4. Security Considerations
IAM:
• GitHub Actions uses OIDC instead of long-lived AWS access keys.
• IAM roles are used for AWS access.
• EKS access is controlled through IAM/EKS access mechanisms.
Secrets:
• Database credentials are stored in AWS Secrets Manager.
• External Secrets Operator synchronizes secrets into Kubernetes.
• Secrets are not committed to Git.
Kubernetes:
• Applications are deployed into dedicated namespaces.
• UAT and PROD use separate configuration values.
• Containers run as a non-root user.
Network:
• EKS worker nodes are deployed in private subnets.
• RDS is kept private.
• Security groups control communication between resources.
5. Cost Optimization
Cost optimization measures include:
Right-sized compute resources: EKS node resources were selected based on the application's workload rather than using larger instances unnecessarily.
Environment-specific resources: UAT and PROD use separate Helm values, allowing resource configurations to be adjusted according to the requirements of each environment.
UAT cost optimization: Since UAT is a non-production environment, resources can be kept smaller than production resources where workload requirements allow it.
Containerized application deployment: The Flask application runs on EKS, allowing Kubernetes resource requests/limits and scaling to be used instead of provisioning dedicated servers for the application.
ECR for container images: Amazon ECR is used as the container registry and integrates directly with the AWS deployment environment.
Resource monitoring: CloudWatch monitoring is configured to observe resource utilization, which helps identify over-provisioned resources and opportunities for future right-sizing.