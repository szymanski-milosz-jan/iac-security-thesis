# Rozdział 5.3.3 pracy — rejestracja GitHub jako dostawcy tożsamości OIDC.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Rozdział 5.3.4 pracy — rola tf-plan-role.
# Używana przez workflow ci-security.yml (zdarzenie pull_request),
# ograniczona wyłącznie do uprawnień odczytu.
resource "aws_iam_role" "tf_plan_role" {
  name = "tf-plan-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:pull_request"
        }
      }
    }]
  })
}

# Polityka tylko do odczytu, zgodnie z opisem w rozdz. 5.3.4
# (iam:Get*, iam:List*, s3:GetObject, ec2:Describe* — zawężone do
# usług wykorzystywanych przez moduł; dostosuj do realnego zakresu
# zasobów przed użyciem produkcyjnym).
resource "aws_iam_role_policy" "tf_plan_role_policy" {
  name = "tf-plan-readonly"
  role = aws_iam_role.tf_plan_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:Get*",
        "iam:List*",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetBucket*",
        "ec2:Describe*",
        "rds:Describe*",
      ]
      Resource = "*"
    }]
  })
}

# Rozdział 5.3.4 pracy — rola tf-apply-role.
# Używana wyłącznie przez workflow cd-apply.yml, uruchamiany po
# scaleniu zmian do gałęzi main (warunek sub ograniczony do
# ref:refs/heads/main). Dokładna treść polityki zaufania zgodna
# z listingiem JSON z rozdz. 5.3.4.
resource "aws_iam_role" "tf_apply_role" {
  name = "tf-apply-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

# Uprawnienia do tworzenia/modyfikacji zasobów wykorzystywanych przez
# moduł (S3, EC2/VPC, IAM, RDS). Poniższe zarządzane polityki AWS mają
# charakter ilustracyjny (szeroki zakres) — przed użyciem produkcyjnym
# zaleca się zawężenie do polityki customer-managed z konkretnymi
# akcjami, zgodnie z zasadą najmniejszych uprawnień.
resource "aws_iam_role_policy_attachment" "tf_apply_s3" {
  role       = aws_iam_role.tf_apply_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "tf_apply_ec2" {
  role       = aws_iam_role.tf_apply_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "tf_apply_iam" {
  role       = aws_iam_role.tf_apply_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "tf_apply_rds" {
  role       = aws_iam_role.tf_apply_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}
