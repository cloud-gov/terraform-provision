variable "ami" {
    description = "AMI to use, example below is Ubuntu 22.04"
    default = "ami-0a85594fe0f52def5"
}


variable "instance_type" {
    description = "EC2 Instance Type to create the VM as"
    default = "m5.large"
}


variable "private_ip" {
    description = "Internal IP address of EC2 vm"
    default     = ""
}

variable "root_volume_size" {
    description = "Size in GB of root disk"
    default = 20
}

variable "subnet_id" {
    description = "Subnet ID (string) to place the EC2 vm into"
    default = ""  #module.stack.private_subnet_ids[0]
}

variable "vpc_security_group_ids" {
    description = "List of Security Groups to add to the EC2 instance"
    default = [] #[module.stack.bosh_security_group]
}


variable "iam_instance_profile" {
    description = "IAM Instance profile to be embedded into the EC2 instance, must exist and is used for Session Manager"
    default = "bootstrap"
}

variable "stack_description" {
  default = "westa-hub"
}


variable "private_ip_offset" {
    default = 1
}
