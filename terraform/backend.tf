terraform {
  backend "s3" {
    bucket         = "project-sfa-terraform-state-bucket"
    key            = "terraform/statefile.tfstate"
    region         = "ap-south-1"
  }
}
