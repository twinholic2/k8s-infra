variable "cluster_name" {
    default = ""
    type = string
}

variable "name" {
    default = ""
    type = string
}

variable "cluster_version" {
    default = "1.28"
    type=string
}

variable "image_id" {
    default = "ami-07cc8400108193157"
    type = string
}

variable "instance_type" {
    default = "t3.medium"
    type = string
}

variable "worker_create_security_group" {
    default = false
  
}

variable "subnets" {
    description = "A list of subnets to place the EKS cluster and workers within."
    default = []
    type = list(string)
}

variable "cluster_certificate" {
  type = string
  default = ""
}

variable "endpoint" {
  type = string
  default = ""
}

variable "asg_force_delete" {
    # Enable/Disable forced deletion for the autoscaling group without waiting all instance deletion.
    default = false
}

variable "target_group_arns" {
  # A list of Application LoadBalancer (ALB) target group ARNs to be associated to the autoscaling group
  default = null
}

variable "protect_from_scale_in" {
  # Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible.
  default = false
}
variable "iam_instance_profile_name" {
  # A custom IAM instance profile name. Used when manage_worker_iam_resources is set to false. Incompatible with iam_role_id.
  default = ""
}
variable "iam_role_id" {
  # A custom IAM role id. Incompatible with iam_instance_profile_name.  Literal local.default_iam_role_id will never be used but if iam_role_id is not set, the local.default_iam_role_id interpolation will be used.
  default = ""
}
variable "suspended_processes" {
  # A list of processes to suspend. i.e. ["AZRebalance", "HealthCheck", "ReplaceUnhealthy"]
  default = ["AZRebalance"]
}

variable "placement_group" {
  # The name of the placement group into which to launch the instances, if any.
  default = ""
}

variable "termination_policies" {
  # A list of policies to decide how the instances in the auto scale group should be terminated.
  default = []
}

variable "max_instance_lifetime" {
  default = 0
}

variable "default_cooldown" {
  # The amount of time, in seconds, after a scaling activity completes before another scaling activity can start.
  default = null
}

variable "health_check_grace_period" {
  # Time in seconds after instance comes into service before checking health.
  default = null
}

variable "enabled_metrics" {
  # A list of metrics to be collected i.e. ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity"]
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "pre_userdata" {
  type = string
  default = ""
}

variable "additional_userdata" {
    type = string
    default = ""
}

variable "bootstrap_extra_args" {
    type = string
    default = ""
}

variable "container_runtime_prefix" {
    type = string
    default = " --container-runtime"
}

variable container_runtime {
    type = string
    default = "containerd"
}

variable "kubelet_extra_prefix" {
    type = string
    default = " --node-labels"
  
}

variable "kubelet_extra_args" {
  type    = list(string)
  default = []
}
variable "key_name" {
  # The key name that should be used for the instances in the autoscaling group
  default = ""
}

variable "root_encrypted" {
    default = false
    type = bool
}

variable "root_volume_size" {
  # root volume size of worker instances.
  default = "20"
}
variable "root_volume_type" {
  # root volume type of worker instances, can be 'standard', 'gp2', or 'io1'
  default = "gp2"
}
variable "root_iops" {
  # The amount of provisioned IOPS. This must be set with a volume_type of "io1".
  default = "0"
}

variable "manage_worker_iam_resources" {
  description = "Whether to let the module manage worker IAM resources. If set to false, iam_instance_profile_name must be specified for worker."
  type        = bool
  default     = true
}

variable "worker_additional_policies" {
  description = "Additional policies to be added to worker"
  type        = list(string)
  default     = []
}

variable "asg_desired_capacity" {
  # Desired worker capacity in the autoscaling group and changing its value will not affect the autoscaling group's desired capacity because the cluster-autoscaler manages up and down scaling of the nodes. Cluster-autoscaler add nodes when pods are in pending state and remove the nodes when they are not required by modifying the desirec_capacity of the autoscaling group. Although an issue exists in which if the value of the asg_min_size is changed it modifies the value of asg_desired_capacity.
  default = "1"
}
variable "asg_max_size" {
  # Maximum worker capacity in the autoscaling group.
  default = "3"
}
variable "asg_min_size" {
  # Minimum worker capacity in the autoscaling group. NOTE: Change in this paramater will affect the asg_desired_capacity, like changing its value to 2 will change asg_desired_capacity value to 2 but bringing back it to 1 will not affect the asg_desired_capacity.
  default = "1"
}

# variable "asg_tags" {
#   default = [
#     {
#     key                 = "Name"
#     value               = "${local.cluster_name}"
#     propagate_at_launch = true
#     },
#     {
#     key                 = "kubernetes.io/cluster/${local.cluster_name}"
#     value               = "owned"
#     propagate_at_launch = true
#     },
#     {
#     key                 = "k8s.io/cluster/${local.cluster_name}"
#     value               = "owned"
#     propagate_at_launch = true
#     }
#   ]
#   type = list(map)
# }

variable "extra_tags" {
    type = list(object({
      key = string
      value = string
      propagate_at_launch = string
    }))
    default = []
}

variable "worker_create_initial_lifecycle_hooks" {
  default = false
}

variable "asg_initial_lifecycle_hooks" {
    default = []
  
}

variable "create_lifecycle_hooks" {
    default = false
    type = bool
}

variable "lifecycle_hooks" {
    default = []
  
}

variable "worker_security_group_id" {
    default = ""
    type = string
  
}