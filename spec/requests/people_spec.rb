require 'rails_helper'

RSpec.describe "People API", type: :request do

  # --- Bloco de Setup ---
  let!(:user) { User.create!(email: "user@email.com", password: "password123") }
  let(:token) { JWT.encode({ user_id: user.id }, ENV['JWT_SECRET_KEY']) }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" } }
  let(:headers_sem_token) { { "Content-Type" => "application/json" } }

  # Cria uma pessoa para os testes de 'show', 'update', 'delete'
  let!(:person) { Person.create!(name: "Autor Teste", date_of_birth: "1990-01-01") }
  
  # Parâmetros válidos para criar uma nova pessoa
  let(:valid_params) do
    { person: { name: "Novo Autor", date_of_birth: "2000-01-01" } }.to_json
  end
  
  # Parâmetros inválidos
  let(:invalid_params) do
    { person: { name: "" } }.to_json # Nome em branco (inválido)
  end

  def json_response
    JSON.parse(response.body)
  end
  # --- Fim do Setup ---

  # Rotas Públicas (GET)
  describe "GET /people" do
    # Teste 0: Listagem de Pessoas (GET /people)
    it "retorna 200 OK e uma lista de pessoas (autores)" do
      get "/people"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['authors'].count).to eq(1)
      expect(json_response['authors'][0]['name']).to eq("Autor Teste")
    end
  end

  describe "GET /people/:id" do
    # Teste 1: Detalhes de uma Pessoa (GET /people/:id)
    it "retorna 200 OK e os dados da pessoa" do
      get "/people/#{person.id}"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq("Autor Teste")
    end
  end

  # Rotas Protegidas (POST, PATCH, DELETE)
  describe "POST /people" do
    context "com um token válido" do
      # Teste 2: Criação de Pessoa com token válido (POST /people)
      it "cria uma nova pessoa e retorna 201 Created" do
        expect {
          post "/people", params: valid_params, headers: headers
        }.to change { Person.count }.by(1)
        
        expect(response).to have_http_status(:created)
        expect(json_response['name']).to eq("Novo Autor")
      end

      # Teste 3: Criação de Pessoa com parâmetros inválidos (POST /people)
      it "retorna 422 Unprocessable Content se os parâmetros forem inválidos" do
        post "/people", params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors']).to include("Name can't be blank")
      end
    end

    context "sem um token" do
      # Teste 4: Criação de Pessoa sem token (POST /people)
      it "retorna 401 Unauthorized" do
        post "/people", params: valid_params, headers: headers_sem_token
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /people/:id" do
    let(:update_params) { { person: { name: "Nome Atualizado" } }.to_json }

    # Teste 5: Atualização de Pessoa sem token (PATCH /people/:id)
    it "retorna 401 Unauthorized se não houver token" do
      patch "/people/#{person.id}", params: update_params, headers: headers_sem_token
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 6: Atualização de Pessoa com token válido (PATCH /people/:id)
    it "atualiza a pessoa se houver um token" do
      patch "/people/#{person.id}", params: update_params, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq("Nome Atualizado")
    end
  end

  # Regra de Negócio (DELETE)
  describe "DELETE /people/:id" do
    # Teste 7: Exclusão de Pessoa sem token (DELETE /people/:id)
    it "retorna 401 Unauthorized se não houver token" do
      delete "/people/#{person.id}", headers: headers_sem_token
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 8: Exclusão de Pessoa com token válido (DELETE /people/:id)
    it "retorna 204 No Content se o autor puder ser deletado" do
      # (Neste teste, o 'person' não está associado a nenhum material)
      expect {
        delete "/people/#{person.id}", headers: headers
      }.to change { Person.count }.by(-1)
      
      expect(response).to have_http_status(:no_content)
    end

    # Teste 9: Exclusão de Pessoa associada a um Material (DELETE /people/:id)
    it "retorna 422 Unprocessable Content se o autor estiver associado a um material" do
      # 1. Cria um material associado à pessoa
      Material.create!(
        user: user, author: person, type: "Book", 
        title: "Livro que impede o delete", isbn: "1111111111111", page_count: 10, status: "draft"
      )

      # 2. Tenta deletar o autor
      expect {
        delete "/people/#{person.id}", headers: headers
      }.not_to change { Person.count } # A contagem não deve mudar
      
      # 3. Verifica o status e a mensagem de erro (do dependent: :restrict_with_error)
      expect(response).to have_http_status(:unprocessable_content)
      expect(json_response['errors']).to include("Cannot delete record because dependent materials exist")
    end
  end
end