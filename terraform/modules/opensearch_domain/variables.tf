variable "instance_type" {
  
}
variable "engine" {
  type = string
  default = "Opensearch_2.5"
}
variable "domain" {
  
}
variable "private_elb_subnets" {
  type = list(string)
}
