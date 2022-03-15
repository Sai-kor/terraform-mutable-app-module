## this null resource do nothing , but we give provisioner , provisioner is one which is going to help you to connect to ec2 instances/linux instances by providing required information.It can connect to the instances and execute the commands
resource "null_resource" "app-deploy" {
  triggers = {
    instance_ids = join(",",aws_spot_instance_request.ec2-spot.*.spot_instance_id) //expects string so here list to string terraform so using join.
  }
  count = length(aws_spot_instance_request.ec2-spot)
  connection {
    type     = "ssh"
    user     = local.username
    password = local.password
    host     = aws_spot_instance_request.ec2-spot.*.private_ip[count.index]
  }
  provisioner "remote-exec" {
    inline = [
      "ansible-pull -U https://github.com/Sai-kor/ansible.git roboshop-pull.yml -e COMPONENT=${var.COMPONENT} -e ENV=${var.ENV} -e APP_VERSION=${var.APP_VERSION} -e  NEXUS_USERNAME=${local.NEXUS_USERNAME} -e  NEXUS_PASSWORD=${local. NEXUS_PASSWORD}"
    ]
  }
}

locals {
   NEXUS_USERNAME=nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["NEXUS_USERNAME"])
  NEXUS_PASSWORD=nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["NEXUS_PASSWORD"])
  username = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["password"]
}