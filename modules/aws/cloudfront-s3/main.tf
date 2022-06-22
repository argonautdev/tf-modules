module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.3"
  comment             = "${var.app_name} via Argonaut"
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  
  /* When S3 Origin Access Identity Enabled */
  create_origin_access_identity = var.create_origin_access_identity
  default_root_object = var.default_root_object
  ##Will create an identity with the description value
  origin_access_identities = var.create_origin_access_identity ? {
    s3 = var.comment
  }: {}
  
  origin = {
    s3_one = {
      domain_name = var.cf_origin_create_bucket ? module.cf-origin-bucket.s3_bucket_bucket_domain_name : data.aws_s3_bucket.cf_origin_bucket.bucket_domain_name
      s3_origin_config = {
        origin_access_identity = "s3" ##This should be same as "key" in "origin_access_identities"
      }
    }
  }
  
  default_cache_behavior = {
    viewer_protocol_policy     = "allow-all"
    target_origin_id           = "s3_one"
    allowed_methods = var.allowed_methods
    cached_methods  = var.cached_methods
    compress        = true
    query_string    = true
  }
  
  ##If Logging is enabled it will get the value from module s3 outputs
  logging_config = var.logging ? {
     bucket = module.cf-logging-bucket.s3_bucket_bucket_domain_name
     prefix = "${var.app_name}-cloudfront" 
  } : {}
  aliases = concat(var.aliases, ["${var.subdomain}.${var.domain_name}"])
  
  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method  = "sni-only"
  }
}

##Bucket for storing static assests
module "cf-origin-bucket" {
  create_bucket = var.cf_origin_create_bucket ## 
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.3.0"
  bucket = var.cf_origin_bucket_name
  # Allow deletion of non-empty bucket
  force_destroy = true
  block_public_acls = var.block_public_acls
  block_public_policy = var.block_public_policy
  ignore_public_acls = var.ignore_public_acls
}

##Fetch information of existing bucket 
data "aws_s3_bucket" "cf_origin_bucket" {
  bucket = var.cf_origin_create_bucket ? module.cf-origin-bucket.s3_bucket_id : var.cf_origin_bucket_name
}


###########################
# Origin Access Identities
###########################
data "aws_iam_policy_document" "s3_policy" {
  source_policy_documents = compact([
    # Pull Policy from data block only when it satisfies "attach_policy is true and cf_origin_create_bucket = true"
    !var.cf_origin_create_bucket && var.attach_policy ? data.aws_s3_bucket_policy.existing_bucket_policy[0].policy : ""
  ])
  statement {
    sid = "Cloudfront Policy managed by argonaut team"
    actions   = ["s3:GetObject"]
    resources = [
      var.assets_dir_path == null ? "${data.aws_s3_bucket.cf_origin_bucket.arn}/*" : "${data.aws_s3_bucket.cf_origin_bucket.arn}/${var.assets_dir_path}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }
}


##Pull Existing Policy and mege both
##DataBlock executes only when it satisfies "attach_policy is true and cf_origin_create_bucket = true" 
data "aws_s3_bucket_policy" "existing_bucket_policy" {
  count = !var.cf_origin_create_bucket && var.attach_policy ? 1 : 0
  bucket = var.cf_origin_bucket_name
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = data.aws_s3_bucket.cf_origin_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

##Module for creating logging bucket.
##Bucket allows to store logs files generated by cloudfront
data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "logdelivaryaccount" {}

data "aws_caller_identity" "current_account" {}

module "cf-logging-bucket" {
  create_bucket = var.logging ? true : false ## Bucket would be created only when logging is enabled
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.3.0"
  bucket = var.logging ? "cf-accesslog-storage-${random_pet.this[0].id}" : null

  # Allow deletion of non-empty bucket
  force_destroy = true
  acl    = null
  ##ACL for Bucket. 
  ##1. Full Control to awslogsdelivery and to the user who is creating bucket
  grant = [{
    type        = "CanonicalUser"
    permission = "FULL_CONTROL"
    id          = data.aws_canonical_user_id.current.id
    }, {
    type        = "CanonicalUser"
    permission = "FULL_CONTROL"
    id          = data.aws_cloudfront_log_delivery_canonical_user_id.logdelivaryaccount.id
    #"c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  }]
  server_side_encryption_configuration = var.logging ? {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects[0].arn
        sse_algorithm     = "aws:kms"
      }
    }
  }: {}
} 

##Module for creating KMS key to encrpt the logging bucket
resource "aws_kms_key" "objects" {
  count = var.logging ? 1 : 0
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
  policy = data.aws_iam_policy_document.kms_policy_document[0].json
}

#Since we are creating an KMS key to encrypt and decrypt objects in logging bucket we need to add following permissions to KMS Key
# Ref: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership ( Required key policy for SSE-KMS buckets )
data "aws_iam_policy_document" "kms_policy_document" {
  count = var.logging ? 1 : 0
  statement {
    sid = "Allow CloudFront to use the key to deliver logs"

    actions = [
      "kms:GenerateDataKey*",
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    resources = [
      "*"
    ]
  }
  statement {
    sid = "Enable IAM User Permissions"

    actions = [
      "kms:*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:root"]
    }
    resources = [
      "*"
    ]
  }
}

resource "random_pet" "this" {
  count = var.logging ? 1 : 0
  length = 2
}

###Certificate Deployment in ACM for CF Alternative domain.

##Find the details of zone
data "aws_route53_zone" "hostedzone" {
  name         = var.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.0.1"
  providers = {
    aws = aws.acm ##Only Provision in "us-east-1" due it's limitation
  }
  domain_name  = "${var.subdomain}.${var.domain_name}"
  zone_id      = data.aws_route53_zone.hostedzone.zone_id
}

##Route53 Record entry for cloudfront dns
resource "aws_route53_record" "cf_record_entry" {
    zone_id = data.aws_route53_zone.hostedzone.zone_id
    name = var.subdomain
    type = "A"
    alias  {
      name = module.cloudfront.cloudfront_distribution_domain_name
      zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      evaluate_target_health = false
    }
}
