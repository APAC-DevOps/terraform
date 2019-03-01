variable "access_key" { }
variable "secret_key" { }
variable "aws_region" {
  default = "ap-southeast-2"
}

variable "aws_ami" {
  default = {
  }
}

variable "aws_aem_instance_type" {
}

variable "aws_key_pair" {
}

variable "ap-southeast-2a" {
  default = ""
}

variable "ap-southeast-2b" {
  default = ""
}

variable "ap-southeast-2c" {
  default = ""
}

variable "aws_availability_zone" {
  default = {
    ap-southeast-2a = "ap-southeast-2a"
    ap-southeast-2b = "ap-southeast-2b"
    ap-southeast-2c = "ap-southeast-2c"
  }
}

variable "aws_sns_topic_email_notification" {}
