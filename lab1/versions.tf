terraform {
  required_version = ">= 1.9"
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.0"
    }
    # Para resolver tu IP publica y abrir el acceso solo a tu laptop.
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

# Credenciales via MONGODB_ATLAS_CLIENT_ID / MONGODB_ATLAS_CLIENT_SECRET
provider "mongodbatlas" {}
