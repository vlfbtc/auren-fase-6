# Auren Web Dashboard (Angular)

Este projeto é um painel administrativo web desenvolvido em Angular 18 + Vite.

## Tecnologias
- **Angular 18**
- **Vite**
- **SCSS**
- **HttpClient**

## Arquitetura
- Standalone app, hash routing
- Componentes standalone, roteamento, guards, interceptors
- SafeStorage para SSR/tests
- Serviços: AuthService, TransactionsService, InsightsService

## Funcionalidades
- **Login**: Formulário, feedback de erro
- **Home**: Resumo, navegação, *ngIf, *ngFor
- **Admin**: Listagem, edição e exclusão de transações
- **Formulário de Transação**: Campos editáveis, data, tipo, categoria, valor
- **Insights**: Recomendações, dicas, conteúdos
- **UX**: Layout limpo, feedbacks de loading/erro, mensagens claras

## Como rodar
1. Instale o [Node.js 18+](https://nodejs.org/).
2. No diretório `auren angular/auren`, execute:
	```sh
	npm install
	npm start
	```
3. Acesse em: [http://localhost:4200](http://localhost:4200)

## Configurações
- Hash routing habilitado (evita erros de rota).
- Interceptor injeta token JWT nas requisições.
- Variáveis e endpoints configuráveis em `environments/`.
