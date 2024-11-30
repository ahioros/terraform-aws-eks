# tls
data "tls_certificate" "cert-eks" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

data "local_file" "config_file" {
  filename = var.config_key
}

data "aws_eks_cluster_auth" "eks-cluster-auth" {
  name = aws_eks_cluster.eks-cluster.name
}

data "aws_eks_cluster" "eks-cluster" {
  name = aws_eks_cluster.eks-cluster.name
}

data "template_file" "kubeconfig" {
  template = file("./template/kubeconfig.tpl")
  vars = {
    cluster_name     = local.config.eks.name
    cluster_endpoint = data.aws_eks_cluster.eks-cluster.endpoint
    #    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks-cluster.certificate_authority[0].data)
    cluster_ca_certificate = data.aws_eks_cluster.eks-cluster.certificate_authority[0].data
    access_token           = data.aws_eks_cluster_auth.eks-cluster-auth.token
  }

}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "./template/kubeconfig.yaml"
}
