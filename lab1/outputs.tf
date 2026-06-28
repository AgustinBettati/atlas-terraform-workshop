output "project_id" {
  description = "ID del proyecto (compartido) donde se desplego el cluster."
  value       = var.project_id
}

output "connection_string_public" {
  description = "SRV publico, listo para pegar en mongosh/Compass/app (incluye credenciales). Requiere que tu IP este en el access list del proyecto."
  sensitive   = true
  value = replace(
    mongodbatlas_advanced_cluster.this.connection_strings.standard_srv,
    "mongodb+srv://",
    "mongodb+srv://${var.db_username}:${var.db_password}@"
  )
}

# El proyecto compartido debe tener YA configurado un private endpoint en CADA region
# donde este cluster tiene nodos. Es all-or-nothing: si falta en alguna region, Atlas
# devuelve private_endpoint vacio. Este lab usa una sola region (var.region_name), asi
# que alcanza con un private endpoint en esa region. El string aparece recien cuando el
# endpoint service esta AVAILABLE; si vuelve vacio tras el apply, corre `terraform refresh`.
output "connection_string_private" {
  description = "SRV via private endpoint, listo para pegar (incluye credenciales). Vacio si el proyecto no tiene un private endpoint en var.region_name."
  sensitive   = true
  value = try(
    replace(
      mongodbatlas_advanced_cluster.this.connection_strings.private_endpoint[0].srv_connection_string,
      "mongodb+srv://",
      "mongodb+srv://${var.db_username}:${var.db_password}@"
    ),
    null
  )
}
