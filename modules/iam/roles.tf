resource "aws_iam_role" "ec2_role" {
  depends_on = [ var.module_depends_on ]
  name       = "ec2-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "attach_s3_ignition_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_ignition_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

######################

resource "aws_iam_role" "vault_ec2_role" {
  depends_on = [ var.module_depends_on ]
  name       = "vault_ec2-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "vault-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "vault_attach_s3_policy" {
  role       = aws_iam_role.vault_ec2_role.name
  policy_arn = aws_iam_policy.s3_ignition_access_policy.arn
}

resource "aws_iam_instance_profile" "vault_ec2_instance_profile" {
  name = "vault-ec2-instance-profile"
  role = aws_iam_role.vault_ec2_role.name
}

######################

resource "aws_iam_role" "vault_init_lambda_role" {
  name = "vault-init-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = [
           "sts:AssumeRole",
        ]
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "vault-init-lambda-exec"
  }
}

resource "aws_iam_role_policy_attachment" "attach_vault_init_lambda_policy" {
  role       = aws_iam_role.vault_init_lambda_role.name
  policy_arn = aws_iam_policy.vault_init_lambda_policy.arn
}

resource "aws_iam_instance_profile" "vault_init_lambda_instance_profile" {
  name = "vault-init-lambda-instance-profile"
  role = aws_iam_role.vault_init_lambda_role.name
}

######################

resource "aws_iam_role" "vault_init_codebuild_role" {
  name = "vault-init-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
      }
    ]
  })

  tags = {
    Name = "vault-init-codebuild-role"
  }
}

resource "aws_iam_role_policy_attachment" "attach_vault_init_codebuild_policy" {
  role = aws_iam_role.vault_init_codebuild_role.id
  policy_arn = aws_iam_policy.vault_init_codebuild_policy.arn
}

resource "aws_iam_instance_profile" "vault_init_codebuild_profile" {
  name = "vault-init-codebuild-profile"
  role = aws_iam_role.vault_init_codebuild_role.id
}

######################

resource "aws_iam_role" "vault_init_codepipeline_role" {
  name = "vault-init-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codepipeline_policy" {
  role = aws_iam_role.vault_init_codepipeline_role.id
  policy_arn = aws_iam_policy.vault_init_codepipeline_policy.arn
}

resource "aws_iam_instance_profile" "vault_init_codepipeline_profile" {
  name = "vault-init-codepipeline-profile"
  role = aws_iam_role.vault_init_codepipeline_role.id
}

######################

resource "aws_iam_role" "vault_init_cloudformation_role" {
  name = "vault-init-cloudformation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "cloudformation.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vault_init_attach_cloudformation_policy" {
  role = aws_iam_role.vault_init_cloudformation_role.id
  policy_arn = aws_iam_policy.vault_init_cloudformation_policy.arn
}

resource "aws_iam_instance_profile" "vault_init_cloudformation_profile" {
  name = "vault-init-cloudformation-profile"
  role = aws_iam_role.vault_init_cloudformation_role.id
}