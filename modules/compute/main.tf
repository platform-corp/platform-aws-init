variable "module_depends_on" {
  type    = any
  default = []
}

output "bastion_ip" {
  value = module.bastion.public_ip
}

output "private_key_file" {
  value = var.public_key == "" ? local_file.private_key[0].filename : "</path/to/your/private/key/file>"
}
