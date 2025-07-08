# OpenShift 4 AWS BareMetal UPI - OpenShift Nodes (Terraform)

This Terraform configuration provisions the OpenShift 4 UPI nodes (bootstrap, master, worker) on AWS. It is intended to be used **after** the base infrastructure is created with the `infra/` stage.

## Staged Workflow
1. **Apply 1:** Set `create_bootstrap = true`, `create_masters = false`, `create_workers = false` (default). This creates only the bootstrap node.
2. Wait for the bootstrap process to complete (monitor OpenShift install logs).
3. Then copy the ignition files to ignitions directory in the current path. (Using SCP from the bastion host)
4. **Apply 2:** Set `create_bootstrap = false`, `create_masters = true`, `create_workers = true`. This creates the master and worker nodes.

## Variables
| Name                        | Description                                      | Required |
|-----------------------------|--------------------------------------------------|----------|
| resource_prefix             | Prefix for resource names                        | Yes      |
| bootstrap_instance_type     | EC2 instance type for bootstrap node             | No (default: m4.xlarge) |
| bootstrap_ami_id            | AMI ID for the RHCOS bootstrap instance          | Yes      |
| bootstrap_subnet_id         | Subnet ID for the bootstrap node                 | Yes      |
| bootstrap_user_data_file    | Path to the bootstrap ignition file              | Yes      |
| create_bootstrap            | Whether to create the bootstrap node             | No (default: true) |
| master_instance_type        | EC2 instance type for master nodes               | No (default: m4.2xlarge) |
| master_ami_id               | AMI ID for the RHCOS master nodes                | Yes      |
| master_subnet_ids           | List of subnet IDs for master nodes (3)          | Yes      |
| master_user_data_file       | Path to the master ignition file                 | Yes      |
| create_masters              | Whether to create the master nodes               | No (default: false) |
| worker_instance_type        | EC2 instance type for worker nodes               | No (default: m4.2xlarge) |
| worker_ami_id               | AMI ID for the RHCOS worker nodes                | Yes      |
| worker_subnet_ids           | List of subnet IDs for worker nodes (2)          | Yes      |
| worker_user_data_file       | Path to the worker ignition file                 | Yes      |
| create_workers              | Whether to create the worker nodes               | No (default: false) |
| instance_security_group     | Security group ID for all OpenShift nodes        | Yes      |

## Usage
1. Initialize Terraform:
   ```sh
   cd openshift_nodes
   terraform init
   ```
2. Set variables in a `terraform.tfvars` file or via CLI. Use the outputs from `infra/` for subnet IDs and security group ID.
3. **Apply 1:**
   ```hcl
   create_bootstrap = true
   create_masters   = false
   create_workers   = false
   bootstrap_user_data_file = "ignitions/bootstrap.ign"
   # ...other variables...
   ```
   ```sh
   terraform apply
   ```
4. Wait for the bootstrap process to complete.
5. **Apply 2:**
   ```hcl
   create_bootstrap = false
   create_masters   = true
   create_workers   = true
   master_user_data_file = "ignitions/master.ign"
   worker_user_data_file = "ignitions/worker.ign"
   # ...other variables...
   ```
   ```sh
   terraform apply
   ```

## Outputs
- `bootstrap_private_ip`: Private IP of the bootstrap node
- `master_private_ips`: List of private IPs for master nodes
- `worker_private_ips`: List of private IPs for worker nodes

## Notes
- The `*_user_data_file` fields should be set to the path of your ignition config files. The module will read and base64 encode them automatically.
- The subnet IDs and security group ID should be taken from the outputs of the `infra/` stage. 
