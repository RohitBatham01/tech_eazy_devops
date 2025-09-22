variable "aws_region" {
  default = ""
}

variable "ami_id" {
  default = "ami-0279a86684f669718"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  default     = ""
}

