# Definindo a região da AWS como variável
variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

