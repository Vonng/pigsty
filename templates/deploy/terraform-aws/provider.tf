# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# export AWS_REGION="cn-north-1"
# export AWS_ACCESS_KEY_ID="xxxxxxxxxxx"
# export AWS_SECRET_ACCESS_KEY="xxxxxxx"

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region                   = "cn-northwest-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "vscode"
}