# //////////////////////////////
# VARIABLES
# //////////////////////////////
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "ssh_key_name" {}
variable "ssh_key_path" {}

variable "deploy_environment" {
  default = "dev"
}

variable "region" {
  default = "us-east-2"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "subnet1_cidr" {
  default = "172.16.0.0/24"
}

variable "environment_map" {
  type = map(string)
  default = {
    "dev"   = "DEV",
    "stage" = "STAGE",
    "prod"  = "PROD"
  }
}

variable "environment_instance_settings" {
  type = map(object({ instance_type = string, monitoring = bool, instance_count = number }))
  default = {
    "dev"   = { instance_type = "t2.micro", monitoring = false, instance_count = 2 },
    "stage" = { instance_type = "t2.micro", monitoring = false, instance_count = 3 },
    "prod"  = { instance_type = "t2.micro", monitoring = true, instance_count = 3 }
  }
}