module "bootstrap" {
 source = "../../bootstrap_module/"
 environment = "dev"
 region = "us-east-1"
 kms_key_users = [ "arn:aws:iam::443370702075:role/GitHubAction-AssumeRoleWithAction", 
                   "arn:aws:iam::443370702075:user/riyaz_tk" 
                 ]
 app_name = "ecs-test"
}


