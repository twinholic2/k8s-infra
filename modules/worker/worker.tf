# ####################################################################################
# EKS Nodegrouup IAM Role
# 노드가 아래 권한이 있어야 노드로써 역할을 할수 있는것이다. 그러기위해 aws_auth 또한 필요함.
# ####################################################################################
resource "aws_iam_role" "worker-role" {
  name               = "${var.cluster_name}-${var.name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.worker-assume-role-doc.json
  tags               = var.tags
  force_detach_policies = true

}

resource "aws_iam_role_policy_attachment" "worker-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "worker-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "worker-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.worker-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 나중을 위해 추가로 worker 노드에 s3등 policy추가가 필요한 경우를 위해 만든다.module호출시 입력해주면 됨.
resource "aws_iam_role_policy_attachment" "worker_additional_policies" {
  count      = var.manage_worker_iam_resources ? length(var.worker_additional_policies) : 0
  role       = aws_iam_role.worker-role.name
  policy_arn = var.worker_additional_policies[count.index]
}

# resource "aws_iam_policy" "describe_instances_policy" {
#   name        = "DescribeInstancesPolicy"
#   description = "Allows describing EC2 instances"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = "ec2:DescribeInstances",
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "describe_instances_policy_attachment" {
#   role       =  aws_iam_role.worker-role.name
#   policy_arn = aws_iam_policy.describe_instances_policy.arn
# }


# EKS Worker 노드 Launch Configuration에 들어갈 IAM Role profile
resource "aws_iam_instance_profile" "worker" {
	name = "${var.cluster_name}-${var.name}-profile"
	role = aws_iam_role.worker-role.name
}

######################################
# EKS Worker 노드 Launch Configuration
######################################
resource "aws_launch_configuration" "worker" {
  name_prefix                 = var.cluster_name
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.worker.name
  #security_groups             = [data.terraform_remote_state.infra.outputs.worker_security_group_id]
  security_groups             = [var.worker_security_group_id]
#   user_data_base64            = base64encode(local.eks_worker_userdata)
  user_data_base64            = base64encode(data.template_file.userdata.rendered)
  key_name                    = var.key_name
  # associate_public_ip_address = true

  root_block_device {
    encrypted             = var.root_encrypted 
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    iops                  = var.root_iops
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#################################
# EKS Worker 노드 AutoScaling 설정
#################################
resource "aws_autoscaling_group" "worker" {
  name                 = "${var.cluster_name}-asg"
  launch_configuration = aws_launch_configuration.worker.name
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity
  vpc_zone_identifier  = var.subnets

  #아래 optianl항목을 필요여부에 따라 판단해서 정리해라.
  force_delete              = var.asg_force_delete
  target_group_arns         = var.target_group_arns
  protect_from_scale_in     = var.protect_from_scale_in
  suspended_processes       = var.suspended_processes
  enabled_metrics           = var.enabled_metrics
  placement_group           = var.placement_group
  termination_policies      = var.termination_policies
  max_instance_lifetime     = var.max_instance_lifetime
  default_cooldown          = var.default_cooldown
  health_check_grace_period = var.health_check_grace_period

  

  # (Optional) 스케일링 정책, 보안 그룹, 태그 등의 추가 설정 가능
     dynamic "tag" {
        for_each = local.asg_tags
        content {
        key                 = tag.value.key
        value               = tag.value.value
        propagate_at_launch = tag.value.propagate_at_launch
        }
    }

    # 환경별로 추가 설정(aws_terminiation_handler, 비용관련추척)
    dynamic "tag" {
      for_each = var.extra_tags
      content {
        key                 = tag.value.key
        value               = tag.value.value
        propagate_at_launch = tag.value.propagate_at_launch
      }
    }

    # autoscaling group시작할때만 작동. 그외에는 모두 아래 aws_autoscaling_lifecycle_hook 사용한다.
    # 따라서 밑에 이런 코드예시를 보여주고 worker_create_initial_lifecycle_hooks = false로 처리하겠다.
    dynamic "initial_lifecycle_hook" {
        for_each = var.worker_create_initial_lifecycle_hooks ? var.asg_initial_lifecycle_hooks : []
        content {
        name                    = initial_lifecycle_hook.value["name"]
        lifecycle_transition    = initial_lifecycle_hook.value["lifecycle_transition"]
        notification_metadata   = lookup(initial_lifecycle_hook.value, "notification_metadata", null)
        heartbeat_timeout       = lookup(initial_lifecycle_hook.value, "heartbeat_timeout", null)
        notification_target_arn = lookup(initial_lifecycle_hook.value, "notification_target_arn", null)
        role_arn                = lookup(initial_lifecycle_hook.value, "role_arn", null)
        default_result          = lookup(initial_lifecycle_hook.value, "default_result", null)
        }
    }


    lifecycle {
        create_before_destroy = true
        #해당 변경사항을 무시하고 관리하지 않는다. 의도하지 않는 리소스 다시생성, 인프라변경 방지.desired_capacity는 언제든 변경할수있기에
        ignore_changes        = [desired_capacity]
    }
  
}

resource "aws_autoscaling_lifecycle_hook" "hook" {
  count             = var.create_lifecycle_hooks ? 1 : 0

  name                   = lookup(var.lifecycle_hooks, "name", null)
  autoscaling_group_name = aws_autoscaling_group.worker.name
  default_result         = lookup(var.lifecycle_hooks, "default_result", null)
  heartbeat_timeout      = lookup(var.lifecycle_hooks, "heartbeat_timeout", 30)
  lifecycle_transition   = lookup(var.lifecycle_hooks, "lifecycle_transition", null)
}