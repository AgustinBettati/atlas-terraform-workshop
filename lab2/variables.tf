variable "org_id" {
  description = "ID de la Organizacion Atlas (24 hex)."
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto Atlas a crear en este lab."
  type        = string
  default     = "workshop-lab2"
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

variable "ip_access_cidr" {
  description = "CIDR permitido. 0.0.0.0/0 SOLO para el workshop."
  type        = string
  default     = "0.0.0.0/0"
}
