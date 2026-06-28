# Lab 2 - Replica set multi-cloud con los modulos oficiales, dentro de un proyecto existente.
# El proyecto ya esta creado (var.project_id) y tiene el private networking configurado;
# aca solo desplegamos el cluster, el usuario y la IP de acceso publico.

# Resolvemos la IP publica de ESTA laptop. Como el proyecto es compartido, cada persona
# agrega solo su propia IP (/32) en vez de 0.0.0.0/0: asi no chocan las entradas entre
# participantes y el acceso queda acotado a cada quien.
data "http" "myip" {
  url = "https://api.ipify.org"
}

module "project" {
  source  = "terraform-mongodbatlas-modules/project/mongodbatlas"
  version = "~> 0.2"

  # Modo referencia: al pasar project_id el modulo NO crea el proyecto, solo gestiona
  # recursos sueltos (aca la ip_access_list) sobre un proyecto que ya existe.
  project_id = var.project_id

  # Cada participante abre solo su propia IP (/32). Al ser un /32 ya no hace falta
  # skip_allow_all_validation (ese flag solo era necesario para 0.0.0.0/0).
  ip_access_list = [{ source = "${chomp(data.http.myip.response_body)}/32", comment = "Workshop ${var.cluster_name}" }]
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
