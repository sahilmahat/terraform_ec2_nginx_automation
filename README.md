# Terraform + AWS EC2 + Nginx

A small Infrastructure as Code project that provisions an AWS EC2
instance with Terraform and configures Nginx automatically using a Bash
user-data script.

I built this project to practise how Terraform resources fit together
and how a server can be provisioned with a repeatable configuration
instead of setting everything up manually.

## What it creates

-   An AWS key pair using an existing SSH public key
-   A security group allowing SSH from one configured public IP and HTTP
    from the internet
-   An EC2 instance with a `gp3` root EBS volume
-   An Nginx web server installed through EC2 user data
-   Terraform outputs for the instance's public IP, public DNS, private
    IP, and website URL

## Architecture

``` text
Your computer
   |
   | Terraform
   v
AWS (ap-south-1)
   |
   +-- Default VPC
   |
   +-- Security Group
   |     +-- TCP 22: your configured public IP only
   |     +-- TCP 80: public HTTP
   |
   +-- EC2 (t3.micro by default)
         |
         +-- User data installs and starts Nginx
               |
               +-- Custom HTML page
```

## Prerequisites

-   An AWS account with permission to create EC2 instances, key pairs,
    security groups, and related resources
-   Terraform CLI installed
-   AWS credentials configured locally, preferably through the AWS CLI
    or environment variables
-   An Ubuntu AMI ID valid in your selected AWS region
-   A public SSH key file

Do not put AWS access keys, private SSH keys, or Terraform state files
in this repository.

## 1. Clone the repository

``` bash
git clone https://github.com/YOUR_GITHUB_USERNAME/terraform-aws-ec2-nginx.git
cd terraform-aws-ec2-nginx
```

Replace `YOUR_GITHUB_USERNAME` with your GitHub username after creating
the repository.

## 2. Configure AWS credentials

If you use the AWS CLI, configure a profile:

``` bash
aws configure
aws sts get-caller-identity
```

Use an IAM identity with only the permissions required for this project.
Avoid using root-account access keys.

## 3. Create an SSH key pair

If you already have a suitable public key, you can use it. Otherwise,
create a dedicated key:

``` bash
ssh-keygen -t ed25519 -f terra-ec2-key
```

This creates a private key (`terra-ec2-key`) and a public key
(`terra-ec2-key.pub`). The Terraform configuration uploads only the
public key to AWS. Keep the private key out of Git.

If you use a different public-key filename, update `public_key_path` in
your `terraform.tfvars`.

## 4. Set your variables

Copy the example file:

``` bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and replace `YOUR_PUBLIC_IP/32` with your
current public IPv4 address in CIDR notation, for example
`203.0.113.10/32` (example only).

Check that the AMI ID matches the AWS region you selected. AMI IDs are
region-specific and can change over time.

## 5. Initialise, validate, and review

``` bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan before applying it. Terraform state can contain
sensitive information, so keep it local or configure a secure remote
backend before collaborating.

## 6. Create the infrastructure

``` bash
terraform apply
```

Review the proposed changes and type `yes` when prompted.

After it completes, print the outputs:

``` bash
terraform output
```

Open the `website_url` output in a browser. It should display the Nginx
page once cloud-init has finished installing and configuring Nginx.
Initial setup may take a few minutes.

## 7. Connect over SSH

Use the private key that matches the public key you registered:

``` bash
chmod 400 terra-ec2-key
ssh -i terra-ec2-key ubuntu@$(terraform output -raw ec2_public_ip)
```

The `ubuntu` username is appropriate for many Ubuntu AMIs; another AMI
may use a different default username.

If SSH does not connect, check that your current public IP still matches
`ssh_allowed_cidr`, the instance has a public IP, and its subnet has a
route to an internet gateway.

## 8. Clean up

When you no longer need the demo resources, destroy them to avoid
ongoing AWS charges:

``` bash
terraform destroy
```

Review the plan and confirm before proceeding. This removes resources
managed by this Terraform configuration; it does not delete unrelated
resources in your AWS account.

## Security notes

-   SSH is restricted to the configured public IPv4 CIDR. Update it if
    your ISP changes your public IP.
-   HTTP is open to the internet for demonstration purposes. Do not
    expose application or administrative ports publicly without a clear
    need.
-   This demo uses the AWS default VPC to keep the setup small. A
    production design should explicitly manage networking, IAM roles,
    logging, patching, and monitoring.
-   Use a remote Terraform backend with encryption and access controls
    for team workflows.
-   Never commit `terraform.tfvars`, private keys, AWS credentials, or
    state files.

## Project structure

``` text
terraform-aws-ec2-nginx/
├── main.tf
├── key_pair.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── install.sh
├── terraform.tfvars.example
├── .gitignore
└── README.md
```

## What I learned

-   Defining and connecting AWS resources with Terraform
-   Managing inbound and outbound security group rules
-   Passing a public SSH key to EC2
-   Using EC2 user data for first-boot configuration
-   Installing and enabling Nginx automatically
-   Using Terraform outputs to retrieve connection details

## Possible next steps

-   Move Terraform state to a secured S3 backend with locking
    appropriate to the chosen Terraform/AWS setup
-   Use an explicit VPC and subnet instead of the default VPC
-   Add HTTPS with a domain and certificate
-   Add monitoring and logging
-   Run formatting, validation, and plan checks in a GitHub Actions
    workflow

------------------------------------------------------------------------

Built as a hands-on learning project for AWS, Terraform, Linux, and
DevOps.
