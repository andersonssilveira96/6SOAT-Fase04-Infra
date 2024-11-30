variable "region" {
  default  = "us-east-1"
}

variable "atlas_public_key" {
  description = "Public key for MongoDB Atlas API."
  type        = string
}

variable "atlas_private_key" {
  description = "Private key for MongoDB Atlas API."
  type        = string
}

variable "project_name" {
  description = "Name of the MongoDB Atlas project."
  type        = string
}

variable "cluster_name" {
  description = "Name of the MongoDB Atlas cluster."
  type        = string
}

variable "db_username_mongo" {
  description = "Username for MongoDB database user."
  type        = string
}

variable "db_password_mongo" {
  description = "Password for MongoDB database user."
  type        = string
  sensitive   = true
}

