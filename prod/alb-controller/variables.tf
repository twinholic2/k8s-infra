variable "name" {
    default = "alb-controller"
}

variable "namespace" {
    default = "kube-system"
}

variable "sa_name" {
    default = "aws-load-balancer-controller"
}