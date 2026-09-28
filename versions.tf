# Rozdział 5.3.2 pracy — backend stanu Terraform z natywną blokadą S3
# (use_lockfile = true, dostępne od Terraform 1.10, ustabilizowane w 1.11).
#
# Zespoły korzystające z Terraform < 1.10 lub OpenTofu < 1.8 powinny zamiast
# tego użyć wariantu z tabelą DynamoDB — patrz plik versions.dynamodb.tf.example
# w tym samym katalogu oraz rozdział 2.4 / 5.3.2 pracy.

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "wsb-nlu-terraform-thesis"
    key          = "envs/prod/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
}
