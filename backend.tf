terraform {
  backend "gcs" {
    bucket      = "demobucketgke"
    prefix      = "terraform/state"
    credentials = "./key.json"

  }
}