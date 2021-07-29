output "redis_host" {
  value = aws_elasticache_cluster.my_cluster.cache_nodes[0].address
}