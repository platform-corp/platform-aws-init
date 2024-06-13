variable "region" {
  description = "The AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "domain_name" {
  description = "The domain name for the private hosted zone"
  type        = string
  default     = "platform.corp"
}

variable "coreos_ami_id" {
  description = "The CoreOS AMI ID"
  type        = string
  default     = "ami-06128ecf4b4101217"
}

variable "repository_url" {
  description = "The URL of the repository"
  type        = string
  default     = "https://github.com/platform-corp/vault-init-lambda.git"
}

variable "main_vpc" {
  description = "The network variables"
  type        = object( { 
    vpc_cidr      = string
    vpc_name      = string
    access_subnet = object({
      name              = string
      cidr              = string
      availability_zone = string
    })
    secure_subnet = object({
      name              = string
      cidr              = string
      availability_zone = string
    })
  })
  default = {
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "main"
    access_subnet = {
      name              = "access"
      cidr              = "10.0.1.0/24"
      availability_zone = "eu-central-1a"
    },
    secure_subnet = {
      name              = "secure"
      cidr              = "10.0.2.0/24"
      availability_zone = "eu-central-1a"
    }
  }
}
