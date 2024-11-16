# EKS
resource "aws_eks_cluster" "eks-cluster" {
  name     = local.config.eks.name == null ? var.eks-cluster-name : local.config.eks.name
  role_arn = aws_iam_role.eks-iam-role.arn

  version = local.config.eks.version == null ? "1.31" : local.config.eks.version

  vpc_config {
    subnet_ids = [
      aws_subnet.eks-public-subnet-1.id,
      aws_subnet.eks-public-subnet-2.id,
      aws_subnet.eks-private-subnet-1.id,
      aws_subnet.eks-private-subnet-2.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks-iam-role-attachment]
}

# node group
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = local.config.eks.nodegroup_name == null ? "private-nodes" : local.config.eks.nodegroup_name
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.eks-private-subnet-1.id,
    aws_subnet.eks-private-subnet-2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = local.config.eks.instance_type

  scaling_config {
    desired_size = local.config.eks.scaling_desired_size == null ? 1 : local.config.eks.scaling_desired_size
    max_size     = local.config.eks.scaling_max_size == null ? 2 : local.config.eks.scaling_max_size
    min_size     = local.config.eks.scaling_min_size == null ? 1 : local.config.eks.scaling_min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    node = "${aws_eks_cluster.eks-cluster.name}-worker"
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker-nodes-policy,
    aws_iam_role_policy_attachment.nodes-cni-policy,
    aws_iam_role_policy_attachment.nodes-ec2-policy
  ]
}
