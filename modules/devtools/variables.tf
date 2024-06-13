variable "project_name" {
    description = "The name of the CodeBuild project."
    type        = string
    default     = "vault-init"
}

variable "s3_config" {
    description = "The S3 configuration."
    type        = any
}

variable "repository_url" {
    description = "The URL of the repository."
    type        = string
}

variable "branch" {
    description = "The branch to build."
    type        = string
    default     = "main"
}

variable "iam_config" {
    description = "The IAM instance profile to use for the Vault instances."
    type        = any
}

variable "pipeline_name" {
  description = "The name of the CodePipeline."
  type        = string
  default     = "vault-init"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
  default     = "vault-init"
}

variable "cloudformation_stack_name" {
  description = "The name of the CloudFormation stack."
  type        = string
  default     = "vault-init"
}

variable "vault_init_repo_name" {
  description = "The name of the ECR repository."
  type        = string
  default     = "vault-init"
}

variable "lambda_bucket_key" {
  description = "The key of the S3 bucket."
  type        = string
  default     = "vault-init-template.zip"
}

variable "domain_name" {
  description = "The domain name."
  type        = string
  default     = "platform.corp"
}

variable "region" {
  description = "The region."
  type        = string
}

variable "vault_address" {
  description = "The address of the Vault server."
  type        = string
  default     = ""
}

variable "secret_name" {
  description = "The name of the secret."
  type        = string
  default     = "vault-init"
}

variable "network_config" {
  description = "The network configuration."
  type        = any
}

variable "security_config" {
  description = "The security configuration."
  type        = any
}