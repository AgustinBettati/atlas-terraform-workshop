variable "org_id" {
  description = "ID de la Organizacion Atlas (24 hex). Organization Settings."
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto Atlas a crear en este lab."
  type        = string
  default     = "workshop-lab1"
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
    Ejemplos de regiones en Espana:
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

variable "ip_access_cidr" {
  description = "CIDR permitido. 0.0.0.0/0 SOLO para el workshop."
  type        = string
  default     = "0.0.0.0/0"
}
