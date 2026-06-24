# Lab 1 - Completa los recursos planos para levantar un replica set single-region.
# Las pistas (topologia, region, sintaxis del provider 2.0) estan en el README de este lab.
# Docs:
#   project:                https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project
#   advanced_cluster:       https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/advanced_cluster
#   database_user:          https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
#   project_ip_access_list: https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list
#   regiones:               https://www.mongodb.com/docs/atlas/cloud-providers-regions/

resource "mongodbatlas_project" "this" {
  # TODO
}

resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = mongodbatlas_project.this.id
  name         = var.cluster_name
  cluster_type = "REPLICASET"

  # TODO: replication_specs
}

resource "mongodbatlas_database_user" "this" {
  project_id         = mongodbatlas_project.this.id
  auth_database_name = "admin"
  # TODO: username, password y roles
}

resource "mongodbatlas_project_ip_access_list" "this" {
  project_id = mongodbatlas_project.this.id
  # TODO
}
