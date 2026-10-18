output "ec2_public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.my_ec2_instance.public_dns
}

output "ec2_private_ip" {
  value = aws_instance.my_ec2_instance.private_ip
}