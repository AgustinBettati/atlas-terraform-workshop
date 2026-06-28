# Lab 2 - Completa los modulos oficiales para un replica set multi-cloud.
# El proyecto ya existe (var.project_id) y tiene private networking configurado.
# Docs:
#   modulo project: https://registry.terraform.io/modules/terraform-mongodbatlas-modules/project/mongodbatlas/latest
#   modulo cluster: https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest
#   database_user:  https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
#   regiones:       https://www.mongodb.com/docs/atlas/cloud-providers-regions/

# Resuelve la IP publica de ESTA laptop (ya viene resuelto). El proyecto es compartido,
# asi que cada persona abre solo su propia IP (/32) en vez de 0.0.0.0/0. Si dos personas
# comparten IP (mismo NAT), el recurso no falla por duplicado: queda esa IP habilitada.
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

  name         = var.cluster_name
  project_id   = module.project.id
  cluster_type = "REPLICASET"

  # TODO: define la lista regions con 3 entradas (AWS EU_SOUTH_2, AZURE SPAIN_CENTRAL,
  #       GCP EUROPE_SOUTHWEST_1). El ORDEN define la prioridad (primera = 7).
  #       node_count = 1 cada una. instance_size se omite (M10 por defecto).
}

resource "mongodbatlas_database_user" "this" {
  project_id         = module.project.id
  auth_database_name = "admin"
  # TODO: define username, password y un bloque roles
}
