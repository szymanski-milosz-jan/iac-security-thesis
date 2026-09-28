# Rozdział 5.8.2 pracy — moduł magazynu danych S3 PO REMEDIACJI.
# Usunięto publiczne ACL, włączono blokadę publicznego dostępu,
# dodano z powrotem pominięte wcześniej zasoby aws_s3_bucket_versioning
# oraz aws_s3_bucket_server_side_encryption_configuration.
# (Te dwa dodane zasoby tłumaczą wzrost liczby zasobów modułu z 8 do 10
# po remediacji — patrz rozdz. 5.8.2 poprawionej wersji pracy.)

resource "aws_s3_bucket" "app_data" {
  bucket = "acme-aplikacja-dane-prod"
}

resource "aws_s3_bucket_public_access_block" "app_data_pab" {
  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app_data_versioning" {
  bucket = aws_s3_bucket.app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data_encryption" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Dodatkowe dobre praktyki spoza formalnego zbioru referencyjnego
# (odnotowane jako dodatkowe naruszenia w rozdz. 5.8.2: CKV_AWS_18 —
# logowanie dostępu S3). Odkomentuj, jeśli chcesz w pełni wyzerować
# także te naruszenia:
#
# resource "aws_s3_bucket_logging" "app_data_logging" {
#   bucket        = aws_s3_bucket.app_data.id
#   target_bucket = aws_s3_bucket.access_logs.id
#   target_prefix = "app-data/"
# }
