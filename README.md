# ClinicDesk - Gerenciador de Tarefas

Projeto desenvolvido para a ClinicDesk com uma API de tarefas em Ruby on Rails e um front em Vue 3 (extra) para consumir a API.

## Visao geral

- API REST para gerenciar tarefas (CRUD)
- Validações de domínio e mensagens de erro padronizadas
- Filtros por status e due_date na listagem
- Front-end em Vue 3 com interface de criação, edição, listagem e remoção

## Stack

- Backend: Ruby on Rails (API)
- Banco: PostgreSQL
- Front-end: Vue 3 + Vite + TypeScript + Tailwind
- Infra local: Docker Compose

## Estrutura do repositório

- `apps/api`: API Ruby on Rails
- `apps/web`: Front-end Vue 3
- `docker-compose.yml`: orquestra banco, API e web
- `docker/postgres/init.sql`: cria bancos auxiliares do Rails

## API

### Endpoints

- `POST /tasks` cria tarefa
- `GET /tasks` lista tarefas (com filtros)
- `GET /tasks/:id` detalha tarefa
- `PATCH /tasks/:id` atualiza tarefa
- `DELETE /tasks/:id` remove tarefa

### Filtros

- `GET /tasks?status=pending`
- `GET /tasks?due_date=2026-02-20`

### Validacoes

- `title` obrigatorio e minimo 3 caracteres
- `status` obrigatorio e dentro de `pending`, `doing`, `done`

### Erros de validacao

Retorna HTTP 422 com o formato:

```json
{ "errors": ["mensagem de erro"] }
```

## Extras em Vue.js

- Tela unica para CRUD completo (criar, editar, listar, remover)
- Filtros por status e due_date com atualizacao da lista
- Edicao inline por item
- Tratamento de erros de validacao exibindo mensagens da API

## Como rodar com Docker

Requisitos: Docker e Docker Compose

Crie um `.env` na raiz (pode copiar de `.env.example`) para ajustar as variaveis do compose.

```bash
RAILS_MASTER_KEY=<sua_master_key> docker compose up --build
```

Servicos:

- API: `http://localhost:3000`
- Web: `http://localhost:8080`

## Rodar localmente (sem Docker)

### Backend

Requisitos: Ruby `3.4.8` e PostgreSQL

```bash
cd apps/api
cp .env.example .env
bundle install

# Caso nao tenha a master key, gere uma nova:
bin/rails credentials:edit

bin/rails db:create db:migrate
bin/rails server
```

### Front-end

Requisitos: Node 20+ e pnpm

```bash
cd apps/web
corepack enable
pnpm install
pnpm dev
```

Variaveis do front:

- `VITE_API_URL` (arquivo `apps/web/.env`) aponta para a API

## Exemplos de requisicoes

Criar tarefa:

```bash
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"task": {"title": "Estudar Rails", "status": "pending"}}'
```

Listar tarefas filtrando por status:

```bash
curl "http://localhost:3000/tasks?status=doing"
```

Atualizar tarefa:

```bash
curl -X PATCH http://localhost:3000/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"task": {"status": "done"}}'
```

## Testes

Este projeto ainda nao possui testes automatizados.

## Master key (importante)

A `config/master.key` nao fica versionada (esta no `.gitignore`).
Ao baixar o projeto, gere a sua com:

```bash
cd apps/api
bin/rails credentials:edit
```

Ou exporte a variavel `RAILS_MASTER_KEY` com a chave que voce tem.

## Deploy

Costumo fazer o deploy na minha propria estrutura VPS para aprendizado. Por isso, o ambiente pode ficar fora do ar em alguns momentos. Se precisar, me avise que eu verifico.

## Depois do front e backend

Front-end:

- Paginação e ordenacao por `due_date`
- Confirmacoes e estados de carregamento mais detalhados
- Melhorias de acessibilidade e responsividade

Back-end:

- Paginação e ordenacao nativas na API
- Testes mais abrangentes (requests e modelo)
- Autenticacao e auditoria de alteracoes
