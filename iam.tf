resource "aws_iam_role" "app_role" {
  name = "app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Rozdział 5.8.2 pracy — polityka roli IAM PO REMEDIACJI.
# Zawężono uprawnienia z Action: "*", Resource: "*" do konkretnych
# akcji i zasobów faktycznie wymaganych przez aplikację (przykład:
# odczyt/zapis wyłącznie do bucketu app_data).
resource "aws_iam_role_policy" "app_role_policy" {
  name = "app-scoped-access"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
      ]
      Resource = [
        aws_s3_bucket.app_data.arn,
        "${aws_s3_bucket.app_data.arn}/*",
      ]
    }]
  })
}
