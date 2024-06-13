# variable "ignition_bucket_name" {
#   description = "The name of the S3 bucket"
#   type        = string
# }

# variable "lambda_bucket_name" {
#   description = "The name of the S3 bucket"
#   type        = string
# }

variable "s3_config" {
  description = "The S3 configuration"
  type        = any
}