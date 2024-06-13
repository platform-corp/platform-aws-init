variable "module_depends_on" {
  type    = any
  default = []
}

output "iam_config" {
  value = {
    ec2 = {
      role_arn = aws_iam_role.ec2_role.arn
      role_name = aws_iam_role.ec2_role.name
      instance_profile_name = aws_iam_instance_profile.ec2_instance_profile.name
    },
    vault_ec2 = {
      role_arn = aws_iam_role.vault_ec2_role.arn
      role_name = aws_iam_role.vault_ec2_role.name
      instance_profile_name = aws_iam_instance_profile.vault_ec2_instance_profile.name
    },
    vault_init_lambda = {
      role_arn = aws_iam_role.vault_init_lambda_role.arn
      role_name = aws_iam_role.vault_init_lambda_role.name
      instance_profile_name = aws_iam_instance_profile.vault_init_lambda_instance_profile.name
    },
    vault_init_codebuild = {
      role_arn = aws_iam_role.vault_init_codebuild_role.arn
      role_name = aws_iam_role.vault_init_codebuild_role.name
      instance_profile_name = aws_iam_instance_profile.vault_init_codebuild_profile.name
    },
    vault_init_codepipeline = {
      role_arn = aws_iam_role.vault_init_codepipeline_role.arn
      role_name = aws_iam_role.vault_init_codepipeline_role.name
      instance_profile_name = aws_iam_instance_profile.vault_init_codepipeline_profile.name
    },
    vault_init_cloudformation = {
      role_arn = aws_iam_role.vault_init_cloudformation_role.arn
      role_name = aws_iam_role.vault_init_cloudformation_role.name
      instance_profile_name = aws_iam_instance_profile.vault_init_cloudformation_profile.name
    }
  }
}