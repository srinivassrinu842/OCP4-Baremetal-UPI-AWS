# OpenShift 4 AWS BareMetal UPI Infrastructure (Terraform) - Base Infra

This Terraform configuration provisions the base AWS infrastructure for an OpenShift 4 BareMetal UPI cluster, equivalent to the CloudFormation template from [OpenShift4-AWS-BareMetal-UPI](https://github.com/ay-garg/OpenShift4-AWS-BareMetal-UPI).

**This stage only creates the base infrastructure (VPC, subnets, security groups, S3, NLB, Route53, bastion, etc.).**

## Features
- VPC with 3 public and 3 private subnets
- Internet Gateway, 3 NAT Gateways, and route tables
- S3 bucket and S3 VPC endpoint
- Private Route53 Hosted Zone and DNS records for OpenShift
- Internal Network Load Balancer with listeners and target groups
- Security group for bastion/utility EC2 instance
- Bastion EC2 instance

## Two-Stage Workflow
1. **Apply this stage first** to create the base infrastructure.
2. **SSH to the bastion node** and generate or upload the ignition configs for bootstrap, master, and worker nodes.
3. **Apply the second stage** (in `openshift_nodes/`) to create the OpenShift nodes, using the outputs from this stage as input variables.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) v1.0+
- AWS CLI configured with appropriate permissions
- An existing EC2 Key Pair in your AWS account

## Variables
| Name                | Description                                      | Required |
|---------------------|--------------------------------------------------|----------|
| key_name            | Name of existing EC2 KeyPair for SSH             | Yes      |
| s3_bucket_name      | Name of the S3 bucket to be created              | Yes      |
| resource_prefix     | Prefix for resource names                        | Yes      |
| private_domain_name | Domain name for private hosted zone              | Yes      |
| ec2_instance_ami    | AMI ID for bastion EC2 instance                  | Yes      |
| ocp4_cluster_name   | OpenShift 4 Cluster name                         | Yes      |
| aws_region          | AWS region to deploy resources (default: us-east-1) | No   |

## Usage
1. Initialize Terraform:
   ```sh
   cd infra
   terraform init
   ```
2. Set variables in a `terraform.tfvars` file or via CLI.
3. Plan and apply:
   ```sh
   terraform plan
   terraform apply
   ```
4. Use the outputs (subnet IDs, security group ID, etc.) as input variables for the next stage (`openshift_nodes/`).

## Outputs
- `vpc_id`: VPC Id
- `public_subnet_ids`: List of public subnet IDs
- `private_subnet_ids`: List of private subnet IDs
- `target_group_6443_id`, `target_group_22623_id`, `target_group_443_id`, `target_group_80_id`: NLB target group IDs
- `bastion_public_ip`: Public IP of the bastion EC2 instance
- `security_group_id`: Security group ID for the bastion

## Reference
- [Original CloudFormation Templates](https://github.com/ay-garg/OpenShift4-AWS-BareMetal-UPI) 

---

### **What’s New**

- **New variables in `openshift_nodes/variables.tf`:**
  - `target_group_80_arn`
  - `target_group_443_arn`

- **New resources in `openshift_nodes/main.tf`:**
  - `aws_lb_target_group_attachment.bootstrap_80`
  - `aws_lb_target_group_attachment.bootstrap_443`

---

### **How It Works**

- **During bootstrap phase:**  
  - The bootstrap node is registered with the 6443 and 22623 target groups.

- **When you apply with `create_masters = true` and `create_workers = true`:**  
  - The bootstrap node is also registered with the 80 and 443 target groups, but only after masters and workers are created (using `depends_on`).

---

### **What to do in your `terraform.tfvars` for openshift_nodes:**

```hcl
<code_block_to_apply_changes_from>
target_group_6443_arn  = "<output-from-infra>"
target_group_22623_arn = "<output-from-infra>"
target_group_80_arn    = "<output-from-infra>"
target_group_443_arn   = "<output-from-infra>"
```

---

This matches the OpenShift UPI workflow:  
- Bootstrap node is initially only on 6443/22623.
- Once masters/workers are up, it is also on 80/443.

If you want to automate deregistration of the bootstrap node from all target groups after the cluster is up, let me know! 