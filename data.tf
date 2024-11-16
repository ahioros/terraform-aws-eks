# tls
data "tls_certificate" "cert-eks" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

data "local_file" "config_file" {
  filename = var.config_key
}
