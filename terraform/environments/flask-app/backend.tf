terraform {
  backend "s3" {
    bucket = "terraform-yogesh-bucket"
    key    = "uat/terraform.tfstate"
    use_lockfile = true
    region = "ap-south-1"
  }
}