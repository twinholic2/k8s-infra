variable "key_name" {
    default = "my_key_osh"
    type = string
}

variable "k8s_version" {
    default = "1.28"
}

variable "hooks" {
  # Initital lifecycle hook for the autoscaling group.
  default = {
    name                 = "k8s-term-hook"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
    heartbeat_timeout    = 30
    default_result       = "CONTINUE"
  }
}

variable "pre_userdata" {
  # userdata to pre-append to the default userdata.
  default = ""
}

variable "additional_userdata" {
#   default = <<EOT
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install
# EOT
  default = ""
  type = string
}

variable "workergroup" {
  default = "kuber"
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key Id"
  type    = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type    = string
}