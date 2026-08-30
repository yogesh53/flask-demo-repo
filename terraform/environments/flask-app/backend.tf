terraform {
  backend "s3" {
    bucket = "terraform-yogesh-bucket"
    key    = "uat/terraform.tfstate"
    region = "ap-south-1"
  }
}