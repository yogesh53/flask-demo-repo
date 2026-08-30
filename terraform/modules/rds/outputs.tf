output "db_instance_endpoint"{
    value = aws_db_instance.this.endpoint
}
output "db_instance_address"{
    value = aws_db_instance.this.address
}
output "db_name"{
    value = aws_db_instance.this.db_name
}
output "port"{
    value = aws_db_instance.this.port
}
output "secret_arn"{
    value = aws_db_instance.this.master_user_secret[0].secret_arn
}
