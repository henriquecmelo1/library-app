# 📖 Library App API

Uma **API RESTful completa** construída em **Ruby on Rails** para gerenciar uma **plataforma de biblioteca digital**.
Inclui **autenticação JWT**, **gerenciamento de materiais (com STI)**, **autores polimórficos**, **integração com API externa (Open Library)** e **cobertura de testes de 90% com RSpec**.

---

## 🧭 Tabela de Conteúdos

1. [✨ Funcionalidades Principais](#-funcionalidades-principais)
2. [🧱 Stack de Tecnologia](#-stack-de-tecnologia)
3. [⚙️ Instalação e Execução (Local)](#️-instalação-e-execução-local)
4. [🧪 Testes](#-testes)
5. [📡 Documentação da API (Endpoints)](#-documentação-da-api-endpoints)

   * 🔐 [Autenticação](#-autenticação)
   * 📘 [Materiais (Livros, Artigos, Vídeos)](#-materiais)
   * 👤 [Autores (Pessoa)](#-autores-pessoa)
   * 🏛️ [Autores (Instituição)](#-autores-instituição)
6. [🧭 Documentação Interativa (Postman)](#-documentação-interativa-postman)
7. [⚙️ Fluxos de Negócio Importantes](#️-fluxos-de-negócio-importantes)

   * 🛡️ [Autorização (Dono vs. Público)](#-autorização)
   * 📖 [Criação de Livro via ISBN](#-criação-de-livro-via-isbn)
8. [🗂️ Estrutura do Projeto](#️-estrutura-do-projeto)
9. [🚀 Próximos Passos](#-próximos-passos)
10. [🔮 GraphQL Implementation](#-graphql-implementation)

    * 🔍 [Exemplo de Busca](#-exemplo-de-busca)
    * 🧾 [Headers](#-headers)
    * 🖥️ [Interface Gráfica](#-interface-gráfica)

---

## ✨ Funcionalidades Principais

* 🔐 **Autenticação JWT:** Sistema completo de registro (`/signup`) e login (`/login`) usando `bcrypt` e `jwt`.
* 🧩 **Modelagem Avançada:**

  * 🏷️ **STI (Single Table Inheritance):** Modelo `Material` como base para `Book`, `Article` e `Video`.
  * 🔄 **Polimorfismo:** Materiais podem ser de autoria de uma `Person` ou `Institution`.
* 🌍 **Integração com API Externa:** Preenchimento automático de `title` e `page_count` via **Open Library API**.
* 🔁 **Máquina de Estado de Status:** Controle de ciclo de vida (`Draft → Published → Archived`).
* 🔎 **Busca e Paginação:** Endpoint `/search` com múltiplos parâmetros e paginação (`pagy`).
* 🧪 **Testes Robustos:** Cobertura acima de 90% com `RSpec` e `SimpleCov`.

---

## 🧱 Stack de Tecnologia

| Categoria          | Tecnologia                            | Propósito                      |
| :----------------- | :------------------------------------ | :----------------------------- |
| **Core**           | Ruby 3.2.x, Rails 8.0.x               | Backend da aplicação           |
| **Banco de Dados** | PostgreSQL                            | Banco de dados relacional      |
| **Servidor**       | Puma                                  | Servidor web                   |
| **Autenticação**   | `bcrypt`, `jwt`                       | Hash de senha e tokens         |
| **API**            | `httparty`, `pagy`, `rack-cors`       | Cliente HTTP, Paginação e CORS |
| **Testes**         | `rspec-rails`, `simplecov`            | Testes e Cobertura    |

---

## ⚙️ Instalação e Execução (Local)

**Pré-requisitos:** Ruby 3.2+, PostgreSQL e Node.js/Yarn.

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/henriquecmelo1/library-app.git
   cd library-app
   ```

2. **Instale as dependências:**

   ```bash
   bundle install
   yarn install
   ```

3. **Configure as variáveis de ambiente (.env):**
    Crie seu arquivo `.env` para armazenar as chaves secretas.

    Gere uma chave secreta (comando `rails secret`) e adicione-a ao seu `.env`:

    ```ini
    JWT_SECRET_KEY=sua_chave_secreta_gerada_aqui
    ```

4. **Configure o banco de dados:**

   ```bash
   rails db:create
   rails db:migrate
   ```

5. **Rode os testes (opcional, mas recomendado):**

   ```bash
   bundle exec rspec
   ```

6. **Inicie o servidor:**

   ```bash
   rails server
   ```

   🌐 A API estará rodando em `http://localhost:3000`.

---

## 🧪 Testes

🧠 O projeto utiliza **RSpec** com cobertura superior a **90%**.

```bash
bundle exec rspec
```

📊 Após rodar os testes, veja o relatório em `coverage/index.html`.

---

## 📡 Documentação da API (Endpoints)

**Autenticação JWT obrigatória** em todas as rotas protegidas:
`Authorization: Bearer <seu_token>`

### 🔐 Autenticação

| Método | Endpoint  | Ação                             | Descrição             |
| :----- | :-------- | :------------------------------- | :-------------------- |
| `POST` | `/signup` | `UsersController#create`         | Registra novo usuário |
| `POST` | `/login`  | `AuthenticationController#login` | Gera token JWT        |

### 📘 Materiais

| Método   | Endpoint                     | Ação          | Descrição                            |
| :------- | :--------------------------- | :------------ | :----------------------------------- |
| `GET`    | `/materials`                 | `index`       | Lista materiais publicados           |
| `GET`    | `/materials/:id`             | `show`        | Mostra um material                   |
| `GET`    | `/materials/search`          | `search`      | Busca por título, autor ou descrição |
| `POST`   | `/materials`                 | `create`      | Cria material                        |
| `PATCH`  | `/materials/:id`             | `update`      | Atualiza material                    |
| `DELETE` | `/materials/:id`             | `destroy`     | Deleta material                      |
| `PATCH`  | `/materials/:id/push_status` | `push_status` | Avança status                        |
| `PATCH`  | `/materials/:id/pull_status` | `pull_status` | Regride status                       |

### 👤 Autores (Pessoa)
| Método | Endpoint | Controller\#Ação | Propósito |
| :--- | :--- | :--- | :--- |
| `GET` | `/people` | `PeopleController#index` | (Público) Lista todos os autores (pessoa). |
| `GET` | `/people/:id` | `PeopleController#show` | (Público) Mostra um autor (pessoa) específico. |
| `POST` | `/people` | `PeopleController#create` | (Autenticado) Cria um novo autor (pessoa). |
| `PATCH`| `/people/:id` | `PeopleController#update` | (Autenticado) Atualiza um autor (pessoa). |
| `DELETE`| `/people/:id`| `PeopleController#destroy`| (Autenticado) Deleta um autor (pessoa). |
### 🏛️ Autores (Instituição)

| Método | Endpoint | Controller\#Ação | Propósito |
| :--- | :--- | :--- | :--- |
| `GET` | `/institutions` | `InstitutionsController#index` | (Público) Lista todas as instituições. |
| `GET` | `/institutions/:id`| `InstitutionsController#show` | (Público) Mostra uma instituição específica. |
| `POST` | `/institutions` | `InstitutionsController#create` | (Autenticado) Cria uma nova instituição. |
| `PATCH`| `/institutions/:id`| `InstitutionsController#update` | (Autenticado) Atualiza uma instituição. |
| `DELETE`| `/institutions/:id`| `InstitutionsController#destroy`| (Autenticado) Deleta uma instituição. |
---

## 🧭 Documentação Interativa (Postman)

🧩 Explore a API interativamente no Postman!
A collection já inclui variáveis e autenticação automática JWT após login.

🔗 [Acesse aqui](https://www.postman.com/henriquecmelo1/my-workspace/collection/gawgm0g/libraryapp?action=share&creator=34558713&active-environment=34558713-db793dd4-e579-4d6d-8c35-b90d82d55e4b)

---

## ⚙️ Fluxos de Negócio Importantes

### 🛡️ Autorização

🔓 **Níveis de acesso:**

1.  **Público:** Rotas `GET` para `index`, `show` e `search` são abertas.
2.  **Autenticado:** Qualquer usuário logado pode criar novos autores (`Person`, `Institution`) e novos `Materials`.
3.  **Dono (Criador):** Apenas o usuário que criou um `Material` (o `@current_user` que é comparado com `material.user_id`) pode **atualizar**, **deletar** ou **mudar o status** desse material.

### 📖 Criação de Livro via ISBN

Ao fazer `POST /materials` com `type: "Book"`:

1.  O controller verifica se um `isbn` foi fornecido.
2.  Se `title` ou `page_count` estiverem em branco, o `OpenLibraryService` é acionado.
3.  O serviço faz uma requisição `GET https://openlibrary.org/isbn/<isbn>.json`.
4.  Se a requisição for bem-sucedida, os campos `title` e `page_count` são preenchidos com os dados da API antes de salvar.



---

## 🗂️ Estrutura do Projeto

📁 **Principais diretórios:**

  * `app/models`:
      * `material.rb`: Modelo base (STI), contém o `enum status` e validações genéricas.
      * `book.rb`, `article.rb`, `video.rb`: Modelos filhos com validações específicas (ex: `isbn` no `Book`).
      * `user.rb`: `has_secure_password` e associação `has_many :materials`.
      * `person.rb`, `institution.rb`: Modelos de autores com associação polimórfica.
  * `app/controllers`:
      * `application_controller.rb`: Contém a lógica de `authorize_request` (decodificação de JWT) e define `@current_user`.
      * `materials_controller.rb`: Lógica principal de CRUD, busca, `check_owner` e a máquina de estado (`push_status`/`pull_status`).
  * `app/services`:
      * `open_library_service.rb`: Serviço isolado que usa `HTTParty` para se comunicar com a Open Library.
  * `spec/`:
      * `spec/models`: Testes de unidade para todas as validações de todos os modelos.
      * `spec/requests`: Testes de integração para todos os controllers, cobrindo permissões e regras de negócio.

---

## 🚀 Próximos Passos

* ☁️ Deploy em produção
* 💻 Criar frontend para consumo da API

---

## 🔮 GraphQL Implementation

✨ Implementação disponível na branch `graphql`.

### 🔍 Exemplo de Busca

```graphql
query ListaDeMateriaisComAutores {
  materials {
    id
    title
    author {
      ... on Person {
        __typename
        name
        dateOfBirth
      }
      ... on Institution {
        __typename
        name
        city
      }
    }
  }
}
```

### 🧾 Headers

```json
{
  "Authorization": "Bearer jwt_token"
}
```

### 🖥️ Interface Gráfica

Acesse o **GraphiQL** em `/graphiql` para explorar e testar queries interativamente.

---

