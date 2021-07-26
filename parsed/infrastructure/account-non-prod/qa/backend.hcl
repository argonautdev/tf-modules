
#  kept at environment level since its common per environment

#  connection info for the current environment
#  parse this go template before push
#  this creates a "backend.tf" file
remote_state {
  backend = "pg" 
  config = {
    conn_str = "postgres://argonaut:VPnoVfCdNQiJypbRaSUjisFNHmEKonal@tf-orgs.cmdfavrazybz.us-east-2.rds.amazonaws.com/argonaut"
    schema_name = "tf_ligma"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}