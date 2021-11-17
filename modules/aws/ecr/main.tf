locals {
  repositories = var.repositories

  // Note:
  // 
  // Providing default values to a list of objects where some of the object key is
  // optional is an experimental feature and may have breaking changes.
  // So the default values must be applied via terragrunt template itself as a workaround.
  // 
  // Refer: https://www.terraform.io/docs/language/functions/defaults.html

  // repositories = defaults(var.repositories, {
  //   image_tag_mutability = "MUTABLE"
  //   scan_on_push         = true
  //   encryption_type      = "AES256"
  // })
}

data "aws_caller_identity" "current" {}

module "ecr" {

  source  = "lgallard/ecr/aws"
  version = "0.3.2"

  count                = length(local.repositories)

  name                 = local.repositories[count.index].name
  scan_on_push         = local.repositories[count.index].scan_on_push
  timeouts_delete      = local.repositories[count.index].timeouts_delete
  image_tag_mutability = local.repositories[count.index].image_tag_mutability
  encryption_type      = local.repositories[count.index].encryption_type
  kms_key              = local.repositories[count.index].kms_key


  # Note that currently only one policy may be applied to a repository.
  policy = local.repositories[count.index].policy

  # Only one lifecycle policy can be used per repository.
  # To apply multiple rules, combined them in one policy JSON.
  lifecycle_policy = local.repositories[count.index].lifecycle_policy

}

resource "aws_ecr_replication_configuration" "default" {
  count = length(var.cross_replication) > 0 ? 1 : 0
  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = var.cross_replication
        content {
          region  = destination.value.region
          registry_id = data.aws_caller_identity.current.account_id
        }
      }
      
    }
  }
}
