variable "environment" {
  type = string
  description = "Environment dev/prod/stage etc"
}

variable "region" {
  type = string
  description = "AWS Region"
}

variable "kms_key_users" {
  description = "The list of IAM user or role ARNs which are going to use the Terraform KMS key."
  type = list(string)
  default = []
}

variable "app_name" {
  type = string
  description = "App name"
}
