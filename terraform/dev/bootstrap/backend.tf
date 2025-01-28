terraform {
  backend "s3" {
    bucket     = "tfstate-dev-us-east-1"
    key        = "ecs-test/terraform.tfstate"
    kms_key_id = "alias/ecs-test-dev-tfstate"
    encrypt    = true

    dynamodb_table = "tfstates-locking"
    region         = "us-east-1"
  }
}
