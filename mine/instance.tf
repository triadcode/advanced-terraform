# //////////////////////////////
# EC2 MODULE
# //////////////////////////////
#module "ec2_cluster" {
#  source                 = "terraform-aws-modules/ec2-instance/aws"
#  version                = "~> 2.0"
#
#  name                   = "frontend-linux"
#  instance_count         = var.environment_instance_settings[var.deploy_environment].instance_count
#
#  ami                    = data.aws_ami.aws-linux.id
#  instance_type          = var.environment_instance_settings[var.deploy_environment].instance_type
#
#  vpc_security_group_ids = [aws_security_group.sg-nodejs-instances.id]
#  subnet_id = module.vpc.public_subnets[1]
#  tags = var.environment_instance_settings[var.deploy_environment].tags
#}

resource "aws_instance" "node_instances" {
  count = var.environment_instance_settings[var.deploy_environment].instance_count
  ami = data.aws_ami.aws-linux.id
  instance_type = var.environment_instance_settings[var.deploy_environment].instance_type
  #subnet_id = aws_subnet.subnet1.id
  subnet_id = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.sg-nodejs-instances.id]
  key_name = var.ssh_key_name
  monitoring = var.environment_instance_settings[var.deploy_environment].monitoring
  tags = var.environment_instance_settings[var.deploy_environment].tags

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.ssh_key_path)
  }
}

# Create more nodejs machines using a custom module
module "node_instance" {
    source = "./modules/nodejs-instance"
    instance_count = 2
    environment_tags = {
        "environment_id" = "development"
    }
}
