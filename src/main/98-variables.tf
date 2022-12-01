variable "aws_region" {
  type        = string
  description = "AWS region to create resources. Default Milan"
  default     = "eu-south-1"
}

variable "app_name" {
  type        = string
  description = "App name."
  default     = "mock-ec"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment"
}

variable "env_short" {
  type        = string
  default     = "d"
  description = "Evnironment short."
}

variable "vpc_cidr" {
  type        = string
  default     = "172.16.128.0/18"
  description = "VPC cidr."
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]
}

variable "vpc_private_subnets_cidr" {
  type        = list(string)
  description = "Private subnets list of cidr."
  default     = ["172.16.128.0/24", "172.16.129.0/24", "172.16.130.0/24"]
}

variable "vpc_public_subnets_cidr" {
  type        = list(string)
  description = "Private subnets list of cidr."
  default     = ["172.16.131.0/24", "172.16.132.0/24", "172.16.133.0/24"]
}

variable "vpc_internal_subnets_cidr" {
  type        = list(string)
  description = "Internal subnets list of cidr. Mainly for private endpoints"
  default     = []
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable/Create nat gateway"
  default     = true
}

## ECS
variable "logs_tasks_retention" {
  type        = number
  description = "Log task retantion (days)."
  default     = 7
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}
