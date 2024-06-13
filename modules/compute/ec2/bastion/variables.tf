variable "instance_type" {
  description = "The instance type to use for the Vault instances."
  type        = string
  default     = "t2.micro" 
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

variable "key_name" {
  description = "The name of the key pair to use for the Vault instances."
  type        = string
}