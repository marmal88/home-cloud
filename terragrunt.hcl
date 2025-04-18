locals {
  environment_name = split("/", path_relative_to_include())[1]
  # Terragrunt will search up the directory tree for the nearest env.hcl
  sensitive_inputs  = read_terragrunt_config(find_in_parent_folders("env.hcl")).inputs
  target_account_id = lookup(local.sensitive_inputs.account_ids, local.environment_name, null)

  # use the environment name to select the IAM Role ARN. Error out if there is no match
  terraform_role_arn = "arn:aws:iam::${local.target_account_id}:role/terraform-role"

  # per environment specific terraform backend variables
  backend_inputs         = read_terragrunt_config(find_in_parent_folders("backend.hcl")).inputs
  backend_bucket_name    = local.backend_inputs.bucket
  backend_bucket_region  = local.backend_inputs.region
  backend_dynamodb_table = local.backend_inputs.dynamodb_table

  # per environment specific inputs
  environment_inputs = read_terragrunt_config(find_in_parent_folders("environment.hcl")).inputs
  environment_region = local.environment_inputs.region
}

# configuration to keep the terraform state files in a GCS bucket
remote_state {
  backend = "s3"

  config = {
    profile        = "terraform-user"
    role_arn       = local.terraform_role_arn
    bucket         = local.backend_bucket_name
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.backend_bucket_region
    dynamodb_table = local.backend_dynamodb_table
    encrypt        = true
  }
  # terragrunt will generate the terraform file with the backend configuration
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# set the google provider and version
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

provider "aws" {
  profile = "terraform-user"
  region  = "${local.environment_region}"
  assume_role {
    role_arn = "${local.terraform_role_arn}"
    session_name = "${local.environment_name}-${basename(get_terragrunt_dir())}"
  }
}
EOF
}