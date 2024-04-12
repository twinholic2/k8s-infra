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
}
