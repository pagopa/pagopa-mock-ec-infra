module "vpc" {
  source                = "terraform-aws-modules/vpc/aws"
  version               = "3.18.1"
  name                  = format("%s-vpc", local.project)
  cidr                  = var.vpc_cidr
  azs                   = data.aws_availability_zones.available.names
  private_subnets       = var.vpc_private_subnets_cidr
  private_subnet_suffix = "private"
  public_subnets        = var.vpc_public_subnets_cidr
  public_subnet_suffix  = "public"
  database_subnets      = []
  enable_nat_gateway    = var.enable_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

}