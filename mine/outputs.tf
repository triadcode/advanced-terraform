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

output "node-instance-dns" {
  value = module.node_instance.instance_dns
}