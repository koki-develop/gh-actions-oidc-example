resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = "github-actions-pool"
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_provider_id = "github-actions-provider"
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
  }
}

resource "google_service_account" "github_actions" {
  account_id = "github-actions"
}

resource "google_service_account_iam_binding" "github_actions_iam_workload_identity_user" {
  service_account_id = google_service_account.github_actions.id
  role               = "roles/iam.workloadIdentityUser"
  members            = ["principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/koki-develop/gh-actions-oidc-example"]
}

resource "google_project_iam_binding" "github_actions_storage_object_viewer" {
  project = var.project
  role    = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.github_actions.email}"]
}
