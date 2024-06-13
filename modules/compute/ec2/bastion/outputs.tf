# output "ignition_configs" {
#     description = "value of the ignition_config output variable from the ignition_config module."
#     value = module.ignition_config.ignition_config
# }

# output "ignition_configs" {
#   value = { for k, v in module.ignition_config : k => v.ignition_config }
#   description = "A map of all ignition configurations by hostname."
# }

output "public_ip" {
  value = aws_instance.bastion.public_ip
  description = "The public IP address of the bastion host."
}