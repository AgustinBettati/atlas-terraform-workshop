# Lab 1 - Replica set single-region con recursos planos, dentro de un proyecto existente.
# El proyecto ya esta creado (var.project_id) y tiene el private networking configurado;
# aca solo desplegamos el cluster, el usuario y la IP de acceso publico.

resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = var.project_id
  name         = var.cluster_name
  cluster_type = "REPLICASET"

  replication_specs = [
    {
      region_configs = [
        {
          provider_name = var.cloud_provider
          region_name   = var.region_name
          priority      = 7

          electable_specs = {
            instance_size = "M10"
            node_count    = 3
          }
        }
      ]
    }
  ]
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
