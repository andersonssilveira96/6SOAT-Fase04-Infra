# Recurso para criar o Security Group 
resource "aws_security_group" "db_sg" {  
  name = "db_sg"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "db_sg" {

  engine                 = "postgres"
  engine_version         = "14"
  db_name                = var.db_name
  identifier             = var.db_name
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  publicly_accessible    = true
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true

  lifecycle {
    ignore_changes = [db_name]
  }

  tags = {
    Name = var.db_name
  }
}
