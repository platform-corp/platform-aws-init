
variable "module_depends_on" {
  type    = any
  default = []
}

data "aws_caller_identity" "current" {}


module "ignition_config" {
    depends_on = [ var.module_depends_on ]
    source           = "github.com/platform-corp/tf-ignition-config.git"

    # disks            = local.ignition_disks
    # filesystems      = local.ignition_filesystems
    directories      = local.ignition_directories
    files            = local.ignition_files
    systemd_units    = local.ignition_systemd_units
    groups           = local.ignition_groups
    users            = local.ignition_users
}

# module "ignition_config" {
#     source           = "github.com/levente-simon/tf-ignition-config.git"
#     for_each         = local.ignition_files_map

#     directories      = local.ignition_directories
#     disks            = local.ignition_disks
#     files            = each.value
#     filesystems      = local.ignition_filesystems
#     systemd_units    = local.ignition_systemd_units
#     users            = local.ignition_users
#     groups           = local.ignition_groups
# }

resource "aws_s3_object" "ignition_file" {
  bucket   = var.bucket_name
  key      = "vault/ignition.json"
  content  = module.ignition_config.ignition_config

  tags = {
    Name        = "vault-ignition"
  }
}

## Create the KMS key for auto-unseal
resource "aws_kms_key" "vault_auto_unseal_key" {
  description = "Vault Auto Unseal Key"
}

## Create the IAM user 
resource "aws_iam_user" "vault_user" {
  name = "vault-user"
}

resource "aws_iam_access_key" "vault_user_key" {
  user = aws_iam_user.vault_user.name
}

## Create the IAM policy for the KMS key
resource "aws_iam_policy" "kms_policy" {
  name = "ec2-kms-access-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey"
        ],
        Resource = aws_kms_key.vault_auto_unseal_key.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "vault_kms_policy_attachment" {
  user       = aws_iam_user.vault_user.name
  policy_arn = aws_iam_policy.kms_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ec2_kms_policy" {
  role       = var.iam_config.role_name
  policy_arn = aws_iam_policy.kms_policy.arn
}


## Create the Vault instance
resource "aws_instance" "vault" {
  ami                    = var.coreos_ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id
  user_data = base64encode("{\"ignition\":{\"config\":{\"replace\":{\"source\":\"s3://${var.bucket_name}/${aws_s3_object.ignition_file.key}\"}},\"version\":\"3.4.0\"}}")

  # ebs_block_device {
  #   device_name = var.ebs_device_name
  #   volume_size = var.ebs_volume_size
  #   volume_type = var.ebs_volume_type
  # }

  iam_instance_profile = var.iam_config.instance_profile_name
  tags = {
    Name = "vault"
  }
}

resource "aws_kms_key_policy" "vault_auto_unseal_key_policy" {
  key_id = aws_kms_key.vault_auto_unseal_key.id 
  policy      = jsonencode({
    Version = "2012-10-17",
    Id      = "key-policy-id",
    Statement = [
      {
        Sid      = "Enable IAM User Permissions",
        Effect   = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid      = "Allow Vault User Access",
        Effect   = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-user"
        },
        Action   = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid      = "Allow access to the vault instance",
        Effect   = "Allow",
        Principal = {
          AWS = "${var.iam_config.role_arn}"
        },
        Action   = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "${aws_instance.vault.arn}"
          }
        }
      }
    ]
  })
} 

# resource "aws_instance" "vault" {
#   for_each            = { for k, v in module.ignition_config : k => v.ignition_config }
#   ami                 = var.coreos_ami_id
#   instance_type       = var.instance_type
#   key_name            = aws_key_pair.vault_key.key_name
#   vpc_security_group_ids = vpc_security_group_ids
#   subnet_id           = var.subnet_id
#   user_data           = XXX base64encode(each.value)

#   tags = {
#     Name = "vault-${each.key}"
#   }
# }

resource "aws_route53_record" "vault_record" {
  depends_on = [aws_instance.vault]
  zone_id = var.route53_zone_id
  name    = "${var.hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [ aws_instance.vault.private_ip ]

}

output "user_data" {
  value = base64encode("{\"ignition\":{\"config\":{\"replace\":{\"source\":\"s3://${var.bucket_name}/${aws_s3_object.ignition_file.key}\"}},\"version\":\"3.4.0\"}}")
}


