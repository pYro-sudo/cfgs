packer {
  required_plugins {
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "ubuntu-vm"
}

source "vmware-iso" "ubuntu" {
  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
  iso_checksum     = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  guest_os_type    = "ubuntu-64"
  disk_size        = 20000
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "5m"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  boot_wait        = "10s"
  boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz quiet autoinstall ds=nocloud-net\\;s=/cdrom/nocloud/ ---<enter>",
    "initrd /casper/initrd<enter>",
    "boot<enter>"
  ]
  http_directory   = "http"
  vmware_os_type   = "ubuntu-64"
  vmx_data = {
    "memsize" = "2048"
    "numvcpus" = "2"
  }
  vmx_remove_ethernet_interfaces = true
}

build {
  sources = ["source.vmware-iso.ubuntu"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -E -S bash '{{.Path}}'"
    scripts = [
      "scripts/base.sh",
      "scripts/vagrant.sh",
      "scripts/cleanup.sh"
    ]
  }

  post-processor "vagrant" {
    output = "builds/${var.vm_name}.box"
    provider_override = "vmware_desktop"
  }
}
