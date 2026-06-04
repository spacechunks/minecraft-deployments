packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source = "github.com/hashicorp/docker"
    }
    s3 = {
      version = "2.0.11"
      source = "github.com/spacechunks/s3"
    }
  }
}

variable "oci_reg_user" {
  type = string
  default = env("BUILD_OCI_REG_USER")
}

variable "oci_reg_pass" {
  type = string
  default = env("BUILD_OCI_REG_PASS")
}

variable "paper_version" {
  type = string
  default = env("BUILD_PAPER_VERSION")
}

variable "files" {
  type = list(object({
    source = string
    destination = string
  }))
}

variable "secrets" {
  type = map(string)
  default = {}
}

variable "name" {
  type = string
}

variable "version" {
  type = string
}

// disable arm64 builds temporarily (tm) unitl we
// figured out why it doesn't work in the ci
//
//source "docker" "arm64" {
//  image = "ghcr.io/spacechunks/paper-docker:${var.paper_version}"
//  commit = "true"
//  platform = "linux/arm64"
//  run_command = ["-d", "-i", "-t", "{{.Image}}"]
//}

source "docker" "amd64" {
  image = "ghcr.io/spacechunks/paper-docker:${var.paper_version}"
  commit = "true"
  platform = "linux/amd64"
  run_command = ["-d", "-i", "-t", "{{.Image}}"]
}

locals {
  rendered_files = {
    for f in fileset(path.cwd, "**/*.tpl") :
      # path.root would be paper/lobby/config/blabla, but we need to cut out the "paper/lobby" part
      # of the string, so we are left with the relative path from the servers root directory.
      f => templatefile("${path.cwd}/${f}", var.secrets)
  }
}

build {
  sources = [
   // "source.docker.arm64",
    "source.docker.amd64"
  ]

  provisioner "file" {
    destination = "/opt/paper"
    source = "."
  }

  dynamic "provisioner" {
    for_each = local.rendered_files
    labels   = ["file"]
    content {
      content     = provisioner.value
      destination = "/opt/paper/${trimsuffix(provisioner.key, ".tpl")}"
    }
  }

  provisioner "shell" {
    inline = ["find /opt/paper \\( -name '*.tpl' -or -name '*.pkrvars.json' -or -name '*.sops.json' \\) -delete"]
  }

  provisioner "shell-local" {
    inline = ["find . -name secrets.pkrvars.json -delete"]
  }

  dynamic "provisioner" {
    for_each = var.files
    labels = ["s3"]
    content {
      objects {
        source = provisioner.value.source
        destination = provisioner.value.destination
      }
    }
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "ghcr.io/spacechunks/blueprints/${var.name}"
      tags = ["${var.version}"]
    }

    post-processor "docker-push" {
      login_username = var.oci_reg_user
      login_password = var.oci_reg_pass
      login_server = "ghcr.io"
      login = true
    }
  }
}
