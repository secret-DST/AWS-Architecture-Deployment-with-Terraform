# AWS Infrastructure with Terraform

## Overview

This project provisions a complete AWS network environment using **Terraform Infrastructure as Code (IaC)**.

The goal of this project is to demonstrate practical **DevOps / DevSecOps infrastructure skills**, including:

* Infrastructure as Code with Terraform
* AWS VPC networking
* Public and private subnets
* Internet Gateway and NAT Gateway
* Public and private route tables
* EC2 provisioning
* Network security with Security Groups
* Remote Terraform state stored in Amazon S3
* Terraform state locking
* Terraform variables and outputs
* Resource dependencies and references

The infrastructure is split across multiple Terraform files to keep the configuration organised and maintainable.

## Architecture

The environment contains:

```
                           Internet
                              |
                              |
                       Internet Gateway
                              |
                    +---------+---------+
                    |                   |
              Public Subnet         Private Subnet
              eu-west-2a             eu-west-2b
                    |                   |
              Public EC2           Private EC2
                    |                   |
                    +---- NAT Gateway -+
                           |
                      Elastic IP
```

### Network design

| Component               | Configuration    |
| ----------------------- | ---------------- |
| Region                  | `eu-west-2`      |
| VPC CIDR                | `10.0.0.0/16`    |
| Public subnet           | `10.0.1.0/24`    |
| Private subnet          | `10.0.2.0/24`    |
| Public AZ               | `eu-west-2a`     |
| Private AZ              | `eu-west-2b`     |
| Public EC2              | `t3.micro`       |
| Private EC2             | `t3.micro`       |
| Public access           | Internet Gateway |
| Private outbound access | NAT Gateway      |

---

## Infrastructure Components

### VPC

A custom VPC is created with DNS support and DNS hostnames enabled.

```text
10.0.0.0/16
```

### Public Subnet

The public subnet is configured with:

```text
10.0.1.0/24
```

- Instances launched in this subnet can receive public IPv4 addresses.
- Traffic to the internet is routed through the Internet Gateway.

### Private Subnet

The private subnet uses:

```text
10.0.2.0/24
```
- Instances in this subnet do not receive public IP addresses.
- Outbound internet traffic is routed through the NAT Gateway.

### Internet Gateway

- The Internet Gateway provides internet connectivity for resources in the public subnet.

### NAT Gateway

- The NAT Gateway allows resources in the private subnet to initiate outbound internet connections without exposing them directly to the public internet.
- The NAT Gateway uses an Elastic IP address.

### Route Tables

Two route tables are configured:

**Public route table**

```text
0.0.0.0/0 → Internet Gateway
```

**Private route table**

```text
0.0.0.0/0 → NAT Gateway
```

---

## EC2 Instances

Two EC2 instances are provisioned.

### Public EC2

The public EC2 instance is deployed into the public subnet and receives a public IP address.

It is associated with a security group allowing:

* SSH — port 22
* HTTP — port 80
* Outbound traffic

### Private EC2

The private EC2 instance is deployed into the private subnet and does not receive a public IP address.

SSH access is restricted to the public EC2 security group rather than allowing SSH from the entire internet.

This demonstrates basic **network segmentation** between public and private workloads.

---

## Security

Security considerations were included in the design.

### Network segmentation

- The architecture separates workloads into public and private subnets.
- The private EC2 instance cannot be directly accessed from the public internet.

### Security Groups

- The public EC2 security group allows HTTP and SSH traffic.
- The private EC2 security group allows SSH traffic only from the public EC2 security group.
= This demonstrates **security-group-to-security-group access control** rather than exposing the private instance directly.

### DevSecOps consideration

For a production environment, SSH should not be exposed to:

```text
0.0.0.0/0
```

Instead, access should be restricted to a trusted IP range or replaced with a service such as **AWS Systems Manager Session Manager**.

---

## Terraform State

Terraform state is stored remotely in an Amazon S3 bucket.

The backend is configured with:

```hcl
backend "s3" {
  bucket       = "<your-s3-state-bucket>"
  key          = "path/to/terraform.tfstate"
  region       = "eu-west-2"
  encrypt      = true
  use_lockfile = true
}
```

Remote state provides centralised state storage and allows Terraform state to be managed independently from the local development machine.

The S3 backend also uses:

* Server-side encryption
* State locking using an S3 lockfile

> The actual S3 bucket name is intentionally not included in this repository.

---

## Project Structure

The Terraform configuration is split into multiple files:

```text
.
├── provider.tf
├── variables.tf
├── network.tf
├── outputs.tf
├── .gitignore
└── README.md
```

### `provider.tf`

Contains:

* Terraform version requirements
* AWS provider configuration
* S3 backend configuration

