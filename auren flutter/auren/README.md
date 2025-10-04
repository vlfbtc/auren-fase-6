# Auren — App Mobile Flutter

Aplicativo mobile multiplataforma (Android/iOS) para educação financeira personalizada, desenvolvido em Flutter com arquitetura BLoC e integração REST.

---

## Principais Tecnologias

- **Flutter** (UI multiplataforma)
- **BLoC** (gerenciamento de estado)
- **REST API** (backend Spring Boot)
- **Pacotes:** flutter_bloc, fl_chart, http

---

## Arquitetura & Boas Práticas

- Estrutura em camadas: `features/*/domain | data | presentation`
- Repository Pattern para acesso a dados
- `TokenStorage` centralizado para sessão
- `ApiClient` com headers, query params e autenticação
- Tratamento consistente de erros e feedbacks via Snackbars

---

## Funcionalidades

- **Home:** Listagem real de transações, gráficos de barras (renda x despesa) e pizza (despesas por categoria), pull-to-refresh, loading e estados vazios
- **Transações:** Adição de transações (INCOME/EXPENSE), datas ISO, BigDecimal, refresh automático
- **Insights:** Recomendações, dicas e conteúdos (artigos, vídeos, podcasts) integrados ao backend e IA Gemini, fallback quando IA off
- **Refatorações:** Widgets desacoplados, logs úteis, mensagens claras de erro/vazio

---

## Como rodar o projeto

1. **Pré-requisitos:**  
   - [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
   - Emulador Android/iOS ou dispositivo físico

2. **Instale as dependências:**
   ```bash
   flutter pub get