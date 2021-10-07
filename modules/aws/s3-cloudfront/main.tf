// TODO: ADD TAGS

provider "aws" {
  region = "us-east-1" # CloudFront expects ACM resources in us-east-1 region only

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}

locals {
  domain_name = "argonaut.live" # trimsuffix(data.aws_route53_zone.this.name, ".")
  subdomain   = "violet"
  app_name    = "myapp"
}

data "aws_cloudfront_origin_request_policy" "cors_s3origin" {
  name = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_origin_request_policy" "cors_customorigin" {
  name = "Managed-Custom-Origin"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "2.7.0"
  # insert the 9 required variables here

  depends_on = [
    data.aws_cloudfront_origin_request_policy.cors_s3origin,
    data.aws_cloudfront_origin_request_policy.cors_customorigin,
    data.aws_cloudfront_cache_policy.caching_optimized
  ]

  aliases = ["${local.subdomain}.${local.domain_name}", "bs-prod.violet.argonaut.live"]

  comment             = "${local.app_name} via Argonaut"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
    ingress_nlb = "Ingress nlb for the k8s cluster"
  }

  logging_config = {
    bucket = module.log_bucket.s3_bucket_bucket_domain_name
    prefix = "${local.app_name}-cloudfront" #"
  }

  origin = {
    ingress_nlb = {
      // domain_name = "${local.subdomain}.${local.domain_name}" #"
      domain_name = "a8cdd7c38e0c843d08c2cd309ec286f3-c6e29e9322c0415c.elb.us-east-1.amazonaws.com"
      origin_id   = "ingress_nlb"
      custom_origin_config = {
        http_port = 80
        https_port = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols = ["TLSv1.2"]
      }
      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-1"
      }
    }

  s3_one = {
      domain_name = module.s3_one.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one" # key in `origin_access_identities`
        # cloudfront_access_identity_path = "origin-access-identity/cloudfront/E5IGQAA1QO48Z" # external OAI resource
      }
      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-1"
      }
    }
  }

  origin_group = {
    group_one = {
      failover_status_codes      = [403, 404, 500, 502]
      primary_member_origin_id   = "ingress_nlb"
      secondary_member_origin_id = "s3_one"  
    }
  }

  default_cache_behavior = {
    target_origin_id = "ingress_nlb"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    compress                = true
    
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200

    // origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_customorigin.id
    // cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    
    forwarded_values = {
      cookies = {
        forward = "all"
      }
      query_string            = true
      query_string_cache_keys = []
      headers                 = ["*"]
    }
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_one"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method  = "sni-only"
  }

  geo_restriction = {
    restriction_type = "none"
  }

  // custom_error_response = {
  //   error_code = "404"
  //   error_caching_min_ttl = 0
  // }

  // custom_error_responses = {
  //   error_code = "403"
  //   error_caching_min_ttl = 0
  // }

}

######
# ACM
######

data "aws_route53_zone" "this" {
  name = "${local.domain_name}"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name               = local.domain_name
  zone_id                   = data.aws_route53_zone.this.id
  subject_alternative_names = ["${local.subdomain}.${local.domain_name}", "bs-prod.violet.argonaut.live"]
}

#############
# S3 buckets
#############

data "aws_canonical_user_id" "current" {}
// data "aws_cloudfront_canonical_user_id" "current" {}

module "s3_one" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 2.0"

  bucket        = "s3-one-${random_pet.this.id}"
  
  force_destroy = true
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 2.0"

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true

  bucket = "logs-${random_pet.this.id}"
  acl    = null
  grant = [{
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    id          = data.aws_canonical_user_id.current.id
    },
    {
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    // id          = data.aws_cloudfront_canonical_user_id.current.id
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  }
  ]
  force_destroy = true
}

##########
# Route53
##########

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.0.0" # @todo: revert to "~> 2.0" once 2.1.0 is fixed properly

  zone_id = data.aws_route53_zone.this.zone_id

  records = [
    {
      name = local.subdomain
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    },
  ]
}

###########################
# Origin Access Identities
###########################
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_one.s3_bucket_arn}/static/*"]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_one.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}

########
# Extra
########

resource "random_pet" "this" {
  length = 2
}

// ##########
// # WAF
// ##########

// module "cloudfront_waf" {
//   source = "coresolutions-ltd/wafv2/aws"

//   name_prefix      = "Cloudfront"
//   default_action   = "allow"
//   scope                = "CLOUDFRONT"
//   rate_limit          = 1000
//   managed_rules = ["AWSManagedRulesCommonRuleSet",
//                                 "AWSManagedRulesAmazonIpReputationList",
//                                 "AWSManagedRulesAdminProtectionRuleSet",
//                                 "AWSManagedRulesKnownBadInputsRuleSet",
//                                 "AWSManagedRulesLinuxRuleSet",
//                                 "AWSManagedRulesUnixRuleSet"]
// }