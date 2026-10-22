output "ec2_public_ip" {
  value = [
    for key in aws_instance.my_ec2_instance : key.public_ip
  ]
}

output "ec2_public_dns" {
  value = [
    for key in aws_instance.my_ec2_instance : key.public_dns
  ]
}

output "ec2_private_ip" {
  value = [
    for key in aws_instance.my_ec2_instance : key.private_ip
  ]
}

output "ec2_arn" {
  value = {
    for k, v in aws_instance.my_ec2_instance : k => v.arn
  }
}