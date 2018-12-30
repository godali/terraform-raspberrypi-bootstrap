# Raspberry Pi Terraform Bootstrap Provisioner (Tested with Raspbian Stretch).
# This is a run-once bootstrap Terraform provisioner for a Raspberry Pi.
# Provisioners by default run only at resource creation, additional runs without cleanup may introduce problems.
# https://www.terraform.io/docs/provisioners/index.html

resource "null_resource" "raspberry_pi_bootstrap" {
  count = 3
  connection {
    type = "ssh"
    user = "${var.username}"
    password = "${var.password}"
    host = "${lookup(var.instance_ips, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo hostname",
      # SET HOSTNAME
      "sudo hostnamectl set-hostname ${lookup(var.host_names, count.index)}",
      "echo '127.0.1.1 ${lookup(var.host_names, count.index)}' | sudo tee -a /etc/hosts",

      # DATE TIME CONFIG
      "sudo timedatectl set-timezone ${var.timezone}",
      "sudo timedatectl set-ntp true",

      # CHANGE DEFAULT PASSWORD
      "echo 'pi:${var.new_password}' | sudo chpasswd",

      # SYSTEM AND PACKAGE UPDATES
      "sudo apt-get update -y",
      "sudo apt-get dist-upgrade -y",

      # INSTALL PROMETHEUS NODE EXPORTER
      # This step optional, comment out this section if not desired
      "sudo apt-get install prometheus-node-exporter -y",
      "sudo systemctl enable prometheus-node-exporter.service",

      # NETWORKING - SET STATIC IP
      "echo 'interface eth0\nstatic ip_address=${lookup(var.static_ips_and_mask, count.index)}\nstatic routers=${var.static_router}\nstatic domain_name_servers=${var.static_dns}' | cat >> /etc/dhcpcd.conf",

      # COPY KUBERNETES PREP SCRIPT
      "curl https://raw.githubusercontent.com/godali/terraform-raspberrypi-bootstrap/master/k8s_prep.sh > /home/pi/k8s_prep.sh",
      "chmod u+x k8s_prep.sh",
      "sudo ./k8s_prep.sh"

      # OPTIMIZE GPU MEMORY
      "echo 'gpu_mem=16' | sudo tee -a /boot/config.txt",

      # REBOOT
      "sudo reboot"
    ]
  }
}
