provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  cidr_c_private_subnets = 1
  cidr_c_public_subnets  = 11
  max_private_subnets    = 2
  max_public_subnets     = 2
  availability_zones     = data.aws_availability_zones.available.names
  private_subnets = [
    for az in local.availability_zones :
    "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_private_subnets + index(local.availability_zones, az)}.0/24"
  ]
  public_subnets = [
    for az in local.availability_zones :
    "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_public_subnets + index(local.availability_zones, az)}.0/24"
  ]
  build_date = formatdate("MM-DD-YYYY", timestamp())
  tags = {
    AccountID   = var.account_id
    Environment = var.environment
    BuildDate   = local.build_date
    Owner       = var.owner
    Contact     = var.contact
    Region      = var.aws_region
  }
  flow_log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
  traffic_type = "ACCEPT"
  s3_arn  = "arn:aws:s3:::${var.s3_bucket_prefix}-${var.account_id}-${var.aws_region}/sophos-optix-flowlogs/"
  iam_arn = "arn:aws:iam::${var.account_id}:role/Sophos-Optix-labda-to-cloudWatch"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = "${var.account_id}-${var.environment}-${local.build_date}"
  cidr = "${lookup(var.cidr_ab, var.environment)}.0.0/16"

  azs             = local.availability_zones
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = false

  enable_vpn_gateway  = false
  enable_dhcp_options = false

  manage_default_security_group  = true
  default_security_group_name  = "sg-${var.account_id}-${var.environment}"
  default_security_group_ingress = [
    default_inbound = {
      rule_action = "allow"
      from_port   = 3389
      to_port = 3389 "tcp"
    }
  ]
  default_security_group_egress  = []

  enable_flow_log                   = true
  flow_log_destination_type         = "s3"
  flow_log_destination_arn          = local.s3_arn
  flow_log_cloudwatch_iam_role_arn  = local.iam_arn
  flow_log_file_format              = "plain-text"
  flow_log_max_aggregation_interval = 600
  flow_log_log_format               = local.flow_log_format
  flow_log_traffic_type             = local.traffic_type

  vpc_flow_log_tags = {
      created_by = "optix"
  }

  tags = merge(
    local.tags,
    var.default_tags
  )
}
