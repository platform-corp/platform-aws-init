resource "aws_codebuild_project" "vault_init_build" {
  depends_on = [ var.module_depends_on ]
  name        = var.project_name
  description = "Build project for Go app"

  service_role = var.iam_config.vault_init_codebuild.role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${aws_ecr_repository.vault_init_repo.repository_url}"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name  = "GIT_URL"
      value = var.repository_url
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $REPOSITORY_URI
      - echo Getting the source code...
      - git clone $GIT_URL app
  build:
    commands:
      - echo Building the Docker image...
      - cd app && docker build -t $REPOSITORY_URI:$IMAGE_TAG .
  post_build:
    commands:
      - echo Pushing the Docker image...
      - docker push $REPOSITORY_URI:$IMAGE_TAG
artifacts:
  files:
    - lambda-template.yaml
EOF
  }
}
