locals {
  config = jsondecode(data.local_file.config_file.content)
}
