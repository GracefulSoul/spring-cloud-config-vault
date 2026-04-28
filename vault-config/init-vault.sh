#!/bin/bash

# Vault 초기화 및 설정 스크립트
# 이 스크립트는 Vault를 초기화하고 비밀을 저장합니다.

# Vault 서버가 실행 중인지 확인
echo "Vault 상태 확인 중..."
vault status > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Vault 서버가 실행 중이 아닙니다. 먼저 Vault를 시작하세요."
    echo "실행: vault server -dev"
    exit 1
fi

echo "Vault 초기화 중..."

# 클라이언트 앱의 데이터베이스 자격증명 저장
echo "데이터베이스 자격증명 저장..."
vault kv put secret/data/client-app/database \
    username="dbuser" \
    password="db-secure-password-2024" \
    url="jdbc:postgresql://localhost:5432/client_db" \
    maxPoolSize=20

# 클라이언트 앱의 보안 설정 저장
echo "보안 설정 저장..."
vault kv put secret/data/client-app/security \
    jwtSecret="vault-managed-jwt-secret-key-xyz123" \
    jwtExpiration=86400000 \
    apiKey="vault-managed-api-key-abc456" \
    encryptionKey="vault-encryption-key-def789"

# 개발 환경용 설정 저장
echo "개발 환경 설정 저장..."
vault kv put secret/data/client-app/dev \
    database.url="jdbc:postgresql://localhost:5432/myapp_dev" \
    database.username="dev_user" \
    database.password="dev_password_123" \
    logging.level="DEBUG"

# 프로덕션 환경용 설정 저장
echo "프로덕션 환경 설정 저장..."
vault kv put secret/data/client-app/prod \
    database.url="jdbc:postgresql://prod-db.example.com:5432/myapp_prod" \
    database.username="prod_user" \
    database.password="prod_secure_password_xyz" \
    logging.level="INFO"

# OAuth2 자격증명 저장
echo "OAuth2 자격증명 저장..."
vault kv put secret/data/oauth2 \
    google.client-id="your-google-client-id" \
    google.client-secret="your-google-client-secret" \
    github.client-id="your-github-client-id" \
    github.client-secret="your-github-client-secret"

# Third-party API 키 저장
echo "Third-party API 키 저장..."
vault kv put secret/data/external-apis \
    slack.webhook-url="https://hooks.slack.com/services/YOUR/WEBHOOK/URL" \
    sendgrid.api-key="SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
    aws.access-key="AKIAIOSFODNN7EXAMPLE" \
    aws.secret-key="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

echo "=============================================="
echo "Vault 초기화 완료!"
echo "=============================================="
echo ""
echo "저장된 비밀 확인:"
echo "vault kv list secret/data/client-app"
echo "vault kv get secret/data/client-app/database"
echo "vault kv get secret/data/client-app/security"
