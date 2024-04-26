variable "cluster_name" {
    default = "kuber-demo"
    type = string
} 
variable "cluster_version" {
    default = "1.28"
    type = string
}

variable "env" {
  default = "prod"
  type = string
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key Id"
  type    = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type    = string
}