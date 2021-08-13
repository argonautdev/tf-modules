module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.name

  acl = var.visibility == "public" ? "public-read" : "private"

  block_public_acls       = var.visibility == "public" ? false : true
  block_public_policy     = var.visibility == "public" ? false : true
  ignore_public_acls      = var.visibility == "public" ? false : true
  restrict_public_buckets = var.visibility == "public" ? false : true

  versioning = {
    enabled = true
  }

}
