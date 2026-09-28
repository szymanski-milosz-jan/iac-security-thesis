# Zasób bazowy aws_vpc — w treści pracy (rozdz. 5.4.2) referencjonowany
# jako aws_vpc.main.id, ale nigdy jawnie niezdefiniowany we fragmentach
# kodu. Dodany tu jako minimalna, poprawnie skonfigurowana sieć bazowa
# (NIE wchodzi w skład 12 celowych błędów referencyjnych z tabeli 5.4.5 —
# to jeden z ośmiu "czystych" zasobów uzupełniających moduł do liczby
# 8 zasobów wskazanej w rozdz. 5.8.1).
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "acme-app-vpc"
  }
}

# Rozdział 5.8.2 pracy — grupa bezpieczeństwa PO REMEDIACJI.
# Usunięto otwarte porty administracyjne SSH/RDP z 0.0.0.0/0; dostęp
# administracyjny ograniczono do zakresu sieci firmowej/VPN (przykładowy
# CIDR do zastąpienia realnym zakresem). Egress zawężono do ruchu HTTPS
# niezbędnego np. do pobierania aktualizacji pakietów.

variable "admin_cidr" {
  description = "Zaufany zakres CIDR dopuszczony do dostępu administracyjnego (VPN/biuro), zamiast 0.0.0.0/0."
  type        = string
  default     = "10.100.0.0/16" # PRZYKŁAD — zastąp realnym zakresem sieci zaufanej
}

resource "aws_security_group" "app" {
  name   = "app-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH wyłącznie z zaufanej sieci administracyjnej"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Ruch wychodzący HTTPS (aktualizacje, API AWS)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
