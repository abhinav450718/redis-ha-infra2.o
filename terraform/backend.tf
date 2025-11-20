terraform {
  backend "s3" {
    bucket         = "redis-ha-infra-state"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "redis-ha-infra-lock"
    encrypt        = true
  }
}
