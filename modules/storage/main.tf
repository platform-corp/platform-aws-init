variable "module_depends_on" {
  type    = any
  default = []
}

resource "aws_s3_bucket" "ignition_config" {
  depends_on    = [ var.module_depends_on ]
  bucket_prefix = "${var.ignition_bucket_prefix}-"
  force_destroy = true

  tags = {
    Prefix      = var.ignition_bucket_prefix
  }
}

resource "aws_s3_bucket" "vault_init_lambda_config" {
  depends_on    = [ var.module_depends_on ]
  bucket_prefix = "${var.lambda_bucket_prefix}-"
  force_destroy = true

  tags = {
    Prefix      = var.lambda_bucket_prefix
  }
}

resource "aws_s3_bucket_versioning" "s3_blucket_lambda_versioning" {
  bucket = aws_s3_bucket.vault_init_lambda_config.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

output "s3_config" {
  value = {
    ignition_config = {
      bucket_name = aws_s3_bucket.ignition_config.bucket
      bucket_arn  = aws_s3_bucket.ignition_config.arn
    },
    vault_init_lambda = {
      bucket_name = aws_s3_bucket.vault_init_lambda_config.bucket
      bucket_arn  = aws_s3_bucket.vault_init_lambda_config.arn
    }
  }
}