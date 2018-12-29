variable "instance_ips" {
  type = "map"
  default = {
    "0" = "192.168.1.212"
    "1" = "192.168.1.213"
    "2" = "192.168.1.214"
  }
}
variable "username" {}
variable "password" {}

# more than one map variable cannot be declared in terraform.tfvars
variable "host_names" {
  type = "map"
  default = {
    "0" = "abhiz_rasp01"
    "1" = "abhiz_rasp02"
    "2" = "abhiz_rasp03"
  }
}
variable "new_password" {}
variable "timezone" {}
variable "static_ips_and_mask" {
  type = "map"
  default = {
    "0" = "192.168.1.212/24"
    "1" = "192.168.1.213/24"
    "2" = "192.168.1.214/24"
  }
}
variable "static_router" {}
variable "static_dns" {}
