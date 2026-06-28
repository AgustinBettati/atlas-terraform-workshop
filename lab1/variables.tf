variable "project_id" {
  description = "ID del proyecto Atlas compartido donde se despliega el cluster (24 hex). El proyecto ya existe y tiene el private networking configurado."
  type        = string
}

variable "cluster_name" {
  description = "Nombre del cluster del Lab 1."
  type        = string
  default     = "lab1-basic"
}

variable "cloud_provider" {
  description = "Proveedor cloud donde se aprovisiona el cluster. Valores: AWS, AZURE o GCP."
  type        = string
}

variable "region_name" {
  description = <<-EOT
    Region de Atlas donde se aprovisiona el cluster. Tiene que corresponder al cloud_provider elegido.
    Ejemplos de regiones en Espana (mismas que usa el Lab 2, para saber donde configurar el private endpoint):
      - AWS:   EU_SOUTH_2          (Espana / Zaragoza)
      - AZURE: SPAIN_CENTRAL       (Spain Central / Madrid)
      - GCP:   EUROPE_SOUTHWEST_1  (Madrid)
    Listado completo de identificadores: https://www.mongodb.com/docs/atlas/cloud-providers-regions/
  EOT
  type        = string
}

variable "db_username" {
  description = "Usuario de base de datos a crear."
  type        = string
  default     = "workshop_app"
}

variable "db_password" {
  description = "Password del usuario (usar alfanumerica para evitar URL-encoding)."
  type        = string
  sensitive   = true
}
