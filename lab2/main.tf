# Lab 2 - Replica set multi-cloud con los modulos oficiales, dentro de un proyecto existente.
# El proyecto ya esta creado (var.project_id) y tiene el private networking configurado;
# aca solo desplegamos el cluster, el usuario y la IP de acceso publico.

module "project" {
  source  = "terraform-mongodbatlas-modules/project/mongodbatlas"
  version = "~> 0.2"

  # Modo referencia: al pasar project_id el modulo NO crea el proyecto, solo gestiona
  # recursos sueltos (aca la ip_access_list) sobre un proyecto que ya existe.
  project_id = var.project_id

  # El modulo rechaza 0.0.0.0/0 salvo skip_allow_all_validation = true. Para el workshop
  # abrimos a todo Internet para conectar desde cualquier laptop; NO en produccion.
  ip_access_list = [{ source = var.ip_access_cidr, comment = "Workshop", skip_allow_all_validation = true }]
}

module "cluster" {
  source  = "terraform-mongodbatlas-modules/cluster/mongodbatlas"
  version = "~> 0.3"

  name       = var.cluster_name
  project_id = module.project.id

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
  project_id         = module.project.id
  username           = var.db_username
  password           = var.db_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}
