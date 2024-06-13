
variable "instance_type" {
  description = "The instance type to use for the instances."
  type        = string
  default     = "t2.micro" 
}

variable "coreos_ami_id" {
  description = "The AMI ID for CoreOS."
  type        = string
}


variable "network_config" {
  description = "The network configuration for the instances."
  type        = any
}

variable "s3_config" {
  description = "The S3 configuration for the instances."
  type        = any
}

variable "iam_config" {
  description = "The IAM instance profile to use for the Vault instances."
  type        = any
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

variable "route53_zone_id" {
  description = "The ID of the Route 53 zone to use for the Vault instances."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the private hosted zone"
  type        = string
  default     = "platform.corp"
}

variable "security_config" {
  description = "The security configuration for the instances."
  type        = any
}

variable "region" {
  description = "The region to use for the instances."
  type        = string
  default     = "eu-central-1"
}

variable "public_key" {
  description = "The public key to use for the instances."
  type        = string
  default     = ""
}
