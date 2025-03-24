packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source = "github.com/hashicorp/docker"
    }
    s3 = {
      version = "2.0.2"
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

variable "velocity_version" {
  type = string
  default = env("BUILD_VELOCITY_VERSION")
}

variable "files" {
  type = list(object({
    source = string
    destination = string
  }))
}

variable "name" {
  type = string
}

variable "version" {
  type = string
}

source "docker" "velocity" {
  image = "ghcr.io/spacechunks/velocity-docker:${var.velocity_version}"
  commit = "true"
  // specify, because the default command will override our entrypoint
  run_command = ["-d", "-i", "-t", "{{.Image}}"]
}

build {
  sources = [
    "source.docker.velocity"
  ]

  // move symlinks before uploading files
  // because docker builder cant handle those
  provisioner "shell-local" {
    inline = [
      "mv blueprint.pkr.hcl /tmp/blueprint.hcl"
    ]
  }

  provisioner "file" {
    destination = "/opt/velocity"
    source = "."
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

  // restore prevoius state
  provisioner "shell-local" {
    inline = [
      "mv /tmp/blueprint.hcl blueprint.pkr.hcl"
    ]
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
