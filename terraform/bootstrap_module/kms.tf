data "aws_caller_identity" "current" {}

locals {
  tf_kms_key_name = "${var.app_name}-${var.environment}-tfstate"
}

resource "aws_kms_key" "terraform" {
  description = "Terraform KMS key"
  enable_key_rotation = true
  policy = data.aws_iam_policy_document.kms_terraform.json
}

resource "aws_kms_alias" "terraform" {
  name          = "alias/${local.tf_kms_key_name}"
  target_key_id = aws_kms_key.terraform.key_id
}

data "aws_iam_policy_document" "kms_terraform" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.kms_key_users) > 0 ? [1] : []
    content {
      sid    = "Allow use of the key"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.kms_key_users
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
      ]
      resources = ["*"]
    }
  }
}
