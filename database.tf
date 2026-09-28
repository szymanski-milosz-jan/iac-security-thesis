# Rozdział 5.8.2 pracy — moduł bazy danych RDS PO REMEDIACJI.
# Wyłączono publiczną dostępność, włączono szyfrowanie, ochronę przed
# usunięciem oraz tryb Multi-AZ.

resource "aws_db_instance" "app_db" {
  identifier        = "app-db-prod"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  username = "dbadmin"
  password = var.db_password # bez wartości domyślnej — patrz variables.tf

  publicly_accessible = false
  storage_encrypted   = true
  deletion_protection = true
  multi_az            = true
  skip_final_snapshot  = false
  final_snapshot_identifier = "app-db-prod-final"

  vpc_security_group_ids = [aws_security_group.app.id]

  # Dodatkowe dobre praktyki odnotowane w rozdz. 5.8.2 jako naruszenia
  # spoza formalnego zbioru referencyjnego (CKV_AWS_161, CKV_AWS_118):
  iam_database_authentication_enabled = true
  monitoring_interval                 = 60
}
