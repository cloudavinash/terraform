variable "vpc_cidr" {
  type = string
  default = ""
}
variable "subset_public_cidr" {
  type = list
  default = [""]
}
variable "subset_private_cidr" {
    type = list
  default = [""]
}
variable "subset_database_cidr" {
    type = list
  default = [""]
}
variable "subnet_public_id" {
    type = list
  default = [""] 
}
variable "ec2_Bastion" {
  type = string
    default = ""
}
variable "subnet_private_id" {
    type = list
  default = [""] 
}