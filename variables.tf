variable "account_id" {
  description = "AWS 12-digit account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS Region in which to deploy resources to"
  type        = string
}

variable "cidr_ab" {
  description = "CIDR environment mapping for dynamic subnets"
  type        = map(any)
  default = {
    development = "10.22"
    qa          = "10.24"
    testing     = "10.26"
    production  = "10.28"
  }
}

variable "contact" {
  description = "Contact email address"
  type        = string
}

variable "default_tags" {
  description = "Default tags attached to all provisioned resources"
  type        = map(string)
  default = {
    Team    = "Sophos CSPM Team"
    Contact = "publiccloud@sophos.com"
  }
}

variable "environment" {
  description = "Environment to deploy. Options: development, qa, testing, production"
  default     = "development"
}

variable "owner" {
  description = "Contact name of the resource owner"
  type        = string
}

variable "s3_bucket_prefix" {
  description = "Bucket prefix for VPC Flow Logs"
  type        = string
  default     = "sophos-optix-flowlogs"
}