terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "terraform/statefile.tfstate"
    region         = "ap-south-1"
  }
}
