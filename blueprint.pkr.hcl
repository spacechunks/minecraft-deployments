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

variable "s3_access_key" {
  type = string
  default = env("BUILD_S3_ACCESS_KEY")
}

variable "s3_secret_key" {
  type = string
  default = env("BUILD_S3_SECRET_KEY")
}

variable "s3_endpoint" {
  type = string
  default = env("BUILD_S3_ENDPOINT")
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

variable "name" {
  type = string
}

variable "version" {
  type = string
}

source "docker" "paper" {
  image = "ghcr.io/spacechunks/paper-docker:${var.paper_version}"
  commit = "true"
  run_command = ["-d", "-i", "-t", "{{.Image}}"]
}

build {
  sources = [
    "source.docker.paper"
  ]

  // move symlinks before uploading files
  // because docker builder cant handle those
  provisioner "shell-local" {
    inline = [
      "mv blueprint.pkr.hcl /tmp/blueprint.hcl"
    ]
  }

  provisioner "file" {
    destination = "/opt/paper"
    source = "."
  }

  dynamic "provisioner" {
    for_each = var.files
    labels = ["s3"]
    content {
      access_key = var.s3_access_key
      secret_key = var.s3_secret_key
      endpoint = var.s3_endpoint
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

  provisioner "shell" {
    inline = [
      "echo 'Starting .tgz extraction process'",
      "find /opt/paper -name '*.tgz' -print0 | while IFS= read -r -d '' file; do",
      "  echo \"Extracting $file\"",
      "  tar -xzvf \"$file\" -C /opt/paper",
      "  rm \"$file\"",
      "  echo \"Extracted and removed $file\"",
      "done",
      "echo 'Extraction process completed'"
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
