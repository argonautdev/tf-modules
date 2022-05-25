module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.3"
  comment             = var.comment
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment

  create_origin_access_identity = var.create_origin_access_identity
  ##Description while creating identity. so, keeping comment as input. whatever we pass as description (comment) it will be applied here.
  origin_access_identities = {
    s3 = var.comment
  }
  origin = {
    s3_one = {
      domain_name = var.s3_bucket_dns_name
      s3_origin_config = {
        origin_access_identity = "s3"
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
}