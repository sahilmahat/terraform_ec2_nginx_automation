variable "ec2_instance_type" {
  default = "t3.micro"
  type    = string
}

variable "ec2_default_root_storage" {
  default = 10
  type    = number
}

variable "ec2_ami_id" {
  default = "ami-01a00762f46d584a1"
  type    = string
}

variable "env" {
  default = "dev"
  type    = string

}