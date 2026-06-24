output "project_id" {
  description = "ID del proyecto creado en este lab."
  value       = mongodbatlas_project.this.id
}

output "connection_string_srv" {
  description = "Cadena SRV estandar (sin credenciales)."
  value       = mongodbatlas_advanced_cluster.this.connection_strings.standard_srv
}

output "connection_string" {
  description = "Cadena lista para pegar en mongosh/Compass/app (incluye credenciales)."
  sensitive   = true
  value = replace(
    mongodbatlas_advanced_cluster.this.connection_strings.standard_srv,
    "mongodb+srv://",
    "mongodb+srv://${var.db_username}:${var.db_password}@"
  )
}