### `variables.tf`

Contains configurable infrastructure variables such as:

* VPC CIDR
* Public subnet CIDR
* Private subnet CIDR
* AMI ID
* EC2 instance type

### `network.tf`

Contains the main infrastructure:

* VPC
* Subnets
* Internet Gateway
* NAT Gateway
* Elastic IP
* Route tables
* Route table associations
* EC2 instances
* Security groups

### `outputs.tf`

Provides useful infrastructure information after deployment, including:

* VPC ID
* Public subnet ID
* Private subnet ID
* NAT Gateway ID
* Public EC2 IP

---

## Prerequisites

Before deploying the infrastructure, install:

* Terraform 1.15.x
* AWS CLI
* An AWS account
* AWS credentials configured locally

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI authentication:

```bash
aws sts get-caller-identity
```

---

## Deployment

### 1. Clone the repository

```bash
git clone <repository-url>
cd <repository-name>
```

### 2. Configure the S3 backend

Create an S3 bucket for Terraform state and update:

```hcl
bucket = "<your-s3-state-bucket>"
```

Do not commit credentials or sensitive information to the repository.

### 3. Initialise Terraform

```bash
terraform init
```

### 4. Format the configuration

```bash
terraform fmt -recursive
```

### 5. Validate the configuration

```bash
terraform validate
```

### 6. Review the execution plan

```bash
terraform plan
```

Review the resources Terraform intends to create before applying.

### 7. Deploy

```bash
terraform apply
```

Review the plan and confirm the deployment.

### 8. View outputs

```bash
terraform output
```

To retrieve the public EC2 IP:

```bash
terraform output ec2_public_ip
```

---

## Destroying the Infrastructure

When finished with the lab:

```bash
terraform destroy
```

This removes the infrastructure managed by Terraform.

Destroying the environment when it is no longer required also helps avoid unnecessary AWS charges.

---

## Terraform Workflow

This project follows a basic Infrastructure as Code workflow:

```text
Write Terraform
       |
       v
terraform fmt
       |
       v
terraform validate
       |
       v
terraform plan
       |
       v
Review changes
       |
       v
terraform apply
       |
       v
AWS Infrastructure
```

---

## DevOps / DevSecOps Skills Demonstrated

This project demonstrates practical experience with:

### Infrastructure as Code

Terraform is used to define AWS infrastructure declaratively rather than creating resources manually.

### Cloud Networking

The project demonstrates understanding of:

* VPCs
* CIDR ranges
* Subnets
* Availability Zones
* Route tables
* Internet Gateways
* NAT Gateways
* Elastic IPs

### Security

The architecture demonstrates:

* Public/private network segmentation
* Security groups
* Restricted communication between workloads
* No public IP on the private EC2 instance
* Encrypted remote Terraform state

### Infrastructure Management

The project uses:

* Variables
* Outputs
* Resource references
* Resource dependencies
* Remote state
* State locking

---

## Future Improvements

Planned improvements include:

* [ ] Replace `0.0.0.0/0` SSH access with restricted administrator IP ranges
* [ ] Implement AWS Systems Manager Session Manager instead of SSH
* [ ] Add multiple availability zones for improved resilience
* [ ] Add a dedicated NAT Gateway per AZ
* [ ] Add IAM roles with least-privilege permissions
* [ ] Add VPC Flow Logs
* [ ] Add CloudWatch monitoring
* [ ] Add HTTPS using an Application Load Balancer
* [ ] Add Terraform modules
* [ ] Add environment separation such as `dev`, `staging`, and `prod`
* [ ] Add CI/CD using GitHub Actions
* [ ] Add Terraform security scanning
* [ ] Add Terraform linting
* [ ] Add automated `terraform plan` checks on pull requests
* [ ] Add secret scanning
* [ ] Add policy-as-code checks

---

## DevSecOps Roadmap

The next stage of this project would be integrating security into the Terraform workflow.

A potential CI/CD pipeline:

```text
Git Push
   |
   v
GitHub Actions
   |
   +---- Terraform Format
   |
   +---- Terraform Validate
   |
   +---- Terraform Lint
   |
   +---- Security Scan
   |
   +---- Terraform Plan
   |
   v
Manual Approval
   |
   v
Terraform Apply
```

Potential tools for the security stage include:

* Checkov
* Trivy
* tfsec
* TFLint
* GitHub secret scanning

This would extend the project from basic Terraform provisioning into a more complete **DevSecOps workflow**.

---

## Disclaimer

This project is intended as a learning and portfolio project.

The configuration should be reviewed and hardened before being used in a production environment.

AWS resources can incur costs. Destroy the infrastructure when it is no longer required.

