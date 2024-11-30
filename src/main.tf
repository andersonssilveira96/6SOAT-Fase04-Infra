provider "aws" {
 region = "us-east-1"
}

terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1.7"
    }
  }
  required_version = ">= 1.0.0"
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

resource "mongodbatlas_project" "project" {
  name = var.project_name
  org_id = "6747bd9905b12d07fd142691" 
}

resource "mongodbatlas_cluster" "cluster" {
  project_id   = mongodbatlas_project.project.id
  name         = var.cluster_name
  provider_name = "AWS"
  provider_region_name = var.region
  cluster_type = "SHARDED"
  mongo_db_major_version = "6.0"
  provider_instance_size_name = "M10" # Escolha o tamanho da instância (ex.: M10, M20)

  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }

  disk_size_gb           = 10
  backup_enabled         = true
}

resource "mongodbatlas_database_user" "db_user" {
  project_id    = mongodbatlas_project.project.id
  username      = var.db_username
  password      = var.db_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }

  scopes {
    type = "CLUSTER"
    name = mongodbatlas_cluster.cluster.name
  }
}

resource "mongodbatlas_network_container" "network" {
  project_id      = mongodbatlas_project.project.id
  atlas_cidr_block = "192.168.0.0/24"
  provider_name   = "AWS"
  region_name     = var.region
}

resource "mongodbatlas_project_ip_access_list" "access_list" {
  project_id = mongodbatlas_project.project.id
  cidr_block = "0.0.0.0/0" # Permite acesso de qualquer IP
}

resource "aws_cognito_user_pool" "techchallenge-userspool" {
  name = "techchallenge-userspool"

  # Configuração da política de senha
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  alias_attributes         = ["email", "preferred_username"]
  
  # Configuração dos tipos de autenticação permitidos
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  auto_verified_attributes = ["email"]

  # Adicionando o atributo customizado CPF
  schema {
    attribute_data_type      = "String"
    name                     = "custom:cpf"
    required                 = false
    mutable                  = true
    string_attribute_constraints {
      min_length = 11
      max_length = 11
    }
  }

  # Adicionando o atributo username
  schema {
    attribute_data_type      = "String"
    name                     = "username"
    required                 = false
    mutable                  = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_client" "techchallenge-usersclient" {
  name         = "techchallenge-usersclient"
  user_pool_id = aws_cognito_user_pool.techchallenge-userspool.id

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}
