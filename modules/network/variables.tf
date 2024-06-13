variable "region" {
  description = "The AWS region"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the VPC."
  type        = string  
  default     = "platform.corp"
}

variable "network_vars" {
  description = "The network variables"
  type        = object({ 
    vpc_cidr      = string
    vpc_name      = string
    access_subnet = object({
      cidr              = string
      availability_zone = string
    })
    secure_subnet = object({
      cidr              = string
      availability_zone = string
    })
  })
}