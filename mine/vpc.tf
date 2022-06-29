# //////////////////////////////
# VPC
# //////////////////////////////
# Create VPC with multiple availability zones, private and public subnets
#module "vpc" {
#  source = "terraform-aws-modules/vpc/aws"
#  name = "frontend-vpc"
#  cidr = "10.0.0.0/16"
#
#  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
#  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
#
#  enable_nat_gateway = true
#  single_nat_gateway = true
#  # one_nat_gateway_per_az = true
#}

# Declare a vpc with the cidr block specified in the var file
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
}

# Define a subnet inside the vpc
resource "aws_subnet" "subnet1" {
  cidr_block              = var.subnet1_cidr
  vpc_id                  = aws_vpc.vpc1.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[1]
}

# Connect a new gw to the vpc
resource "aws_internet_gateway" "gateway1" {
  vpc_id = aws_vpc.vpc1.id
}

# Define the routing table: gw to vpc and vice versa
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway1.id
  }
}

# Associate the routing table to the subnet
resource "aws_route_table_association" "route-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table1.id
}
