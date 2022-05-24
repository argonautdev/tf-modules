module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.3"
  comment             = var.comment
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment

  create_origin_access_identity = var.create_origin_access_identity
  origin_access_identities = var.origin_access_identities

  origin = var.origin

  default_cache_behavior = var.default_cache_behavior
}