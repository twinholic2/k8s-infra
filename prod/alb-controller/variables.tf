variable "name" {
    default = "alb-controller"
}

variable "namespace" {
    default = "kube-system"
    type = string
}

variable "sa_name" {
    default = "aws-load-balancer-controller"
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key Id"
  type    = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type    = string
}