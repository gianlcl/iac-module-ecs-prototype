locals {
  folders      = split("/", path_relative_to_include())
  
  global_vars  = yamldecode(file("var_global.yaml"))
  env_vars     = yamldecode(file(format("%s/%s", local.folders[0], "var_env.yaml")))
  region_vars  = yamldecode(file(format("%s/%s/%s", local.folders[0], local.folders[1], "var_region.yaml")))
  
  common_tags  = merge(local.global_vars.tags, local.env_vars.tags, local.region_vars.tags)
}

inputs = {
  test_input = "test_value"
}

generate "provider" {
  path      = "auto_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "aws" {
      region = "${local.global_vars.aws_default_region}"
      default_tags {
        tags = {
          ${indent(6 ,yamlencode(local.common_tags))}
        }
      }
    }
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "5.12.0"
        }
      }
    }
  EOF
}

remote_state {
  backend = "s3"

  config = {
    bucket = format("%s-%s-%s", local.global_vars.tenant, local.global_vars.tags.project_name, local.global_vars.tags.managed_by)
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = local.global_vars.aws_default_region
    dynamodb_table = format("terragrunt-%s-%s-state-lock", local.global_vars.tags.project_name, local.env_vars.tags.environment)
  }

  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
