output "vpc_id" {
  description = "ID of VPC"
  value       = aws_vpc.demo-vpc.id
}

output "public_subnet_id" {
  description = "ID of public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of private subnet"
  value       = aws_subnet.private.id
}

output "nat_gateway_id" {
  description = "id of NAT gateway"
  value       = aws_nat_gateway.demo.id
}

output "ec2_public_ip" {
  description = "ipv4 of public ec2"
  value       = aws_instance.public[*].public_ip
}