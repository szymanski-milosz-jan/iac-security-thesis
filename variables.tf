variable "aws_region" {
  description = "Region AWS docelowy dla wdrożenia (rozdz. 5.1.2)."
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "Identyfikator konta AWS, w którym rejestrowany jest dostawca OIDC i role IAM (rozdz. 5.3.3-5.3.4)."
  type        = string
}

variable "github_org" {
  description = "Nazwa organizacji/użytkownika GitHub właściciela repozytorium (rozdz. 5.3.4)."
  type        = string
  default     = "acme-org"
}

variable "github_repo" {
  description = "Nazwa repozytorium GitHub (rozdz. 5.3.4)."
  type        = string
  default     = "iac-security-thesis"
}

variable "db_password" {
  description = "Hasło administratora RDS. W wersji zremediowanej NIE ma wartości domyślnej w kodzie — należy przekazać je z zewnętrznego źródła (AWS Secrets Manager, SSM Parameter Store typu SecureString lub zmienna TF_VAR_db_password ustawiana z sekretu CI), nigdy jako literał w repozytorium."
  type        = string
  sensitive   = true
}
