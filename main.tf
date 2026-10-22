resource "aws_key_pair" "my_key" {
  key_name   = "terra-ec2-key"
  public_key = file("terra-ec2-key.pub")
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "automated-security-group"
  description = "Security group for automated EC2 instance"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["223.185.130.42/32"]
    description = "Allow SSH access from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }


  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow access to port 8000 from anywhere"
  }

}

resource "aws_instance" "my_ec2_instance" {
  ami = var.ec2_ami_id
  for_each = tomap({
    TWS_Junoon-automate-micro  = "t3.micro"
    TWS_Junoon-automate-medium = "t3.small"
  })

  depends_on      = [aws_security_group.my_security_group]
  instance_type   = each.value
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_security_group.name]
  user_data       = file("install.sh")
  root_block_device {
    volume_size = var.env == "dev" ? 20 : var.ec2_default_root_storage
    volume_type = "gp3"
  }

  tags = {
    Name = each.key
  }
}

resource "aws_ec2_instance_state" "my_ec2_insance_state" {
  for_each    = aws_instance.my_ec2_instance
  instance_id = each.value.id
  state       = "running"
}



resource "aws_instance" "my_new_instance" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
}