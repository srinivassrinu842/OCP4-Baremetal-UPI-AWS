output "vpc_id" {
  description = "VPC Id"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public Subnet Ids"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private Subnet Ids"
  value       = aws_subnet.private[*].id
}

output "target_group_6443_id" {
  description = "TargetGroup6443 Id"
  value       = aws_lb_target_group.tg_6443.id
}

output "target_group_22623_id" {
  description = "TargetGroup22623 Id"
  value       = aws_lb_target_group.tg_22623.id
}

output "target_group_443_id" {
  description = "TargetGroup443 Id"
  value       = aws_lb_target_group.tg_443.id
}

output "target_group_80_id" {
  description = "TargetGroup80 Id"
  value       = aws_lb_target_group.tg_80.id
}

output "bastion_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.bastion.public_ip
}

output "security_group_id" {
  description = "Security Group Id"
  value       = aws_security_group.instance.id
} 