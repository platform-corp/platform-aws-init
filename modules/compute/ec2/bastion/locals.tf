
locals {

    # ignition_disks = [
    #     {
    #         device     = "/dev/xvdb"
    #         wipe_table = false
    #         partitions = [
    #             {
    #                 label   = "var"
    #                 sizemib = 4500
    #             },
    #             {
    #                 label   = "share"
    #                 sizemib = 4500
    #             }
    #         ]
    #     }
    # ]

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
            path = "/var/share/squid"
        },
        {
            path = "/var/share/squid/config"
        },
        {
            path = "/var/share/squid/cache"
            uid  = 13
            gid  = 13
        },
        {
            path = "/var/share/squid/logs"
            uid  = 13
            gid  = 13
        }
    ]

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
            path = "/var/share/squid/config/squid.conf"
            overwrite = true
            content = {
                mime = "text/plain"
                content = file("${path.module}/files/squid.conf")
            }
        },
        {
            path = "/etc/containers/systemd/squid.container"
            overwrite = true
            content = {
                mime    = "text/plain"
                content = file("${path.module}/files/squid.container")
            }
        }
        # {
        #     path = "/usr/local/bin/podman_login.sh"
        #     mode = 493
        #     overwrite = true
        #     content = {
        #         mime    = "text/x-shellscript"
        #         content = file("${path.module}/files/podman_login.sh")
        #     }
        # }
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
            name = "systemd-timesyncd.service"
            enabled = true
        }
    ]

    ignition_users = [
        {
            name = "core"
        }
    ]

    ignition_groups = [
        {
            name = "podman"
            gid  = 500
        }
    ]

}