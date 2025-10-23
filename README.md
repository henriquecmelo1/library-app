# Library App API

Uma API RESTful completa construída em Ruby on Rails para gerenciar uma plataforma de biblioteca digital. O projeto inclui autenticação JWT, gerenciamento de materiais (com STI), autores polimórficos, integração com API externa (Open Library) e uma cobertura de testes de 90% com RSpec.

-----

## Tabela de Conteúdos

1.  [Funcionalidades Principais](#funcionalidades-principais)
2.  [Stack de Tecnologia](#stack-de-tecnologia)
3.  [Instalação e Execução (Local)](#instalação-e-execução-local)
4.  [Testes](#testes)
5.  [Documentação da API (Endpoints)](#documentação-da-api-endpoints)
      * [Autenticação](#autenticação)
      * [Materiais (Livros, Artigos, Vídeos)](#materiais)
      * [Autores (Pessoa)](#autores-pessoa)
      * [Autores (Instituição)](#autores-instituição)
6.  [Documentação Interativa (Postman)](#documentação-interativa-postman)
7.  [Fluxos de Negócio Importantes](#fluxos-de-negócio-importantes)
      * [Autorização (Dono vs. Público)](#autorização)
      * [Criação de Livro via ISBN](#criação-de-livro-via-isbn)
8.  [Testando Manualmente (API Client)](#testando-manualmente-api-client)
9.  [Estrutura do Projeto](#estrutura-do-projeto)
10.  [Próximos Passos](#próximos-passos)

-----

## Funcionalidades Principais

  * **Autenticação JWT:** Sistema completo de registro (`/signup`) e login (`/login`) usando `bcrypt` e `jwt`.
  * **Modelagem Avançada:**
      * **STI (Single Table Inheritance):** Modelo `Material` como base para `Book`, `Article` e `Video`.
      * **Polimorfismo:** Materiais podem ser de autoria de uma `Person` ou `Institution`.
  * **Integração com API Externa:** Preenchimento automático de `title` e `page_count` para livros ao cadastrar com `isbn`, consumindo a API da Open Library.
  * **Máquina de Estado de Status:** Endpoints dedicados (`/push_status` e `/pull_status`) para controlar o ciclo de vida dos materiais (Draft -\> Published -\> Archived).
  * **Busca e Paginação:** Endpoint de busca (`/search`) com múltiplos parâmetros e paginação em todas as listagens usando a gem `pagy`.
  * **Testes Robustos:** Cobertura de 90%+ com RSpec, incluindo testes de unidade (model) e requisição (request), com *mocking* da API externa usando `webmock`.

## Stack de Tecnologia

| Categoria | Tecnologia | Propósito |
| :--- | :--- | :--- |
| **Core** | Ruby 3.2.x, Rails 8.0.x | Backend da aplicação |
| **Banco de Dados** | PostgreSQL | Banco de dados relacional |
| **Servidor** | Puma | Servidor de aplicação web |
| **Autenticação** | `bcrypt`, `jwt` | Hash de senha e geração de tokens |
| **API** | `httparty`, `pagy`, `rack-cors` | Cliente HTTP, Paginação e CORS |
| **Testes** | `rspec-rails`, `webmock`, `simplecov` | Testes, Mocking de API e Cobertura |

## Instalação e Execução (Local)

Siga os passos abaixo para configurar o ambiente de desenvolvimento.

**Pré-requisitos:** Ruby 3.2+, PostgreSQL (rodando) e Node.js/Yarn.

1.  **Clone o repositório:**

    ```bash
    git clone https://github.com/henriquecmelo1/library-app.git
    cd library-app
    ```

2.  **Instale as dependências:**

    ```bash
    bundle install
    yarn install 
    ```

3.  **Configure as Variáveis de Ambiente:**
    Crie seu arquivo `.env` para armazenar as chaves secretas.

    Gere uma chave secreta (comando `rails secret`) e adicione-a ao seu `.env`:

    ```ini
    JWT_SECRET_KEY=sua_chave_secreta_gerada_aqui
    ```

4.  **Configure o Banco de Dados:**

    ```bash
    rails db:create
    rails db:migrate
    ```

5.  **Rode os Testes (Opcional, mas recomendado):**

    ```bash
    bundle exec rspec
    ```

6.  **Inicie o Servidor:**

    ```bash
    rails server
    ```

    A API estará rodando em `http://localhost:3000`.

-----

## Testes

O projeto usa RSpec para testes de unidade e requisição. A cobertura de testes está acima de 90%.

```bash
# Rodar todos os testes
bundle exec rspec

# Gerar relatório de cobertura (após rodar os testes)
# Abra o arquivo coverage/index.html
```

As chamadas à API da Open Library são "mockadas" usando `webmock` (veja `spec/support/webmock.rb`).

-----

## Documentação da API (Endpoints)

Todas as rotas de criação/atualização/remoção (POST, PATCH, DELETE) exigem um token JWT válido enviado no cabeçalho:
`Authorization: Bearer <seu_token>`

### Autenticação

| Método | Endpoint | Controller\#Ação | Propósito |
| :--- | :--- | :--- | :--- |
| `POST` | `/signup` | `UsersController#create` | Registra um novo usuário. |
| `POST` | `/login` | `AuthenticationController#login` | Autentica e retorna um token JWT. |

### Materiais

| Método | Endpoint | Controller\#Ação | Propósito |
| :--- | :--- | :--- | :--- |
| `GET` | `/materials` | `MaterialsController#index` | (Público) Lista materiais **publicados** (paginado). |
| `GET` | `/materials/:id` | `MaterialsController#show` | (Público) Mostra um material específico. |
| `GET` | `/materials/search` | `MaterialsController#search` | (Público) Busca materiais por `title`, `author` ou `description`. |
| `POST` | `/materials` | `MaterialsController#create` | (Autenticado) Cria um novo material (Book, Article, Video). |
| `PATCH`| `/materials/:id` | `MaterialsController#update` | (Dono) Atualiza um material. |
| `DELETE`| `/materials/:id`| `MaterialsController#destroy`| (Dono) Deleta um material. |
| `PATCH`| `/materials/:id/push_status`| `MaterialsController#push_status`| (Dono) Avança o status (ex: Draft -\> Published). |
| `PATCH`| `/materials/:id/pull_status`| `MaterialsController#pull_status`| (Dono) Reverte o status (ex: Archived -\> Published). |

### Autores (Pessoa)

| Método | Endpoint | Controller\#Ação | Propósito |
| :--- | :--- | :--- | :--- |
| `GET` | `/people` | `PeopleController#index` | (Público) Lista todos os autores (pessoa). |
| `GET` | `/people/:id` | `PeopleController#show` | (Público) Mostra um autor (pessoa) específico. |
| `POST` | `/people` | `PeopleController#create` | (Autenticado) Cria um novo autor (pessoa). |
| `PATCH`| `/people/:id` | `PeopleController#update` | (Autenticado) Atualiza um autor (pessoa). |
| `DELETE`| `/people/:id`| `PeopleController#destroy`| (Autenticado) Deleta um autor (pessoa). |

### Autores (Instituição)

| Método | Endpoint | Controller\#Ação | Propósito |
| :--- | :--- | :--- | :--- |
| `GET` | `/institutions` | `InstitutionsController#index` | (Público) Lista todas as instituições. |
| `GET` | `/institutions/:id`| `InstitutionsController#show` | (Público) Mostra uma instituição específica. |
| `POST` | `/institutions` | `InstitutionsController#create` | (Autenticado) Cria uma nova instituição. |
| `PATCH`| `/institutions/:id`| `InstitutionsController#update` | (Autenticado) Atualiza uma instituição. |
| `DELETE`| `/institutions/:id`| `InstitutionsController#destroy`| (Autenticado) Deleta uma instituição. |

-----

## Documentação Interativa (Postman)

Uma documentação completa e interativa da API está disponível no Postman. A collection inclui todos os endpoints, exemplos de requisições e um ambiente configurado para lidar automaticamente com a autenticação JWT.

A API está disponível para consumo e testes por lá.

https://www.postman.com/henriquecmelo1/my-workspace/collection/gawgm0g/libraryapp?action=share&creator=34558713&active-environment=34558713-db793dd4-e579-4d6d-8c35-b90d82d55e4b

-----

## Fluxos de Negócio Importantes

### Autorização

A API divide o acesso em três níveis:

1.  **Público:** Rotas `GET` para `index`, `show` e `search` são abertas.
2.  **Autenticado:** Qualquer usuário logado pode criar novos autores (`Person`, `Institution`) e novos `Materials`.
3.  **Dono (Criador):** Apenas o usuário que criou um `Material` (o `@current_user` que é comparado com `material.user_id`) pode **atualizar**, **deletar** ou **mudar o status** desse material.

### Criação de Livro via ISBN

Ao fazer `POST /materials` com `type: "Book"`:

1.  O controller verifica se um `isbn` foi fornecido.
2.  Se `title` ou `page_count` estiverem em branco, o `OpenLibraryService` é acionado.
3.  O serviço faz uma requisição `GET https://openlibrary.org/isbn/<isbn>.json`.
4.  Se a requisição for bem-sucedida, os campos `title` e `page_count` são preenchidos com os dados da API antes de salvar.


## Testando Manualmente (API Client)

A pasta `test-http/` contém exemplos de requisições que podem ser usados com extensões de API Client (como a "REST Client" do VS Code) para facilitar testes manuais.

**Exemplo de JSON para `POST /materials`:**

```json
{
  "material": {
    "type": "Book",
    "author_id": 1,
    "author_type": "Person",
    "status": "draft",
    "isbn": "9780451526533" 
  }
}
```

## Estrutura do Projeto

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
      * `spec/requests`: Testes de integração para todos os controllers, cobrindo permissões, regras de negócio e *mocking* da API externa.

## Próximos Passos

  * Deploy em um ambiente de produção.
  * Frontend simples para consumir a API.