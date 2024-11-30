# terraform-eks

Terraform deployments for [EKS](https://aws.amazon.com/eks/) clusters.

## Configuration

Configure the following in the `config.json` file:

## Installation

```bash

    terraform init
    terraform plan
    terraform apply -var="config_key=config.json"
```

## Test kubernetes cluster

```bash
kubectl --kubeconfig ./template/kubeconfig.yaml get nodes
```

## Destroy

```bash
    terraform destroy -var="config_key=config.json"
```

Enjoy!
