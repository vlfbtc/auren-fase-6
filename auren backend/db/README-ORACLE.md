# Smart HAS / Auren — Perfil Oracle

Este README descreve como subir o **Oracle XE**, aplicar o **schema + seed**, e rodar o backend com o **profile `oracle`**.

## 1. Pré‑requisitos
- Docker (para Oracle XE) ou um Oracle já disponível
- Java 21, Maven 3.9+
- (Opcional) SQL*Plus / SQLcl para executar scripts

## 2. Subir Oracle XE com Docker
```bash
docker run -d --name oracle-xe \
  -p 1521:1521 -e ORACLE_PASSWORD=auren_pass \
  gvenzl/oracle-xe:21-slim
```

> Usuário padrão: `auren_user` / Senha: `auren_pass`.

## 3. Criar usuário/schema do projeto
Conecte no Oracle (SQL*Plus, SQLcl ou ferramenta gráfica) e crie o usuário do projeto (ex.: `SMART_HAS`).

```sql
CREATE USER SMART_HAS IDENTIFIED BY "smart_has_pass"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

GRANT CONNECT, RESOURCE TO SMART_HAS;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE TO SMART_HAS;
```

> Se você já possui scripts DDL (ex.: `01-schema-v2.sql`), rode-os **logado como SMART_HAS**.

## 4. Aplicar schema e seed
1) Execute `01-schema-v2.sql` (ou equivalente do projeto)  
2) Execute **`02-seed.sql`** (deste repositório)

Exemplo usando SQLcl:
```bash
sql -L SMART_HAS/smart_has_pass@localhost:1521/XEPDB1 @db/oracle/01-schema-v2.sql
sql -L SMART_HAS/smart_has_pass@localhost:1521/XEPDB1 @db/oracle/02-seed.sql
```

> Ajuste o **service name** (ex.: `XEPDB1`) conforme sua imagem Oracle.

## 5. Configurar o backend (profile `oracle`)
No `application-oracle.properties`:
```
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/XEPDB1
spring.datasource.username=auren_user
spring.datasource.password=auren_pass
spring.jpa.hibernate.ddl-auto=validate
```

## 6. Rodar a aplicação
```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=oracle
# ou via Spring boot initializr
```

Acesse o **Swagger**:
```
http://localhost:8080/swagger-ui.html
```

## 7. Endpoints úteis
- `POST /api/v1/auth/login` ➜ obter JWT
- `GET  /api/v1/users/{id}/reports/monthly-balance?month=&year=`
- `GET  /api/v1/users/{id}/reports/category-report`
- `GET  /api/v1/users/{id}/reports/db-summary`
- `POST /api/v1/transactions` (cria transação; dispara procedure de alerta se ultrapassar threshold)
