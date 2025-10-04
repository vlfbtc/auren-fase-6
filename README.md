# Auren Fase 6 — Monorepo

Repositório monolítico contendo três projetos integrados para uma solução de educação financeira personalizada:

- **App Mobile Flutter** (`auren flutter/auren`): Aplicativo multiplataforma (Android/iOS) com arquitetura BLoC, gráficos, insights e integração com backend REST.
- **Backend Spring Boot** (`auren backend/auren`): API RESTful segura, com autenticação JWT, integração com IA Gemini, persistência em banco relacional (H2/Oracle), **integração Oracle PL/SQL** com procedures/functions avançadas, e documentação Swagger.
- **Painel Web Angular** (`auren angular/auren`): Dashboard administrativo para gestão de usuários, transações e insights, com autenticação, guards e integração ao backend.

---

## Estrutura do Repositório

```
/auren-fase-6
├── auren flutter/
│   └── auren/           # App mobile Flutter
├── auren backend/
│   └── auren/           # Backend Spring Boot
├── auren angular/
│   └── auren/           # Painel web Angular
└── README.md            # Este arquivo
```

---

## Como rodar cada projeto

### 1. App Mobile Flutter

1. Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. No diretório `auren flutter/auren`, execute:
   ```sh
   flutter pub get
   flutter run
   ```

Mais detalhes: [`auren flutter/auren/README.md`](auren%20flutter/auren/README.md)

---

### 2. Backend Spring Boot

#### Perfil Padrão (H2)
1. Instale o [Java 21+]
2. No diretório `auren backend/auren`, execute:
   ```sh
   ./mvnw spring-boot:run
   ```
3. Configure a variável de ambiente `GEMINI_API_KEY` para integração com IA (opcional)
4. Acesse a documentação Swagger em [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

#### Perfil Oracle (Novo!)
1. **Suba o Oracle XE via Docker:**
   ```sh
   docker run -d --name oracle-xe -p 1521:1521 -e ORACLE_PASSWORD=auren_pass gvenzl/oracle-xe:21-slim
   ```

2. **Aplique o schema e seed:**
   ```sh
   # Conectar como auren_user (usuário) com auren_pass (senha)
   sql -L auren_user/auren_pass@localhost:1521/XEPDB1 @db/oracle/01-schema-v2.sql
   sql -L auren_user/auren_pass@localhost:1521/XEPDB1 @scripts/oracle/02-seed-user.sql
   ```

3. **Execute com perfil Oracle:**
   ```sh
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=oracle
   ```

**Recursos Oracle PL/SQL:**
- **Functions:** `get_monthly_balance()`, `get_tx_summary_json()`
- **Procedures:** `get_category_report()`, `log_high_value_tx()`
- **Scripts de validação:** PowerShell (`04-validate-plsql.ps1`)
- **Alertas automáticos** para transações acima de threshold

Mais detalhes: [`auren backend/auren/README.md`](auren%20backend/auren/README.md) | [`auren backend/db/README-ORACLE.md`](auren%20backend/db/README-ORACLE.md)

---

### 3. Painel Web Angular

1. Instale o [Node.js 18+](https://nodejs.org/)
2. No diretório `auren angular/auren`, execute:
   ```sh
   npm install
   npm start
   ```
3. Acesse em [http://localhost:4200](http://localhost:4200)

Mais detalhes: [`auren angular/auren/README.md`](auren%20angular/auren/README.md)

---

## Observações Gerais

- Cada projeto possui seu próprio `.gitignore` e README detalhado.
- O backend utiliza banco H2 para desenvolvimento, **Oracle XE com PL/SQL para produção/testes avançados**, e pode ser adaptado para PostgreSQL/MySQL.
- **Nova integração Oracle:** Procedures e functions PL/SQL para relatórios avançados, alertas automáticos e validações.
- O Flutter e o Angular consomem a mesma API REST do backend.
- Para integração completa, rode todos os projetos simultaneamente.
- **Scripts Oracle:** Automatização via PowerShell para setup, seed e validação PL/SQL.
