variable "resource_prefix" {
  description = "Prefix to be added to the starting of each resource name"
  type        = string
}

variable "bootstrap_instance_type" {
  description = "EC2 instance type for bootstrap node"
  type        = string
  default     = "m4.xlarge"
}

variable "bootstrap_ami_id" {
  description = "AMI ID for the RHCOS bootstrap instance"
  type        = string
}

variable "bootstrap_subnet_id" {
  description = "Subnet ID for the bootstrap node"
  type        = string
}

variable "bootstrap_user_data" {
  description = "Base64-encoded user data for bootstrap node (ignition)"
  type        = string
  default     = ""
}

variable "bootstrap_user_data_file" {
  description = "Path to the bootstrap ignition file"
  type        = string
  default     = ""
}

variable "create_bootstrap" {
  description = "Whether to create the bootstrap node (apply first, then set to false for next stage)"
  type        = bool
  default     = true
}

variable "create_masters" {
  description = "Whether to create the master nodes (apply after bootstrap is ready)"
  type        = bool
  default     = false
}

variable "create_workers" {
  description = "Whether to create the worker nodes (apply after bootstrap is ready)"
  type        = bool
  default     = false
}

variable "master_instance_type" {
  description = "EC2 instance type for master nodes"
  type        = string
  default     = "m4.2xlarge"
}

variable "master_ami_id" {
  description = "AMI ID for the RHCOS master nodes"
  type        = string
}

variable "master_subnet_ids" {
  description = "List of subnet IDs for master nodes (3)"
  type        = list(string)
}

variable "master_user_data" {
  description = "Base64-encoded user data for master nodes (ignition)"
  type        = string
  default     = ""
}

variable "master_user_data_file" {
  description = "Path to the master ignition file"
  type        = string
  default     = ""
}

variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "m4.2xlarge"
}

variable "worker_ami_id" {
  description = "AMI ID for the RHCOS worker nodes"
  type        = string
}

variable "worker_subnet_ids" {
  description = "List of subnet IDs for worker nodes (2)"
  type        = list(string)
}

variable "worker_user_data" {
  description = "Base64-encoded user data for worker nodes (ignition)"
  type        = string
  default     = ""
}

variable "worker_user_data_file" {
  description = "Path to the worker ignition file"
  type        = string
  default     = ""
}

variable "instance_security_group" {
  description = "Security group ID for all OpenShift nodes"
  type        = string
}

variable "target_group_6443_arn" {
  description = "ARN of the NLB target group for port 6443"
  type        = string
}

variable "target_group_22623_arn" {
  description = "ARN of the NLB target group for port 22623"
  type        = string
}

variable "target_group_80_arn" {
  description = "ARN of the NLB target group for port 80"
  type        = string
}

variable "target_group_443_arn" {
  description = "ARN of the NLB target group for port 443"
  type        = string
} 