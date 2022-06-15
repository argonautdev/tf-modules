module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.3"
  comment             = var.comment
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  
  ##Origin http/https ports are required (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#origin-arguments)
  origin = {
     custom_origin = {
        domain_name = var.custom_origin_dns_name
        custom_origin_config = {
          http_port   = 80
          https_port  = 443
          origin_protocol_policy = var.origin_protocol_policy
          origin_ssl_protocols   = ["TLSv1.2"]
        } 
     }
  }

  default_cache_behavior = {
    viewer_protocol_policy     = "allow-all"
    target_origin_id           = "custom_origin"
    allowed_methods = var.allowed_methods
    cached_methods  = var.cached_methods
    compress        = true
    query_string    = true
  }
}