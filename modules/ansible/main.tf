# THE ANSIBLE PROVIDER HAD COMPATIBILITY ISSUES SO I USE LOCAL EXEC INSTEAD
# THIS IS A TERRIBLE APPOROACH AND SHOULD NOT BE USED IN PRODUCTION ENV

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
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/inventory.yaml ${path.module}/playbook.yaml"
  }
}