resource "google_storage_bucket" "example" {
  name          = "oidc-test-bucket-example"
  location      = "ASIA-NORTHEAST1"
  force_destroy = true
}

resource "google_storage_bucket_object" "example" {
  name    = "hello.txt"
  bucket  = google_storage_bucket.example.id
  content = "Hello World"
}
