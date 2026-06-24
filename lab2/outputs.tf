output "project_id" {
  description = "ID del proyecto creado por el modulo project."
  value       = module.project.id
}

output "connection_string" {
  description = "Cadena lista para pegar en mongosh/Compass/app (incluye credenciales)."
  sensitive   = true
  value = replace(
    module.cluster.connection_strings.standard_srv,
    "mongodb+srv://",
    "mongodb+srv://${var.db_username}:${var.db_password}@"
  )
}
