source "qemu" "gentoo-systemd" {

  iso_url          = "https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230402T170151Z/install-amd64-minimal-20230402T170151Z.iso"
  iso_checksum     = "md5:e02030fd877e73679306341aeb749321"
  output_directory = "output-gentoo-systemd"
  shutdown_command = "shutdown -h now"
  disk_size        = "81920M"
  format           = "qcow2"
  accelerator      = "kvm"
  http_directory   = "resources"
  ssh_username     = "root"
  ssh_password     = "root"
  ssh_timeout      = "20m"
  vm_name          = "gentoo-systemd"
  memory           = 8192
  headless         = true
  cpus             = 8
  disk_interface   = "virtio"
  boot_wait        = "1s"
  boot_steps = [
    ["<enter><wait10>", "Boot menu"],
    ["42<enter><wait30>", "Select UK keyboard"],
    ["passwd<enter><wait1>", "Change password"],
    ["root<enter><wait1>", "Set password"],
    ["root<enter><wait1>", "Confirm password"],
    ["rc-service sshd start<enter>", "Start SSH daemon"]
  ]

}

build {
  sources = ["source.qemu.gentoo-systemd"]

  provisioner "file" {
    source      = "resources/sfdisk-input"
    destination = "/tmp/sfdisk-input"
  }

  provisioner "file" {
    source      = "resources/mirrors.conf"
    destination = "/tmp/mirrors.conf"
  }

  provisioner "file" {
    source      = "resources/install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "file" {
    source      = "resources/fstab"
    destination = "/tmp/fstab"
  }

  provisioner "file" {
    source      = "resources/stage3-amd64-systemd-mergedusr-20230402T170151Z.tar.xz"
    destination = "/tmp/stage3-amd64-systemd-mergedusr-20230402T170151Z.tar.xz"
  }

  provisioner "shell" {
    inline = [

      #"sleep 60000",

      "echo \"root:root\" | chpasswd",

      "sfdisk /dev/vda < /tmp/sfdisk-input",
      "mkfs.vfat -F 32 /dev/vda1",
      "mkswap /dev/vda2",
      "swapon /dev/vda2",
      "mkfs.ext4 /dev/vda3",

      "mount /dev/vda3 /mnt/gentoo",
      "cd /mnt/gentoo",
      #"wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230402T170151Z/stage3-amd64-systemd-mergedusr-20230402T170151Z.tar.xz",
      "mv /tmp/stage3-amd64-systemd-mergedusr-20230402T170151Z.tar.xz .",
      "tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner",
      "cat /tmp/mirrors.conf >> /mnt/gentoo/etc/portage/make.conf",

      "mkdir --parents /mnt/gentoo/etc/portage/repos.conf",
      "cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf",
      "cp --dereference /etc/resolv.conf /mnt/gentoo/etc/",

      "mount --types proc /proc /mnt/gentoo/proc",
      "mount --rbind /sys /mnt/gentoo/sys",
      "mount --make-rslave /mnt/gentoo/sys",
      "mount --rbind /dev /mnt/gentoo/dev",
      "mount --make-rslave /mnt/gentoo/dev",
      "mount --bind /run /mnt/gentoo/run",
      "mount --make-slave /mnt/gentoo/run",

      "mv /tmp/install.sh /mnt/gentoo/.",
      "mv /tmp/fstab /mnt/gentoo/.",

      "chroot /mnt/gentoo /bin/bash /install.sh",

      "rm /mnt/gentoo/stage3-*.tar.*",

      "rm /mnt/gentoo/install.sh /mnt/gentoo/fstab",
      "cd",
      "umount -l /mnt/gentoo/dev{/shm,/pts,}",
      "umount -R /mnt/gentoo"
    ]
  }
}