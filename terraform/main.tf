terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source      = "./modules/networking"
  environment = var.environment
}

module "storage" {
  source      = "./modules/storage"
  environment = var.environment
}

module "processing" {
  source         = "./modules/processing"
  environment    = var.environment
  glue_role_arn  = module.iam.glue_role_arn
  s3_bucket_name = module.storage.data_bucket_name

  depends_on = [module.storage]
}

module "warehouse" {
  source            = "./modules/warehouse"
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.private_subnet_ids
  redshift_password = var.redshift_password

  depends_on = [module.networking]
}