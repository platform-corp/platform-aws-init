terraform { 
  required_providers {
  aws = {
      source  = "hashicorp/aws"
      version = "~> 5.53.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
  network_vars = var.main_vpc
  region = var.region
  domain_name = var.domain_name
}

module "storage" {
  module_depends_on = [ module.network ]
  source = "./modules/storage"
  ignition_bucket_prefix = "ignition-files"
  lambda_bucket_prefix = "vault-init-lambda-files"
}

module "iam" {
  module_depends_on = [ module.network ]
  source = "./modules/iam"
  s3_config = module.storage.s3_config
}

module "compute" {
  module_depends_on = [ module.network, module.storage, module.iam ]
  source = "./modules/compute"
  coreos_ami_id = var.coreos_ami_id
  network_config = module.network.network_config
  security_config = module.network.sg_config
  s3_config = module.storage.s3_config
  iam_config = module.iam.iam_config
  route53_zone_id = module.network.zone_id
  domain_name = var.domain_name
  region = var.region
}

module "devtools" {
  module_depends_on = [ module.compute ]
  source = "./modules/devtools"
  iam_config = module.iam.iam_config
  s3_config = module.storage.s3_config
  repository_url = var.repository_url
  region = var.region
  network_config = module.network.network_config
  security_config = module.network.sg_config
}

output "login" {
  value = "ssh-add ${module.compute.private_key_file}\nssh -A core@${module.compute.bastion_ip}"
}