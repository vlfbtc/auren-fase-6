# Auren Fase 6 — Monorepo

Repositório monolítico contendo três projetos integrados para uma solução de educação financeira personalizada:

- **App Mobile Flutter** (`auren flutter/auren`): Aplicativo multiplataforma (Android/iOS) com arquitetura BLoC, gráficos, insights e integração com backend REST.
- **Backend Spring Boot** (`auren backend/auren`): API RESTful segura, com autenticação JWT, integração com IA Gemini, persistência em banco relacional e documentação Swagger.
- **Painel Web Angular** (`auren angular/auren`): Dashboard administrativo para gestão de usuários, transações e insights, com autenticação, guards e integração ao backend.

---

## Estrutura do Repositório

```
/auren-fase-5
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

1. Instale o [Java 21+]
2. No diretório `auren backend/auren`, execute:
   ```sh
   ./mvnw spring-boot:run
   ```
3. Configure a variável de ambiente `GEMINI_API_KEY` para integração com IA (opcional)
4. Acesse a documentação Swagger em [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

Mais detalhes: [`auren backend/auren/README.md`](auren%20backend/auren/README.md)

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
- O backend utiliza banco H2 para desenvolvimento, mas pode ser facilmente adaptado para PostgreSQL/MySQL.
- O Flutter e o Angular consomem a mesma API REST do backend.
- Para integração completa, rode todos os projetos simultaneamente.
