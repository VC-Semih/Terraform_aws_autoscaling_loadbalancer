variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type        = string
  description = "Nom du vpc (example ccm-insset)"
  default     = "ccm-insset"
}
