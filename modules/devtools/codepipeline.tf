data "archive_file" "lambda_zip" {
    depends_on = [ var.module_depends_on ]
    type        = "zip"
    output_path = "${path.module}/files/${var.lambda_bucket_key}"
    source_file = "${path.module}/files/vault-init-template.yaml"
}

resource "aws_s3_object" "lambda_file" {
    bucket   = var.s3_config.vault_init_lambda.bucket_name
    key      = var.lambda_bucket_key
    source   = data.archive_file.lambda_zip.output_path

    tags = {
        Name        = "vault-init-template"
    }
}

locals {
  user_parameters = <<EOF
{
  "vault_address": "${var.vault_address == "" ? "https://vault.${var.domain_name}:8200" : var.vault_address}",
  "aws_region": "${var.region}",
  "secret_name": "${var.secret_name}"
}
EOF
}

resource "aws_codepipeline" "vault_init_pipeline" {
  depends_on = [ var.module_depends_on ]
  name     = var.pipeline_name
  role_arn = var.iam_config.vault_init_codepipeline.role_arn

  artifact_store {
    location = var.s3_config.vault_init_lambda.bucket_name
    type     = "S3"
  }

  stage {
    name = "Trigger"
    
    action {
      name             = "Trigger"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      run_order        = "1"
      configuration = {
        S3Bucket = var.s3_config.vault_init_lambda.bucket_name
        S3ObjectKey = var.lambda_bucket_key
      }
      output_artifacts = [ "SourceArtifact" ]
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = [ "SourceArtifact" ]
      output_artifacts = [ ]

      configuration = {
        ProjectName = var.project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CloudFormation"
      version          = "1"
      input_artifacts  = [ "SourceArtifact" ]

      configuration = {
        ActionMode       = "CREATE_UPDATE"
        Capabilities     = "CAPABILITY_IAM"
        StackName        = var.cloudformation_stack_name
        TemplatePath     = "SourceArtifact::vault-init-template.yaml"
        RoleArn          = var.iam_config.vault_init_cloudformation.role_arn
        ParameterOverrides = jsonencode({
          LambdaFunctionName = var.lambda_function_name
          LambdaRoleArn      = var.iam_config.vault_init_lambda.role_arn
          ImageUri           = "${aws_ecr_repository.vault_init_repo.repository_url}:latest"
          SecurityGroup      = var.security_config.vault_init_lambda_sg_id
          SubnetId           = var.network_config.main.subnet.secure.id
        })
      }
    }
  }

  stage {
    name = "Invoke"
    action {
      name             = "Invoke"
      category         = "Invoke"
      owner            = "AWS"
      provider         = "Lambda"
      version          = "1"
      input_artifacts  = [ "SourceArtifact" ]

      configuration = {
        FunctionName = var.lambda_function_name
        UserParameters = local.user_parameters
      }
    }
  }
}
