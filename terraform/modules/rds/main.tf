resource "aws_db_subnet_group" "this"{
    name = "${var.environment}-db-subnet-group"
    subnet_ids = var.database_subnet_ids
    tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_instance" "this" {
    identifier = "${var.environment}-postgres"
    engine = "postgres"
    engine_version = var.engine_version
    instance_class = var.db_instance_class
    allocated_storage = 20
    storage_type = "gp3"
    storage_encrypted = true
    db_name = var.db_name
    username = var.db_username
    manage_master_user_password = true
    db_subnet_group_name = aws_db_subnet_group.this.name
    vpc_security_group_ids = [
    var.security_group_id
  ]
    publicly_accessible = false
    backup_retention_period = 7
    backup_window = "03:00-04:00"
    maintenance_window = "sun:04:00-sun:05:00"
    deletion_protection = false
    skip_final_snapshot = true
    multi_az = false
    tags = {
    Name        = "${var.environment}-postgres"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }


}