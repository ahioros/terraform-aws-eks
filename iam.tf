# IAM role for EKS
resource "aws_iam_role" "eks-iam-role" {
  name = "eks-cluster"
  tags = {
    Name = "EKS-Cluster"
  }

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# EKS Policy Attachement
resource "aws_iam_role_policy_attachment" "eks-iam-role-attachment" {
  role       = aws_iam_role.eks-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# nodes
resource "aws_iam_role" "nodes" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# IAM policy attachment -> nodegroup
resource "aws_iam_role_policy_attachment" "worker-nodes-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-ec2-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# IAM policy for cluster autoscaler
resource "aws_iam_policy" "eks-cluster-autoscaler-policy" {
  name = "eks-cluster-autoscaler-policy"
  policy = jsonencode({
		"Version": "2012-10-17",
    Statement = [{
      "Effect": "Allow",
      # Recommended by cluster autoscaler
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": ["*"]
      # Minimal to avoid autoscaler issues
      #      Action = [
      #  "autoscaling:DescribeAutoScalingGroups",
      #  "autoscaling:DescribeAutoScalingInstances",
      #  "autoscaling:DescribeLaunchConfigurations",
      #  "autoscaling:DescribeScalingActivities",
      #  "autoscaling:SetDesiredCapacity",
      #  "autoscaling:TerminateInstanceInAutoScalingGroup",
      #  "eks:DescribeNodegroup"
      #      ]
    }]
  })
}
