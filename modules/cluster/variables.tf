variable "cluster_name" {
    default = ""
    type = string
}

variable "cluster_version" {
    description = "Kubernetes version to use for the EKS cluster."
    default = "1.28"
    type = string
}

variable "vpc_id" {
  default=""
  type = string
  
}

variable "env" {
  default = ""
  type = string
}

variable "tags" {
    default = {}
    type = map(string)
}

variable "subnets" {
    description = "A list of subnets to place the EKS cluster and workers within."
    default = []
    type = list(string)
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

