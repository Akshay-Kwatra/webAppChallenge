terraform {
  backend "s3" {
    bucket = "state-bucket"
    key    = "webapp"
    region = "us-east-1"
  }
}