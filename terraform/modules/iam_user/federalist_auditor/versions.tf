# No longer used - McGowan - 11/6/23 
# remove this and the whole module folder
terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0.0"
    }
  }
}
