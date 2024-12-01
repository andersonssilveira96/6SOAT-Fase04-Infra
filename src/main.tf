provider "aws" {
 region = "us-east-1"
}

terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.20.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

# Criar projeto
resource "mongodbatlas_project" "project" {
  name   = var.project_name
  org_id = "6747bd9905b12d07fd142691"
}

# Criar usuário do banco de dados
resource "mongodbatlas_database_user" "db_user" {
  project_id           = mongodbatlas_project.project.id
  username             = var.db_username_mongo
  password             = var.db_password_mongo
  auth_database_name   = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}

# Permitir acesso ao cluster (configuração básica para teste)
resource "mongodbatlas_project_ip_access_list" "access_list" {
  project_id = mongodbatlas_project.project.id
  cidr_block = "0.0.0.0/0" # Permite acesso de qualquer IP (não recomendado em produção)
}

# Criar cluster
resource "mongodbatlas_cluster" "cluster" {
  project_id              = mongodbatlas_project.project.id
  name                        = var.cluster_name

  # Provider Settings "block"
  provider_name = "TENANT"
  backing_provider_name = "AWS"
  provider_region_name = "US_EAST_1"
  provider_instance_size_name = "M0"
}