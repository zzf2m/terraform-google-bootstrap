/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "im_workspace" {
  source = "../../modules/im_cloudbuild_workspace"

  project_id    = var.project_id
  deployment_id = "im-example-github-deployment"

  tf_repo_type           = "GITHUB"
  im_deployment_repo_uri = "https://github.com/josephdt12/terraform-google-bootstrap.git"
  im_deployment_repo_dir = "examples/im_cloudbuild_workspace_github"
  im_deployment_ref      = "bugbash-example"
  infra_manager_sa       = "projects/${var.project_id}/serviceAccounts/prod-byosa@josephdthomas-prod.iam.gserviceaccount.com"

  github_app_installation_id   = "47236181"
  github_personal_access_token = var.im_github_pat_secret
}

module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 5.0"

  name       = "im-${var.project_id}-example-bucket"
  project_id = var.project_id
  location   = "us"

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age            = 365
      with_state     = "ANY"
      matches_prefix = var.project_id
    }
  }]

  custom_placement_config = {
    data_locations : ["US-EAST4", "US-WEST1"]
  }

  iam_members = [{
    role   = "roles/storage.objectViewer"
    member = "group:test-gcp-ops@test.blueprints.joonix.net"
  }]

  autoclass = true
}
