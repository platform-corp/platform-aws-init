# variable "hostnames" {
#   description = "Hostname of the machine."
#   type        = list(string)
# }

variable "vault_cluster_name" {
  description = "Name of the Vault cluster."
  type        = string
  default     = "vault-cluster"
}
  
variable "instance_type" {
  description = "The instance type to use for the Vault instances."
  type        = string
  default     = "t2.micro" 
}

variable "cert_subject" {
  description = "The subject for the certificate."
  type        = string
  default     = ""
}

variable "coreos_ami_id" {
  description = "The AMI ID for CoreOS."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to use for the Vault instances."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "The security group IDs to use for the Vault instances."
  type        = list(string)
}

 variable "bucket_name" {
   description = "The name of the S3 bucket to store the Ignition files."
   type        = string
}

variable "iam_config" {
  description = "The IAM instance profile to use for the Vault instances."
  type = object({
    role_arn = string
    role_name = string
    instance_profile_name = string
  })
}

variable "ebs_volume_size" {
  description = "The size of the EBS volume to attach to the Vault instances."
  type        = number
  default     = 10
}

variable "ebs_volume_type" {
  description = "The type of the EBS volume to attach to the Vault instances."
  type        = string
  default     = "gp2"
}

variable "ebs_device_name" {
  description = "The device name to use for the EBS volume."
  type        = string
  default     = "/dev/xvdb"
}

variable "hostname" {
  description = "The hostname to use for the Vault instances."
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 zone to use for the Vault instances."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the private hosted zone"
  type        = string
  default     = "platform.corp"
}

variable "proxy" {
  description = "The proxy to use for the Vault instances."
  type        = string
  default     = ""
}

variable "no_proxy" {
  description = "The no_proxy to use for the Vault instances."
  type        = string
  default     = ""
}

variable "region" {
  description = "The AWS region to use."
  type        = string
  default     = "eu-central-1" 
}

variable "key_name" {
  description = "The key pair name to use for the Vault instances."
  type        = string
}