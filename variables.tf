variable "config_key" {
  type = string
  description = "Config File"
}

variable "eks-cluster-name" {
  type = string
  description = "EKS Cluster Name"
  default = "eks-cluster-default"
}
