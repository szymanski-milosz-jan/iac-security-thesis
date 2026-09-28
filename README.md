# Projekt: Automatyzacja testów bezpieczeństwa IaC — kompletny kod

Ten katalog zawiera **pełną, odtworzoną wersję** wszystkich fragmentów kodu
opisanych w pracy inżynierskiej (rozdz. 5.3–5.6), w tym dwa zasoby, które
w treści pracy są tylko referencjonowane, a nigdy jawnie zdefiniowane
(`aws_vpc.main`, `aws_iam_role.app_role`) — zostały tu uzupełnione minimalnymi,
poprawnymi definicjami, żeby moduł faktycznie dało się zainicjalizować
i zwalidować.

## Struktura

```
.
├── vulnerable/              ← moduł z 12 celowymi błędami (rozdz. 5.4)
│   ├── versions.tf          ← backend S3 z natywną blokadą (rozdz. 5.3.2)
│   ├── versions.dynamodb.tf.example  ← alternatywny backend (Terraform < 1.10)
│   ├── variables.tf
│   ├── s3.tf                ← rozdz. 5.4.1
│   ├── network.tf           ← rozdz. 5.4.2 (+ aws_vpc uzupełniony)
│   ├── iam.tf                ← rozdz. 5.4.3 (+ aws_iam_role uzupełniony)
│   ├── database.tf          ← rozdz. 5.4.4
│   ├── oidc.tf               ← rozdz. 5.3.3-5.3.4 (provider + role IAM)
│   └── .checkov.yaml         ← rozdz. 5.5.1
├── remediated/               ← ten sam moduł po naniesieniu poprawek (rozdz. 5.8.2)
│   └── (te same pliki, z usuniętymi błędami)
└── .github/workflows/
    ├── ci-security.yml       ← rozdz. 5.6.2 (wersja poprawiona)
    └── cd-apply.yml           ← rozdz. 5.6.3
```

## Jak z tego skorzystać (razem z przewodnikiem konfiguracji)

Workflowy (`ci-security.yml`, `cd-apply.yml`) oczekują plików `.tf`
bezpośrednio w katalogu głównym repozytorium (`directory: .`), więc katalogi
`vulnerable/` i `remediated/` **nie mogą współistnieć w repo jednocześnie** —
to dwa warianty tego samego modułu do użycia w różnych momentach testu,
zgodnie z Częściami E–H przewodnika konfiguracji:

1. **Repozytorium główne (branch `main`)** — skopiuj do niego zawartość
   `remediated/` (to jest "czysty", bezpieczny stan wyjściowy) oraz cały
   folder `.github/workflows/`:
   ```bash
   cp remediated/*.tf remediated/.checkov.yaml .
   cp -r .github <docelowe-repo>/
   ```
2. **Branch testowy z błędami** (Część H przewodnika, dowód do 5.8.1/5.6):
   ```bash
   git checkout -b test/with-errors
   cp vulnerable/*.tf .
   git add -A && git commit -m "test: wprowadzenie 12 celowych błędów"
   git push -u origin test/with-errors
   gh pr create --base main --head test/with-errors
   ```
   Poczekaj na czerwony status `security-scan` → to jest dowód do tabeli 5.3.
3. **Remediacja na tym samym branchu** (dowód do 5.8.2):
   ```bash
   cp remediated/*.tf .
   git add -A && git commit -m "fix: remediacja 12 błędów bezpieczeństwa"
   git push
   ```
   Poczekaj na zielony status → zmerguj PR → `cd-apply.yml` uruchomi się
   automatycznie na `main`.

Do lokalnych testów Checkov (Część E–G przewodnika) możesz odwoływać się
do `vulnerable/` i `remediated/` bezpośrednio, bez kopiowania:
```bash
checkov -d vulnerable/ --framework terraform --compact
checkov -d remediated/ --framework terraform --compact
```

## Przed pierwszym `terraform init`

1. Utwórz bucket S3 na stan (Część B przewodnika) i podmień jego nazwę
   w `versions.tf`, jeśli używasz innej niż `acme-terraform-state-prod`.
2. Utwórz dostawcę OIDC i role IAM (Część C przewodnika) — albo ręcznie
   w konsoli, albo deklaratywnie przez `oidc.tf` (wymaga jednak wstępnego
   uwierzytelnienia kontem administracyjnym, żeby móc wdrożyć same role).
3. Ustaw zmienne: `terraform.tfvars` lub `-var` z `aws_account_id`,
   `github_org`, `github_repo`, `db_password` (wersja `remediated/` wymaga
   `db_password` bez wartości domyślnej — patrz `variables.tf`).
4. Ustaw zmienne repozytorium GitHub oraz branch protection / environment
   `production` (Część D przewodnika).

## Uwaga dot. uprawnień w `oidc.tf`

Polityki dołączone do `tf-apply-role` (`AmazonS3FullAccess`,
`AmazonEC2FullAccess`, `IAMFullAccess`, `AmazonRDSFullAccess`) mają
charakter **ilustracyjny i celowo szeroki**, żeby moduł zadziałał od razu
bez dodatkowego dopracowywania uprawnień. Przed jakimkolwiek użyciem poza
środowiskiem testowym pracy zawęź je do polityki customer-managed
z konkretnymi akcjami wymaganymi przez ten moduł (zasada najmniejszych
uprawnień, o której pisze rozdz. 3.1 i 5.3.4 pracy).

## Powiązane materiały

Pełny opis kroków konfiguracyjnych (konsola AWS, GitHub, zbieranie
dowodów/screenshotów) znajduje się w osobnym przewodniku
(`przewodnik_konfiguracji_dowody.md`) przygotowanym wcześniej w tej samej
rozmowie.
