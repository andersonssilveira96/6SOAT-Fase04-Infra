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
}

resource "mongodbatlas_cluster" "cluster" {
  project_id   = mongodbatlas_project.project.id
  name         = var.cluster_name
  provider_name = "AWS"
  provider_region_name = var.region
  cluster_type = "SHARDED"
  mongo_db_major_version = "6.0"

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

resource "mongodbatlas_project_ip_whitelist" "whitelist" {
  project_id = mongodbatlas_project.project.id
  ip_address = "0.0.0.0/0" # Permite acesso de todos os IPs
}

