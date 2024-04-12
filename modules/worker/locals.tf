locals {
  worker_group_default = {
    pre_userdata = "",
    additional_userdata ="",
    bootstrap_extra_args = ""
  }
  cluster_name = var.cluster_name

  asg_tags = concat([
        {
        key                 = "Name"
        value               = "${var.cluster_name}"
        propagate_at_launch = true
        },
        {
        key                 = "kubernetes.io/cluster/${var.cluster_name}"
        value               = "owned"
        propagate_at_launch = true
        }
        # {
        # key                 = "k8s.io/cluster/${var.cluster_name}"
        # value               = "owned"
        # propagate_at_launch = true
        # }
    ])
}