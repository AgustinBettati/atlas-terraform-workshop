module "project" {
  source  = "terraform-mongodbatlas-modules/project/mongodbatlas"
  version = "~> 0.2"

  org_id = var.org_id
  name   = var.project_name
  # El modulo valida las entradas y rechaza 0.0.0.0/0 salvo skip_allow_all_validation = true.
  # Para el workshop abrimos a todo Internet para conectar desde cualquier laptop; NO en produccion.
  ip_access_list = [{ source = var.ip_access_cidr, comment = "Workshop", skip_allow_all_validation = true }]
  tags           = { team = "workshop", scenario = "multicloud" }
}

module "cluster" {
  source  = "terraform-mongodbatlas-modules/cluster/mongodbatlas"
  version = "~> 0.3"

  name       = var.cluster_name
  project_id = module.project.id

  cluster_type = "REPLICASET"

  # El orden define la prioridad de eleccion: AWS=7, Azure=6, GCP=5.
  regions = [
    { name = "EU_WEST_1", provider_name = "AWS", node_count = 1 },
    { name = "EUROPE_WEST", provider_name = "AZURE", node_count = 1 },
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
