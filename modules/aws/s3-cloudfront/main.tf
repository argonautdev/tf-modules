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

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "2.7.0"
  # insert the 9 required variables here

  aliases = ["${local.subdomain}.${local.domain_name}"]

  comment             = "CloudFront via Argonaut"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
    ingress-nlb = "Ingress nlb for the k8s cluster"
  }

  logging_config = {
    bucket = module.log_bucket.s3_bucket_bucket_domain_name
    prefix = "${local.app_name}-cloudfront" #"
  }

  origin = {
    ingress-nlb = {
      domain_name = "${local.subdomain}.${local.domain_name}" #"
      origin_id   = "ingress-nlb"
      custom_origin_config = {
        http_port = 80
        https_port = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols = ["TLSv1.2"]
        // origin_read_timeout = 30
        // origin_keepalive_timeout = 5
      }
      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-1"
      }
    }

    // appsync = {
    //   domain_name = "appsync.${local.domain_name}"
    //   # "
    //   custom_origin_config = {
    //     http_port              = 80
    //     https_port             = 443
    //     origin_protocol_policy = "match-viewer"
    //     origin_ssl_protocols   = ["TLSv1.2"]
    //   }

    //   custom_header = [
    //     {
    //       name  = "X-Forwarded-Scheme"
    //       value = "https"
    //     },
    //     {
    //       name  = "X-Frame-Options"
    //       value = "SAMEORIGIN"
    //     }
    //   ]

    //   origin_shield = {
    //     enabled              = true
    //     origin_shield_region = "us-east-1"
    //   }
    // }

  s3_one = {
      domain_name = module.s3_one.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one" # key in `origin_access_identities`
        # cloudfront_access_identity_path = "origin-access-identity/cloudfront/E5IGQAA1QO48Z" # external OAI resource
      }
    }
  }

  origin_group = {
    group_one = {
      failover_status_codes      = [403, 404, 500, 502]
      primary_member_origin_id   = "ingress-nlb"
      secondary_member_origin_id = "s3_one"
      // primary_member_origin_id   = "appsync"      
    }
  }

  default_cache_behavior = {
    target_origin_id = "ingress-nlb"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    compress                = true
    forwarded_values = {
      cookies = {
        forward = "all"
      }
      query_string            = true
      query_string_cache_keys = []
      headers                 = ["*"]
    }
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  // default_cache_behavior = {
  //   target_origin_id       = "appsync"
  //   viewer_protocol_policy = "redirect-to-https"

  //   allowed_methods = ["GET", "HEAD", "OPTIONS"]
  //   cached_methods  = ["GET", "HEAD"]
  //   compress        = true
  //   query_string    = true

  //   lambda_function_association = {

  //     # Valid keys: viewer-request, origin-request, viewer-response, origin-response
  //     viewer-request = {
  //       lambda_arn   = module.lambda_function.lambda_function_qualified_arn
  //       include_body = true
  //     }

  //     origin-request = {
  //       lambda_arn = module.lambda_function.lambda_function_qualified_arn
  //     }
  //   }
  // }

  // ordered_cache_behavior {
  //   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  //   cached_methods   = ["GET", "HEAD"]
  //   target_origin_id = "ingress-nlb"
  //   forwarded_values {
  //     cookies {
  //       forward = "all"
  //     }
  //     compress        = true
  //     query_string    = true
      // headers                 = ["*"]
  //   }
  //   viewer_protocol_policy = "redirect-to-https"
  //   min_ttl                = 0
  //   default_ttl            = 300
  //   max_ttl                = 1200
  //   path_pattern           = "/errors/*.html"
  // }


  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_one"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true

      function_association = {
        # Valid keys: viewer-request, viewer-response
        viewer-request = {
          function_arn = aws_cloudfront_function.example.arn
        }

        viewer-response = {
          function_arn = aws_cloudfront_function.example.arn
        }
      }
    }
  ]

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method  = "sni-only"
  }

  geo_restriction = {
    restriction_type = "none"
    // restriction_type = "whitelist"
    // locations        = ["NO", "UA", "US", "GB"]
  }

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
  subject_alternative_names = ["${local.subdomain}.${local.domain_name}"]
}

#############
# S3 buckets
#############

data "aws_canonical_user_id" "current" {}

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
  //   {
  //   type        = "CanonicalUser"
  //   permissions = ["FULL_CONTROL"]
  //   id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
  //   # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
  //   # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  // }
  ]
  force_destroy = true
}

#############################################
# Using packaged function from Lambda module
#############################################

locals {
  package_url = "https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-lambda/master/examples/fixtures/python3.8-zip/existing_package.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${local.app_name}-${random_pet.this.id}-lambda"
  description   = "My awesome lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  publish        = false
  lambda_at_edge = false 
  // publish        = true
  // lambda_at_edge = true

  create_package         = false
  local_existing_package = local.downloaded

  # @todo: Missing CloudFront as allowed_triggers?

  #    allowed_triggers = {
  #      AllowExecutionFromAPIGateway = {
  #        service = "apigateway"
  #        arn     = module.api_gateway.apigatewayv2_api_execution_arn
  #      }
  #    }
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

resource "aws_cloudfront_function" "example" {
  name    = "${local.app_name}-example-${random_pet.this.id}"
  runtime = "cloudfront-js-1.0"
  code    = file("example-function.js")
}