provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket       = "platform-lab-tfstate-007"
    key          = "platform-lab/codepipeline.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}