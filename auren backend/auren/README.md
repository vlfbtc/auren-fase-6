# Auren Backend (Spring Boot)

Este projeto é um backend escalável para gestão financeira, desenvolvido em Java 21 com Spring Boot 3.

## Tecnologias
- **Java 21**
- **Spring Boot 3** (MVC, Security, JPA/Hibernate)
- **H2 Database** (dev)
- **OpenAPI/Swagger**
- **JWT** (autenticação)

## Arquitetura
- Camadas: Controller → Service → Repository → Entity
- Entidades: User, Transaction, InsightSnapshot
- Tratamento de erros padronizado
- Documentação automática via Swagger

## Funcionalidades
- **Transações**: CRUD completo, queries paginadas e por período
- **Insights**: IA Gemini (Google), snapshots persistidos, fallback seguro
- **Segurança**: JWT, autorização por userId, headers Authorization
- **Validações**: @Valid, enums, logs úteis

## Endpoints Principais
- **Auth**:
  - POST `/api/v1/auth/verify-pin`
  - POST `/api/v1/auth/signup`
  - POST `/api/v1/auth/refresh`
  - POST `/api/v1/auth/login`
  - POST `/api/v1/auth/create-password`
- **Transactions**:
  - GET `/api/v1/users/{userId}/transactions?from=&to=&limit=`
  - POST `/api/v1/users/{userId}/transactions`
  - PUT `/api/v1/users/{userId}/transactions/{id}`
  - DELETE `/api/v1/users/{userId}/transactions/{id}`
- **Insights**:
  - GET `/api/v1/users/{userId}/insights?months=6&topN=10&refresh=true|false`

## Como rodar
1. Instale o [Java 21+]
2. Configure a variável de ambiente `GEMINI_API_KEY` (ou utiliza a que mantive hardcoded para validação)
3. No diretório `auren backend/auren`, execute:
   ```sh
   ./mvnw spring-boot:run
   ```

   ou via spring boot dashboard (se VSCode)
4. Acesse o Swagger em: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

## Configurações
- Banco H2 em memória (dev). Para produção, configure PostgreSQL/MySQL.
- Propriedades em `src/main/resources/application-local.properties`.
