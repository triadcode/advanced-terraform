# //////////////////////////////
# OUTPUT
# //////////////////////////////
output "instance-ip" {
  #  value = module.ec2_cluster.public_ip
  value = aws_instance.node_instances.*.public_ip
}

output "instance-dns" {
  #  value = module.ec2_cluster.public_dns
  value = aws_instance.node_instances.*.public_dns
}