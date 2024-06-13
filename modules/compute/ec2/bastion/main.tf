variable "module_depends_on" {
  type    = any
  default = []
}


module "ignition_config" {
    depends_on = [ var.module_depends_on ]
    source           = "github.com/platform-corp/tf-ignition-config.git"

    # disks            = local.ignition_disks
    # filesystems      = local.ignition_filesystems
    directories      = local.ignition_directories
    files            = local.ignition_files
    # systemd_units    = local.ignition_systemd_units
    users            = local.ignition_users
}

resource "aws_s3_object" "ignition_file" {
  bucket   = var.bucket_name
  key      = "bastion/ignition.json"
  content  = module.ignition_config.ignition_config

  tags = {
    Name        = "bastion-ignition"
  }
}

resource "aws_instance" "bastion" {
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
    Name = "bastion"
  }
}

resource "aws_route53_record" "bastion_record" {
  depends_on = [aws_instance.bastion]
  zone_id = var.route53_zone_id
  name    = "${var.hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [ aws_instance.bastion.private_ip ]
}

resource "aws_route53_record" "proxy_record" {
  depends_on = [aws_instance.bastion]
  zone_id = var.route53_zone_id
  name    = "proxy.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [ aws_instance.bastion.private_ip ]
}
