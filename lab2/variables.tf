variable "project_id" {
  description = "ID del proyecto Atlas compartido donde se despliega el cluster (24 hex). El proyecto ya existe y tiene el private networking configurado."
  type        = string
}

variable "cluster_name" {
  description = "Nombre del cluster multi-cloud del Lab 2."
  type        = string
  default     = "lab2-multicloud"
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
