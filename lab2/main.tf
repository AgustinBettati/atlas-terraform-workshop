# Lab 2 - Completa los modulos oficiales para un replica set multi-cloud.
# Docs:
#   modulo project: https://registry.terraform.io/modules/terraform-mongodbatlas-modules/project/mongodbatlas/latest
#   modulo cluster: https://registry.terraform.io/modules/terraform-mongodbatlas-modules/cluster/mongodbatlas/latest
#   database_user:  https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user
#   regiones:       https://www.mongodb.com/docs/atlas/cloud-providers-regions/

module "project" {
  source  = "terraform-mongodbatlas-modules/project/mongodbatlas"
  version = "~> 0.2"

  # ip_access_list ya viene resuelta: el modulo valida las entradas y rechaza
  # 0.0.0.0/0 salvo que se pase skip_allow_all_validation = true. Para el workshop
  # abrimos a todo Internet para que cualquiera conecte desde su laptop; NO en produccion.
  ip_access_list = [{ source = var.ip_access_cidr, comment = "Workshop", skip_allow_all_validation = true }]

  # TODO: define org_id, name y tags
}

module "cluster" {
  source  = "terraform-mongodbatlas-modules/cluster/mongodbatlas"
  version = "~> 0.3"

  name         = var.cluster_name
  project_id   = module.project.id
  cluster_type = "REPLICASET"

  # TODO: define la lista regions con 3 entradas (AWS EU_WEST_1, AZURE EUROPE_WEST,
  #       GCP EUROPE_SOUTHWEST_1). El ORDEN define la prioridad (primera = 7).
  #       node_count = 1 cada una. instance_size se omite (M10 por defecto).
}

resource "mongodbatlas_database_user" "this" {
  project_id         = module.project.id
  auth_database_name = "admin"
  # TODO: define username, password y un bloque roles
}
