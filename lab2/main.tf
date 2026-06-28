# Lab 2 - Replica set multi-cloud con el modulo oficial cluster, dentro de un proyecto existente.
# El proyecto ya esta creado (var.project_id) y tiene el private networking configurado;
# aca solo desplegamos el cluster, el usuario y la IP de acceso publico.

module "cluster" {
  source  = "terraform-mongodbatlas-modules/cluster/mongodbatlas"
  version = "~> 0.3"

  name       = var.cluster_name
  project_id = var.project_id

  cluster_type = "REPLICASET"

  # El orden define la prioridad de eleccion: AWS=7, Azure=6, GCP=5.
  # Mismas regiones que recomienda el Lab 1: para tener connection string privada el
  # proyecto debe tener un private endpoint en CADA una de estas tres regiones.
  regions = [
    { name = "EU_SOUTH_2", provider_name = "AWS", node_count = 1 },
    { name = "SPAIN_CENTRAL", provider_name = "AZURE", node_count = 1 },
    { name = "EUROPE_SOUTHWEST_1", provider_name = "GCP", node_count = 1 },
  ]

  tags = {
    team     = "workshop"
    scenario = "multicloud"
  }
  # instance_size se omite -> el modulo usa M10 por defecto.
}

resource "mongodbatlas_database_user" "this" {
  project_id         = var.project_id
  username           = var.db_username
  password           = var.db_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}

resource "mongodbatlas_project_ip_access_list" "this" {
  project_id = var.project_id
  cidr_block = var.ip_access_cidr
  comment    = "Workshop - revisar/cerrar despues de la sesion"
}
