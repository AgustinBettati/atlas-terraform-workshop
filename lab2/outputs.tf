output "project_id" {
  description = "ID del proyecto (compartido) donde se desplego el cluster."
  value       = module.project.id
}

output "connection_string_public" {
  description = "SRV publico, listo para pegar en mongosh/Compass/app (incluye credenciales). Requiere que tu IP este en el access list del proyecto."
  sensitive   = true
  value = replace(
    module.cluster.connection_strings.standard_srv,
    "mongodb+srv://",
    "mongodb+srv://${var.db_username}:${var.db_password}@"
  )
}

# El proyecto compartido debe tener YA configurado un private endpoint en CADA region
# donde este cluster tiene nodos. Es all-or-nothing: si falta en alguna, Atlas devuelve
# private_endpoint vacio. Este cluster es multi-cloud, asi que requiere un private
# endpoint en LAS TRES regiones: AWS EU_SOUTH_2, AZURE SPAIN_CENTRAL y GCP
# EUROPE_SOUTHWEST_1. El string aparece recien cuando los endpoint services estan
# AVAILABLE; si vuelve vacio tras el apply, corre `terraform refresh`.
output "connection_string_private" {
  description = "SRV via private endpoint, listo para pegar (incluye credenciales). Vacio salvo que el proyecto tenga un private endpoint en las tres regiones del cluster."
  sensitive   = true
  value = try(
    replace(
      module.cluster.connection_strings.private_endpoint[0].srv_connection_string,
      "mongodb+srv://",
      "mongodb+srv://${var.db_username}:${var.db_password}@"
    ),
    null
  )
}
