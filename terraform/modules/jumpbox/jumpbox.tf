resource "aws_instance" "jumpbox" {
  ami                                  = var.ami
  iam_instance_profile                 = var.iam_instance_profile
  instance_type                        = var.instance_type
  key_name                             = var.stack_description
  subnet_id                            = var.subnet_id 
  vpc_security_group_ids               = var.vpc_security_group_ids 
  private_ip                           = var.private_ip
  associate_public_ip_address          = "false"
  get_password_data                    = "false"
  hibernation                          = "false"
  instance_initiated_shutdown_behavior = "stop"
  ipv6_address_count                   = "0"
  monitoring                           = "false"
  source_dest_check                    = "true"
  tenancy                              = "default"

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp2"
    delete_on_termination = "true"
    encrypted             = "false"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  enclave_options {
    enabled = "false"
  }
  
  tags        = { 
    "Name" = "jumpbox" 
  }
}



  

## TODO: Probably worth locking down the jumpbox if it is going to be around for any length of time

#resource "aws_ssm_document" "session_manager_prefs" {
#  name            = var.ssm_document_name 
#  document_type   = "Session"
#  document_format = "JSON"
#
#  content = jsonencode({
#    schemaVersion = "1.0"
#    description   = "Document to hold regional settings for Session Manager"
#    sessionType   = "Standard_Stream"
#    inputs = {
#      kmsKeyId                    = var.kms_key_id
#      s3BucketName                = var.s3_bucket_name
#      s3KeyPrefix                 = var.s3_key_prefix
#      s3EncryptionEnabled         = var.s3_encryption_enabled
#      cloudWatchLogGroupName      = var.cloudwatch_log_group_name
#      cloudWatchEncryptionEnabled = var.cloudwatch_encryption_enabled
#      cloudWatchStreamingEnabled  = var.cloudwatch_streaming_enabled
#      idleSessionTimeout          = var.idle_session_timeout
#      maxSessionDuration          = var.max_session_duration
#      runAsEnabled                = var.run_as_enabled
#      shellProfile = {
#        linux   = var.linux_shell_profile
#        windows = var.windows_shell_profile
#      }
#    }
#  })
#}

#resource "aws_ssm_association" "example" {
#  name = aws_ssm_document.example.name
#
#  targets {
#    key    = "InstanceIds"
#    values = [aws_instance.example.id]
#  }
#}