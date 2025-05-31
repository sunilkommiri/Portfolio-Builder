# terraform/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets."
  value       = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
}

output "frontend_ecr_repository_url" {
  description = "The URL of the frontend ECR repository."
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "The URL of the backend ECR repository."
  value       = aws_ecr_repository.backend.repository_url
}

output "rds_instance_address" {
  description = "The address of the RDS instance."
  value       = aws_db_instance.default.address
}

output "rds_instance_port" {
  description = "The port of the RDS instance."
  value       = aws_db_instance.default.port
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_http_listener_arn" {
  description = "ARN of the ALB HTTP listener"
  value       = aws_lb_listener.http.arn
}
