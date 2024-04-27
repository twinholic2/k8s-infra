#######################################
# EKS cluster 설정 
#######################################
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-role.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    ##vpc에 있는 모든 subnets들 모듈이니까 입력받는값으로 설정하면 다음과 같다.
    subnet_ids              = var.subnets
    # endpoint_public_access  = var.cluster_endpoint_public_access
	  # endpoint_private_access = var.cluster_endpoint_private_access
        endpoint_public_access  = true
	  endpoint_private_access = true
    public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_security_group.cluster
  ]
}

#########################
# EKS Security Group 설정
#########################
#EKS Master Cluster Security Group
# resource "aws_security_group" "cluster" {
# 	name = join("-",tolist([var.cluster_name,"cluster"]))
# 	description = "Cluster communication with worker nodes"
# 	vpc_id = var.vpc_id
#     # 아래 코드는 밑에처럼 aws_security_group_rule로 생성해도 된다.
# 	# egress {
# 	# 	from_port = 0
# 	# 	to_port = 0
# 	# 	protocol = "-1"
# 	# 	cidr_blocks = ["0.0.0.0/0"]
# 	# }

#      tags = merge (
#         {
#             "Name" = "${var.cluster_name}-cluster"
#         },
#         var.tags
#     )
	
# }
resource "aws_security_group" "cluster" {
	name = join("-",tolist(["eks-cluster-sg",var.cluster_name,var.env]))
	description = "Cluster communication with worker nodes"
	vpc_id = var.vpc_id
    # 아래 코드는 밑에처럼 aws_security_group_rule로 생성해도 된다.
	# egress {
	# 	from_port = 0
	# 	to_port = 0
	# 	protocol = "-1"
	# 	cidr_blocks = ["0.0.0.0/0"]
	# }

     tags = merge (
        {
            "Name" = "eks-cluster-sg-${var.cluster_name}-${var.env}",
            # "aws:eks:cluster-name" = "${var.cluster_name}",
            "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        },
        var.tags
    )
	
}

resource "aws_security_group" "worker" {
  name        = join("-",tolist([var.cluster_name,"worker"]))
  description = "Security group for all nodes in the cluster"
  #vpc_id      = aws_vpc.k8s-vpc.id
  vpc_id      = var.vpc_id

  tags = merge(
    {
        "Name" = format(
            "%s-node",
            var.cluster_name
        )
       "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    var.tags,
  )
}

#worker노드로부터 cluster private access 가능하도록 함
resource "aws_security_group_rule" "worker-to-cluster-private-access" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.worker.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

#위에서 egress 인라인블럭으로 하는걸 이렇게 함
#master cluster에서 외부 인터넷으로 나갈수 있게 설정
resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}


# resource "aws_security_group_rule" "worker_egress_dns" {
#   description       = "Allow cluster egress access to the Internet."
#   protocol          = "-1"
#   security_group_id = aws_security_group.worker.id
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 53
#   to_port           = 53
#   type              = "ingress"
# }

resource "aws_security_group_rule" "worker_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.worker.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}
# resource "aws_security_group_rule" "worker_egress_tcp" {
#   description       = "Allow cluster egress access to the Internet."
#   protocol          = "-1"
#   security_group_id = aws_security_group.worker.id
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 443
#   to_port           = 443
#   type              = "egress"
# }

#master cluster에서 새로 추가된 요구사항
#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group_rule" "cluster_ingress_self" {
  description       = "Allow all ports within itself."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.cluster.id
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

#worker노드끼리 서로 통신가능하도록 함. 0~65535 까지 모든 포트, to_port값을 0으로 해도 됨
resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other"
  protocol                 = "-1"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.worker.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster" {
  description              = "Allow worker pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_ssh" {
  description              = "Allow node to communicate with each other"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  cidr_blocks = ["0.0.0.0/0"]
  from_port                = 22
  to_port                  = 22
  type                     = "ingress"
}

#Master cluster 에서부터 worker노드로 들어올수있또록 허용
resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

# 이유찾기
resource "aws_security_group_rule" "cluster_private_access" {
  protocol    = "tcp"
  security_group_id = aws_security_group.cluster.id
  from_port   = 443
  to_port     = 443
  cidr_blocks =  ["0.0.0.0/0"]
  type        = "ingress"

}

resource "aws_security_group_rule" "worker_ingress_cluster_kubelet" {
  description              = "Allow worker Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}


####################################
# Security for private db subnet a,c  
####################################
resource "aws_security_group" "db" {
  name        = "my-oshyun-db"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    {
        "Name" = format(
            "%s-db",
            "mysql"
        )
    },
    var.tags,
  )
}

#worker노드로부터 cluster private access 가능하도록 함
resource "aws_security_group_rule" "db-private-access" {
  description              = "Connect to mysql db"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.worker.id
  from_port                = 3306
  to_port                  = 3306
  type                     = "ingress"
}


#########################
# EKS IAM Role 설정
#########################
resource "aws_iam_role" "eks-role" {
  name               = var.cluster_name
  assume_role_policy = data.aws_iam_policy_document.eks-assume-role-doc.json
  tags               = var.tags
  force_detach_policies = true
  path                  = "/"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-role.name
}

# optionanl이라 기능에 대해 이해를 하고 쓸지 여부를 생각해라
# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-role.name
}