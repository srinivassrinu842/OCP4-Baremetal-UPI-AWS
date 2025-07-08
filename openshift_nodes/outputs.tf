output "bootstrap_private_ip" {
  description = "The private IP address of the Bootstrap instance."
  value       = length(aws_instance.bootstrap) > 0 ? aws_instance.bootstrap[0].private_ip : null
}

output "master_private_ips" {
  description = "The private IP addresses of the Master instances."
  value       = [for m in aws_instance.master : m.private_ip]
}

output "worker_private_ips" {
  description = "The private IP addresses of the Worker instances."
  value       = [for w in aws_instance.worker : w.private_ip]
} 