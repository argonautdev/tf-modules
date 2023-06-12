module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.0"
  bucket = var.name

  force_destroy        = var.force_destroy
  acl = var.visibility == "public" ? "public-read" : "private"
  control_object_ownership = var.control_object_ownership
  object_ownership         = var.object_ownership

  block_public_acls       = var.visibility == "public" ? false : true
  block_public_policy     = var.visibility == "public" ? false : true
  ignore_public_acls      = var.visibility == "public" ? false : true
  restrict_public_buckets = var.visibility == "public" ? false : true

  versioning = {
    enabled = true
  }
}
