variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "private subnet CIDR block"
  type        = string
  default     = "10.0.2.0/24"
}

variable "all_traffic" {
  description = "allows all traffic"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ami" {
  description = "ami of ubuntu"
  type        = string
  default     = "ami-0224ce6f9504665ee"
}

variable "instance_type" {
  description = "instance type of ec2"
  type        = string
  default     = "t3.micro"
}