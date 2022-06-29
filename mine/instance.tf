# //////////////////////////////
# EC2 MODULE
# //////////////////////////////
#module "ec2_cluster" {
#  source                 = "terraform-aws-modules/ec2-instance/aws"
#  version                = "~> 2.0"
#
#  name                   = "frontend-linux"
#  instance_count         = 1
#
#  ami                    = data.aws_ami.aws-linux.id
#  instance_type          = "t2.micro"
#
#  vpc_security_group_ids = [aws_security_group.sg_frontend.id]
#  subnet_id              = module.vpc.public_subnets[1]
#
#}

resource "aws_instance" "node_instances" {
  count = var.environment_instance_settings[var.deploy_environment].instance_count
  ami = data.aws_ami.aws-linux.id
  instance_type = var.environment_instance_settings[var.deploy_environment].instance_type
  #subnet_id = aws_subnet.subnet1.id
  subnet_id = module.vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.sg-nodejs-instance.id]
  key_name = var.ssh_key_name
  monitoring = var.environment_instance_settings[var.deploy_environment].monitoring
  tags = {Environment = var.environment_map[var.deploy_environment]}

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.ssh_key_path)
  }
}
