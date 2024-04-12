variable "name" {
    default = "external-dns"
}

variable "namespace" {
    default = "kube-system"
}

variable "sa_name" {
    default = "external-dns"
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key Id"
  type    = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type    = string
}