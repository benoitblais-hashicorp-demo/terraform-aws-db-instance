output "vpc_id" {
  description = "The ID of the test VPC"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "The IDs of the test subnets"
  value       = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

output "security_group_id" {
  description = "The ID of the test security group"
  value       = aws_security_group.this.id
}
