output "bucket_name" {
  value = local.config.bucket.name
}

output "bucket_tfstate" {
  value = local.config.bucket.tfstate
}

output "region" {
  value = local.config.aws.region
}
