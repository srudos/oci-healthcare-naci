############################################################
# Variables (apps)
############################################################

# OCI auth (needed to fetch kubeconfig)
variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

# Mirth Connect deployment settings
variable "mirth_image_repository" {
  type    = string
  default = "docker.io/nextgenhealthcare/connect"
}

variable "mirth_image_tag" {
  type    = string
  default = "4.5.2"
}

variable "mirth_replica_count" {
  type    = number
  default = 1
}

variable "mirth_http_port" {
  type    = number
  default = 8080
}

variable "mirth_https_port" {
  type    = number
  default = 8443
}

variable "mirth_vmoptions" {
  type    = string
  default = "-Xmx512m"
}

variable "mirth_keystore_storepass" {
  type      = string
  sensitive = true
  default   = "changeme"
}

variable "mirth_keystore_keypass" {
  type      = string
  sensitive = true
  default   = "changeme"
}

variable "mirth_server_id" {
  type    = string
  default = "mirth-connect-oke"
}

variable "mirth_database_max_connections" {
  type    = number
  default = 20
}

variable "mirth_database_max_retry" {
  type    = number
  default = 2
}

variable "mirth_database_retry_wait_ms" {
  type    = number
  default = 10000
}

variable "mirth_persistence_size" {
  type    = string
  default = "10Gi"
}

variable "mirth_persistence_storage_class" {
  type    = string
  default = ""
}

# PostgreSQL credentials used by the Mirth Connect backend database
variable "psql_admin_username" {
  type    = string
  default = "admin"
}

variable "psql_admin_password" {
  type      = string
  sensitive = true
}

variable "psql_mirth_username" {
  type    = string
  default = "mirthdb"
}

variable "psql_mirth_password" {
  type      = string
  sensitive = true
}
