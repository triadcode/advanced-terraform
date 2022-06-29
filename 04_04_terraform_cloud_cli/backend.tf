terraform {
  backend "remote" {
    organization = "mdm"

    workspaces {
      name = "cli-workspace"
    }
  }
}
