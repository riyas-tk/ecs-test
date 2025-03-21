data "aws_caller_identity" "main" {}

#### BACKEND RESOURCES PERMISSIONS
data "aws_iam_policy_document" "tfstates_bucket_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::tfstate-${var.environment}-${var.region}",
      "arn:aws:s3:::tfstate-${var.environment}-${var.region}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.main.account_id}:table/tfstates-locking",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:*",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.main.account_id}:role/GhaAssumeRoleWithAction",
      "arn:aws:iam::${data.aws_caller_identity.main.account_id}:policy/TerraformStatesBucketAccess",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:*",
    ]
   resources = [ "*" ]
  }
}

resource "aws_iam_policy" "tfstates_bucket_access" {
  name        = "TerraformStatesBucketAccess"
  description = "Policy for tfstates bucket"
  policy      = data.aws_iam_policy_document.tfstates_bucket_access.json
}

resource "aws_iam_role" "gh_assume_role" {
  name = "GhaAssumeRoleWithAction"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.main.account_id}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": "repo:riyas-tk/ecs-test:ref:refs/heads/main"
                }
            }
        }
    ]
})
}

resource "aws_iam_policy_attachment" "deployment_policy_attachment" {
  name       = "deployment_policy_attachment"
  roles      = [ aws_iam_role.gh_assume_role.name ]
  policy_arn = aws_iam_policy.tfstates_bucket_access.arn
}



