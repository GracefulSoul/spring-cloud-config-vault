# Spring Cloud Config Server와 Vault 통합 샘플 프로젝트

이 프로젝트는 Spring Cloud Config Server와 HashiCorp Vault를 통합하여 분산 시스템에서 설정을 관리하는 방법을 보여줍니다. **멀티 모듈 구조**로 구성되어 있습니다.

## 프로젝트 구조

```
spring-cloud-config-vault/                    # 부모 프로젝트 (Multi-Module)
├── pom.xml                                   # 부모 POM (의존성 관리)
│   └── 공통 속성 정의
│   └── 의존성 버전 관리
│   └── 플러그인 설정
│
├── config-server/                            # 모듈 1: Config Server
│   ├── pom.xml                               # 부모 POM 참조
│   ├── src/main/java/com/example/configserver/
│   │   └── ConfigServerApplication.java
│   └── src/main/resources/application.yml
│
├── client-app/                               # 모듈 2: Client Application
│   ├── pom.xml                               # 부모 POM 참조
│   ├── src/main/java/com/example/clientapp/
│   │   ├── ClientAppApplication.java
│   │   ├── config/AppProperties.java
│   │   └── controller/ConfigController.java
│   └── src/main/resources/
│       ├── bootstrap.yml                     # Config Server & Vault 연결
│       └── application.yml                   # 기본 설정
│
└── vault-config/                             # Vault 설정 및 초기화
    ├── vault-config.yml
    ├── client-app.yml (공통 설정)
    ├── client-app-dev.yml (개발 환경)
    ├── client-app-prod.yml (프로덕션 환경)
    ├── init-vault.sh (Linux/Mac)
    └── init-vault.ps1 (Windows)
```

## 사전 요구사항

- Java 17 이상
- Maven 3.6 이상
- Docker (Vault 실행용, 또는 Vault 바이너리 설치)

## 설치 및 실행

### 1. Vault 시작

#### Docker를 사용하는 경우:
```bash
docker run --name vault -d \
  -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID="s.xxxxxxxxxxxxxxxx" \
  vault:latest
```

#### Vault 바이너리를 사용하는 경우:
```bash
vault server -dev
```

### 2. Vault 초기화

**Linux/Mac:**
```bash
cd vault-config
chmod +x init-vault.sh
./init-vault.sh
```

**Windows:**
```powershell
cd vault-config
.\init-vault.ps1
```

### 3. 전체 프로젝트 빌드 (멀티 모듈)

```bash
# 부모 디렉토리에서 빌드
cd spring-cloud-config-vault
mvn clean install

# 빌드 결과
# - config-server/target/spring-cloud-config-server-1.0.0.jar
# - client-app/target/spring-cloud-config-client-app-1.0.0.jar
```

특정 모듈만 빌드하려면:
```bash
# config-server 모듈만 빌드
mvn clean install -pl config-server

# client-app 모듈만 빌드
mvn clean install -pl client-app

# 병렬 빌드 (성능 향상)
mvn clean install -T 1.0C
```

### 4. Config Server 시작

```bash
cd config-server
mvn spring-boot:run

# 또는 JAR 파일로 실행
java -jar target/spring-cloud-config-server-1.0.0.jar
```

Config Server는 http://localhost:8888에서 실행됩니다.

### 5. Client Application 시작

```bash
# 새 터미널에서
cd client-app
mvn spring-boot:run

# 또는 JAR 파일로 실행
java -jar target/spring-cloud-config-client-app-1.0.0.jar
```

Client Application은 http://localhost:8080에서 실행됩니다.

## API 엔드포인트

### Config 확인
```bash
curl http://localhost:8080/api/config/properties
curl http://localhost:8080/api/config/status
```

### Actuator 엔드포인트
```bash
# Health 확인
curl http://localhost:8080/actuator/health

# 현재 설정값 확인
curl http://localhost:8080/actuator/configprops

# 환경 변수 확인
curl http://localhost:8080/actuator/env
```

## 멀티 모듈 프로젝트 구조 설명

### 부모 POM (pom.xml)

부모 POM은 다음과 같은 역할을 담당합니다:

```xml
<!-- 1. 모듈 선언 -->
<modules>
    <module>config-server</module>
    <module>client-app</module>
</modules>

<!-- 2. 공통 속성 정의 -->
<properties>
    <java.version>17</java.version>
    <spring-boot.version>3.1.8</spring-boot.version>
    <spring-cloud.version>2022.0.4</spring-cloud.version>
</properties>

<!-- 3. 의존성 관리 (버전 일관성 보장) -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>${spring-cloud.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### 모듈 POM 구조

각 모듈은 부모 POM을 상속하며 간단하게 구성됩니다:

**config-server/pom.xml:**
```xml
<parent>
    <groupId>com.gracefulsoul</groupId>
    <artifactId>spring-cloud-config-vault</artifactId>
    <version>1.0.0</version>
    <relativePath>..</relativePath>
