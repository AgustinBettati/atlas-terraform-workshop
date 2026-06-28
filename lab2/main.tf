# Lab 2 - Completa el modulo oficial cluster para un replica set multi-cloud.
# El proyecto ya existe (var.project_id) y tiene private networking configurado.
# Docs:
#   modulo cluster: https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest
#   database_user:  https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
#   regiones:       https://www.mongodb.com/docs/atlas/cloud-providers-regions/

module "cluster" {
  source  = "terraform-mongodbatlas-modules/cluster/mongodbatlas"
  version = "~> 0.3"

  name         = var.cluster_name
  project_id   = var.project_id
  cluster_type = "REPLICASET"

  # TODO: define la lista regions con 3 entradas (AWS EU_SOUTH_2, AZURE SPAIN_CENTRAL,
  #       GCP EUROPE_SOUTHWEST_1). El ORDEN define la prioridad (primera = 7).
  #       node_count = 1 cada una. instance_size se omite (M10 por defecto).
}

resource "mongodbatlas_database_user" "this" {
  project_id         = var.project_id
  auth_database_name = "admin"
  # TODO: define username, password y un bloque roles
}

# ip_access_list ya viene resuelto: acceso publico para el workshop (NO en produccion).
resource "mongodbatlas_project_ip_access_list" "this" {
  project_id = var.project_id
  cidr_block = var.ip_access_cidr
  comment    = "Workshop - revisar/cerrar despues de la sesion"
}
