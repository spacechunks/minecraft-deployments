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
  type = list(string)
  default = []
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

build {
  sources = [
   // "source.docker.arm64",
    "source.docker.amd64"
  ]

  dynamic "provisioner" {
    for_each = var.secrets
    labels = ["shell-local"]
    content {
      script = "../../../scripts/sops-decrypt.sh"
      env = {
        "ENCRYPTED_FILE": provisioner.value
      }
    }
  }

  provisioner "file" {
    destination = "/opt/paper"
    source = "."
  }

  dynamic "provisioner" {
    for_each = var.secrets
    labels = ["shell-local"]
    content {
      script = "../../../scripts/sops-encrypt.sh"
      env = {
        "ENCRYPTED_FILE": provisioner.value
      }
    }
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
  //provisioner "shell-local" {
  //  inline = [
  //    "mv /tmp/blueprint.hcl blueprint.pkr.hcl"
  //  ]
  //}

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
