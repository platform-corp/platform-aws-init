
locals {

    # ignition_disks = [
    #     {
    #         device     = "/dev/vdb"
    #         wipe_table = false
    #         partitions = [
    #             {
    #                 label   = "var"
    #                 sizemib = 10240
    #             },
    #             {
    #                 label   = "share"
    #                 sizemib = 10240
    #             }
    #         ]
    #     }
    # ]
    #
    # ignition_filesystems = [
    #     {
    #         device          = "/dev/disk/by-partlabel/var"
    #         format          = "xfs"
    #         label           = "var"
    #         path            = "/var"
    #         with_mount_unit = true
    #     },
    #     {
    #         device          = "/dev/disk/by-partlabel/share"
    #         format          = "xfs"
    #         label           = "share"
    #         path            = "/var/usrlocal/share"
    #         with_mount_unit = true
    #     }
    # ]

    ignition_directories = [
        {
            path = "/usr/local/etc/vault"
            uid = 100
            gid = 0
        },
        {
            path = "/usr/local/etc/vault/tls"
            uid = 100
            gid = 0
        },
        {
            path = "/usr/local/share/vault-data"
            uid = 100
        },
        {
            path = "/usr/local/etc/smallstep"
            uid = 100
        }
    ]

 #
    # ignition_files_map = { for hostname in var.hostnames : hostname => concat([
    #     {
    #         path      = "/etc/hostname"
    #         overwrite = true
    #         content   = {
    #             mime    = "text/plain"
    #             content = "${hostname}\n"
    #         }
    #     },
    #     {
    #         path = "/usr/local/etc/vault/vault-config.hcl"
    #         overwrite = true
    #         content   = {
    #             mime    = "text/plain"
    #             content = templatefile("${path.root}/templates/vault-config.hcl.tftpl", {
    #                 hostname      = hostname,
    #                 cluster_name  = var.vault_cluster_name,
    #                 hostnames     = var.hostnames
    #             })
    #         }
    #     } ], local.additional_ignition_files)
    # }

    # additional_ignition_files = [
    #     {
    #         path       = "/etc/pki/ca-trust/source/anchors/${var.ca_cert_file}"
    #         overwrite = true
    #         content = {
    #             mime    = "text/plain"
    #             content = file("${path.root}/files/${var.ca_cert_file}")
    #         }
    #     }, 
    # ]

    ignition_files = [
        {
            path = "/etc/hostname"
            overwrite = true
            content = {
                mime = "text/plain"
                content = "${var.hostname}\n"
            }
        },
        {
            path = "/usr/local/etc/vault/vault-config.hcl"
            overwrite = true
            content   = {
                mime    = "text/plain"
                content = templatefile("${path.module}/files/vault-config.hcl.tftpl", {
                    hostname      = var.hostname,
                    domain_name   = var.domain_name,
                    cluster_name  = var.vault_cluster_name,
                    hostnames     = [ ],
                    aws_region    = var.region,
                    kms_key       = aws_kms_key.vault_auto_unseal_key.id
                    access_key    = aws_iam_access_key.vault_user_key.id
                    secret_key    = aws_iam_access_key.vault_user_key.secret
                })
            }
        },
        {
            path = "/etc/environment"
            overwrite = true
            content = {
                mime = "text/plain"
                content = templatefile("${path.module}/files/proxy.conf.tftpl",
                    {
                        proxy   = var.proxy == "" ? "http://proxy.${var.domain_name}:3128" : var.proxy
                        no_proxy = var.no_proxy == "" ? "localhost,127.0.0.1,${var.domain_name},amazonaws.com" : var.no_proxy
                    })
            }
        },
        {
            path = "/etc/proxy.conf"
            overwrite = true
            content = {
                mime = "text/plain"
                content = templatefile("${path.module}/files/proxy.conf.tftpl",
                    {
                        proxy   = var.proxy == "" ? "http://proxy.${var.domain_name}:3128" : var.proxy
                        no_proxy = var.no_proxy == "" ? "localhost,127.0.0.1,${var.domain_name},amazonaws.com" : var.no_proxy
                    })
            }
        },
        {
            path = "/etc/containers/systemd/vault.container"
            overwrite = true
            content = {
                mime    = "text/plain"
                content = templatefile("${path.module}/files/vault.container.tftpl",
                    {
                        proxy   = var.proxy == "" ? "http://proxy.${var.domain_name}:3128" : var.proxy
                        cert_subject = var.cert_subject == "" ? "/C=EU/ST=State/L=City/O=Organization/OU=Department/CN=${var.hostname}.${var.domain_name}" : var.cert_subject
                    })
            }
        }
    ]

    ignition_systemd_units = [
        {
            name = "podman.socket"
            enabled = true
            dropin = [
                {
                    name    = "10-podman-socket.conf"
                    content = "[Socket]\nSocketMode=0660\nSocketGroup=podman\n"
                }
            ]
        },
        {
            name = "vault.timer"
            content = "[Timer]\nOnBootSec=5min\n"
        },
        {
            name = "rpm-ostreed.service"
            dropin = [
                {
                    name = "99-proxy.conf"
                    content = "[Service]\nEnvironmentFile=/etc/proxy.conf\n"
                }
            ]
        },
        {
            name = "zincati.service"
            dropin = [
                {
                    name = "99-proxy.conf"
                    content = "[Service]\nEnvironmentFile=/etc/proxy.conf\n"
                }
            ]
        },
        {
            name = "rpm-ostree-countme.service"
            dropin = [
                {
                    name = "99-proxy.conf"
                    content = "[Service]\nEnvironmentFile=/etc/proxy.conf\n"
                }
            ]
        },
        {
            name = "docker.service"
            enabled = false
        },
        {
            name = "systemd-timesyncd.service"
            enabled = true
        }
    ]

    ignition_groups = [
        {
            name = "podman"
            gid  = 500
        }
    ]

    ignition_users = [
        {
            name = "core"
        },
        {
            name = "vault"
            uid = 100
            no_create_home = false
            shell = "/usr/sbin/nologin"
            groups = [ "podman" ]
        }
    ]
}