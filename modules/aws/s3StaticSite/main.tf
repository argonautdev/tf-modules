module "s3_logging_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.name
  acl    = "log-delivery-write"
}

module "s3_static_site_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.name
  acl    = "public-read"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.website}/*"
            ]
        }
    ]
}
EOF

  website = {
    index_document = var.index_document
    error_document = var.error_document
  }

  logging = {
    target_bucket = module.s3_logging_bucket.s3_bucket_id
  }

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "webapp" {
  acl          = "public-read"
  key          = var.index_document
  bucket       = module.s3_static_site_bucket.s3_bucket_id
  content      = file("${path.module}/${var.index_document}")
  content_type = "text/html"
}
