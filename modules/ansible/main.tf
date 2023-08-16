terraform {
  required_providers {
  }
}

locals {
  inventory = {
    webservers = {
        hosts = {
            for i in range(length(var.urls)):
                format("webserver%d", i) => {
                        "ansible_host" = var.urls[i]
                }
        },
        vars  = {
            ansible_user = var.ansible_user
        }
      }
  }
}

resource "local_file" "inventory" {
  content  = "${yamlencode(local.inventory)}"
  filename = "${path.module}/inventory.yaml"
}

resource "null_resource" "run_ansible" {
    count      = length(var.urls) > 0 ? 1 : 0
    depends_on = [local_file.inventory]
    provisioner "local-exec" {
        command = "ansible-playbook -i ${path.module}/inventory.yaml ${path.module}/playbook.yaml"
  }
}