</parent>

<artifactId>spring-cloud-config-server</artifactId>

<!-- 의존성에 버전 명시 불필요 (부모에서 관리) -->
<dependencies>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-config-server</artifactId>
    </dependency>
</dependencies>
```

### 빌드 순서

Maven은 자동으로 의존성을 파악하여 빌드 순서를 결정합니다:

```
부모 POM (pom.xml)
    ↓
config-server (먼저 빌드) → client-app (의존할 수 있음)
    ↓
전체 프로젝트 빌드 완료
```

### 멀티 모듈의 장점

- **의존성 관리 통합**: 부모에서 모든 버전 관리
- **빌드 간편화**: 부모 디렉토리에서 한 명령으로 전체 빌드
- **설정 공유**: 공통 플러그인, 속성 모든 모듈 상속
- **버전 일관성**: 모든 모듈이 동일한 라이브러리 버전 사용
- **확장성**: 새로운 모듈 추가 용이

---

### Spring Cloud Config Server
- Git 저장소 기반 설정 관리
- 프로필별 설정 지원 (dev, prod 등)
- 실시간 설정 업데이트
- RESTful API를 통한 설정 조회

### Vault 통합
- 민감한 정보 (패스워드, API 키) 관리
- 자동 인증서 관리
- 감사 로그 기록
- 다양한 인증 방식 지원 (Token, AppRole, Kubernetes, LDAP 등)

## 설정 우선순위

Spring Cloud Config와 Vault를 함께 사용할 때의 설정 로드 순서:

1. `bootstrap.yml` / `bootstrap.properties` - Config Server 및 Vault 연결 설정
2. Vault에서 로드한 민감한 정보
3. Config Server에서 로드한 설정
4. `application.yml` / `application.properties` - 애플리케이션 기본 설정

## 환경 변수

클라이언트 애플리케이션 실행 시 다음 환경 변수를 설정할 수 있습니다:

```bash
export ENVIRONMENT=development
export DATABASE_URL=jdbc:postgresql://localhost:5432/myapp_db
export DATABASE_USER=appuser
export DATABASE_PASSWORD=password123
export JWT_SECRET=my-secret-key
export API_KEY=my-api-key

cd client-app
mvn spring-boot:run
```

## 주요 코드 설명

### Config Server 활성화
```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
```

### Config 속성 주입
```java
@Component
@ConfigurationProperties(prefix = "app")
@Data
public class AppProperties {
    private String name;
    private String version;
    private String environment;
    private Database database = new Database();
    private Security security = new Security();
}
```

### 개별 속성 주입
```java
@Value("${app.name:Not Set}")
private String appName;

@Value("${app.database.url}")
private String databaseUrl;
```

## Config Server 설정 조회

```bash
# 기본 설정
curl http://localhost:8888/client-app/default

# 개발 환경 설정
curl http://localhost:8888/client-app/dev

# 프로덕션 환경 설정
curl http://localhost:8888/client-app/prod

# YAML 형식
curl http://localhost:8888/client-app-dev.yml
```

## Vault에서 비밀 조회

```bash
# 로그인
vault login s.xxxxxxxxxxxxxxxx

# 데이터베이스 자격증명 확인
vault kv get secret/data/client-app/database

# 보안 설정 확인
vault kv get secret/data/client-app/security

# 모든 비밀 목록
vault kv list secret/data/client-app
```

## 문제 해결

### Config Server에 연결할 수 없음
- Config Server가 실행 중인지 확인: `http://localhost:8888/actuator/health`
- `bootstrap.yml`의 `spring.cloud.config.uri` 확인

### Vault에 연결할 수 없음
- Vault 서버가 실행 중인지 확인: `vault status`
- Token이 유효한지 확인
- `bootstrap.yml`의 Vault 호스트, 포트, 토큰 확인

### 민감한 정보가 로드되지 않음
- Vault에 비밀이 저장되어 있는지 확인: `vault kv list secret/data/client-app`
- 경로가 올바른지 확인 (예: `secret/data/client-app/database`)

## 참고자료

- [Spring Cloud Config 공식 문서](https://spring.io/projects/spring-cloud-config){:target="_blank"}
- [Spring Cloud Vault 공식 문서](https://spring.io/projects/spring-cloud-vault){:target="_blank"}
- [HashiCorp Vault 공식 문서](https://www.vaultproject.io/docs){:target="_blank"}
- [Spring Boot Configuration Properties](https://spring.io/projects/spring-boot){:target="_blank"}

## 라이선스

MIT License
