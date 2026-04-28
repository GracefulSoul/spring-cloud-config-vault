# Vault 초기화 및 설정 스크립트 (PowerShell)
# 이 스크립트는 Windows 환경에서 Vault를 초기화하고 비밀을 저장합니다.

Write-Host "Vault 상태 확인 중..." -ForegroundColor Green

try {
    vault status | Out-Null
} catch {
    Write-Host "Vault 서버가 실행 중이 아닙니다. 먼저 Vault를 시작하세요." -ForegroundColor Red
    Write-Host "실행: vault server -dev" -ForegroundColor Yellow
    exit 1
}

Write-Host "Vault 초기화 중..." -ForegroundColor Green

# 클라이언트 앱의 데이터베이스 자격증명 저장
Write-Host "데이터베이스 자격증명 저장..." -ForegroundColor Cyan
vault kv put secret/data/client-app/database `
    username="dbuser" `
    password="db-secure-password-2024" `
    url="jdbc:postgresql://localhost:5432/client_db" `
    maxPoolSize=20

# 클라이언트 앱의 보안 설정 저장
Write-Host "보안 설정 저장..." -ForegroundColor Cyan
vault kv put secret/data/client-app/security `
    jwtSecret="vault-managed-jwt-secret-key-xyz123" `
    jwtExpiration=86400000 `
    apiKey="vault-managed-api-key-abc456" `
    encryptionKey="vault-encryption-key-def789"

# 개발 환경용 설정 저장
Write-Host "개발 환경 설정 저장..." -ForegroundColor Cyan
vault kv put secret/data/client-app/dev `
    database.url="jdbc:postgresql://localhost:5432/myapp_dev" `
    database.username="dev_user" `
    database.password="dev_password_123" `
    logging.level="DEBUG"

# 프로덕션 환경용 설정 저장
Write-Host "프로덕션 환경 설정 저장..." -ForegroundColor Cyan
vault kv put secret/data/client-app/prod `
    database.url="jdbc:postgresql://prod-db.example.com:5432/myapp_prod" `
    database.username="prod_user" `
    database.password="prod_secure_password_xyz" `
    logging.level="INFO"

# OAuth2 자격증명 저장
Write-Host "OAuth2 자격증명 저장..." -ForegroundColor Cyan
vault kv put secret/data/oauth2 `
    google.client-id="your-google-client-id" `
    google.client-secret="your-google-client-secret" `
    github.client-id="your-github-client-id" `
    github.client-secret="your-github-client-secret"

# Third-party API 키 저장
Write-Host "Third-party API 키 저장..." -ForegroundColor Cyan
vault kv put secret/data/external-apis `
    slack.webhook-url="https://hooks.slack.com/services/YOUR/WEBHOOK/URL" `
    sendgrid.api-key="SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx" `
    aws.access-key="AKIAIOSFODNN7EXAMPLE" `
    aws.secret-key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

Write-Host "=============================================" -ForegroundColor Green
Write-Host "Vault 초기화 완료!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "저장된 비밀 확인:" -ForegroundColor Yellow
Write-Host "vault kv list secret/data/client-app"
Write-Host "vault kv get secret/data/client-app/database"
Write-Host "vault kv get secret/data/client-app/security"
