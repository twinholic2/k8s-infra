provider "helm" {
  kubernetes {
    host                   =  data.terraform_remote_state.cluster.outputs.cluster_endpoint
    cluster_ca_certificate =  base64decode(data.terraform_remote_state.cluster.outputs.cluster_certificate)
    token                  =  data.aws_eks_cluster_auth.cluster.token 
  }
}

provider "kubernetes" {
  host                   =  data.terraform_remote_state.cluster.outputs.cluster_endpoint
  cluster_ca_certificate =  base64decode(data.terraform_remote_state.cluster.outputs.cluster_certificate)
  token                  =  data.aws_eks_cluster_auth.cluster.token 
}

resource "kubernetes_service_account" "alb_service_account" {
  metadata {
    name = var.sa_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb-controller.role_arn
    }
  }

  depends_on = [module.alb-controller]
}

resource "helm_release" "example" {
  name        = var.name
  namespace   = var.namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "v1.7.2"
  create_namespace = true

  set {
    name = "clusterName"
    value = data.terraform_remote_state.cluster.outputs.cluster_name
  }
  set {
    name = "serviceAccount.create"
    value = false
  }

  set {
    name = "serviceAccount.name"
    value = var.sa_name
  }
  depends_on = [ 
    kubernetes_service_account.alb_service_account
   ]
}