# RDS Module

# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${var.environment}-db-subnet-group"
  description = "Database subnet group for ${var.environment}"
  subnet_ids  = var.subnet_ids

  tags = {
    Environment = var.environment
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.security_groups
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.storage_size
  storage_encrypted     = true
  storage_type          = "gp3"
  max_allocated_storage = var.storage_size * 2

  db_name  = var.database_name
  username = var.database_user
  password = var.database_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.environment == "production" ? 30 : 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = var.environment != "production"

  performance_insights_enabled          = true
  performance_insights_retention_period = var.environment == "production" ? 31 : 7

  enabled_cloudwatch_logs_exports = ["postgresql"]

  deletion_protection = var.environment == "production"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}