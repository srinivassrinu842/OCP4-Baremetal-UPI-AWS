variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to be created"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to be added to the starting of each resource name"
  type        = string
}

variable "private_domain_name" {
  description = "Domain name for private hosted zone"
  type        = string
}

variable "ec2_instance_ami" {
  description = "AMI ID for bastion EC2 instance"
  type        = string
}

variable "ocp4_cluster_name" {
  description = "OpenShift 4 Cluster name"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
} 