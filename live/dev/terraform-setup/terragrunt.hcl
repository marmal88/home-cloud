include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/${basename(get_terragrunt_dir())}"
}

locals {
  environment_inputs = read_terragrunt_config(find_in_parent_folders("environment.hcl")).inputs
  environment_tags   = local.environment_inputs.tags
}

inputs = {
  tags = local.environment_tags
}