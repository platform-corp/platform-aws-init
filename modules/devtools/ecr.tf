resource "aws_ecr_repository" "vault_init_repo" {
  name         = var.vault_init_repo_name
  force_delete = true
}
