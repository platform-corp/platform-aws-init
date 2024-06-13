resource "tls_private_key" "ssh" {
  depends_on = [ var.module_depends_on ]
  algorithm = "ED25519"
}

locals {
  public_key = var.public_key == "" ? tls_private_key.ssh.public_key_openssh : var.public_key
}

resource "local_file" "private_key" {
  count = var.public_key == "" ? 1 : 0
  filename = "id_ed25519"
  content  = tls_private_key.ssh.private_key_openssh
  file_permission = "0600"
}

resource "aws_key_pair" "admin_key" {
  depends_on = [ tls_private_key.ssh, local_file.private_key, local.public_key ]
  key_name   = "admin-key"
  public_key = local.public_key
}

module "vault" {
  module_depends_on = aws_key_pair.admin_key
  source = "./ec2/vault"
  coreos_ami_id = var.coreos_ami_id
  subnet_id = var.network_config.main.subnet.secure.id
  vpc_security_group_ids = [ var.security_config.vault_sg_id ] 
  bucket_name = var.s3_config.ignition_config.bucket_name
  iam_config = var.iam_config.vault_ec2
  hostname = "vault"
  route53_zone_id = var.route53_zone_id
  domain_name = var.domain_name
  key_name = aws_key_pair.admin_key.key_name
}

module "bastion" {
  module_depends_on = [ module.vault ]
  source = "./ec2/bastion"
  coreos_ami_id = var.coreos_ami_id
  subnet_id = var.network_config.main.subnet.access.id 
  vpc_security_group_ids = [ var.security_config.bastion_sg_id ]
  bucket_name = var.s3_config.ignition_config.bucket_name
  iam_config = var.iam_config.ec2
  hostname = "bastion"
  route53_zone_id = var.route53_zone_id
  domain_name = var.domain_name
  key_name = aws_key_pair.admin_key.key_name
}
