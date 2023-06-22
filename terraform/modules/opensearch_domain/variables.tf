variable "instance_type" {
  
}
variable "engine" {
  type = string
  default = "Opensearch_2.5"
}
variable "domain_name" {
  
}
variable "master_user_name" {
  
}
variable "master_user_password" {
  
}
variable "private_elb_subnets" {
  type = list(string)
}
