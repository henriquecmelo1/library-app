require 'rails_helper'

RSpec.describe "Institutions API", type: :request do

  # --- Bloco de Setup ---
  let!(:user) { User.create!(email: "user@email.com", password: "password123") }
  let(:token) { JWT.encode({ user_id: user.id }, ENV['JWT_SECRET_KEY']) }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" } }
  let(:headers_sem_token) { { "Content-Type" => "application/json" } }

  # Cria uma instituição para os testes de 'show', 'update', 'delete'
  let!(:institution) { Institution.create!(name: "Instituição Teste", city: "Recife") }
  
  # Parâmetros válidos para criar uma nova instituição
  let(:valid_params) do
    { institution: { name: "Nova Instituição", city: "São Paulo" } }.to_json
  end
  
  # Parâmetros inválidos
  let(:invalid_params) do
    { institution: { name: "" } }.to_json # Nome em branco (inválido)
  end

  def json_response
    JSON.parse(response.body)
  end
  # --- Fim do Setup ---

  # Rotas Públicas (GET)
  describe "GET /institutions" do
    # Teste 0: Listagem de Instituições (GET /institutions)
    it "retorna 200 OK e uma lista de instituições (autores)" do
      get "/institutions"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['authors'].count).to eq(1)
      expect(json_response['authors'][0]['name']).to eq("Instituição Teste")
    end
  end

  # Teste 1: Detalhes de uma Instituição (GET /institutions/:id)
  describe "GET /institutions/:id" do
    it "retorna 200 OK e os dados da instituição" do
      get "/institutions/#{institution.id}"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq("Instituição Teste")
    end
  end

  # Rotas Protegidas (POST, PATCH, DELETE)
  describe "POST /institutions" do
    context "com um token válido" do
      # Teste 2: Criação de Instituição com token válido (POST /institutions)
      it "cria uma nova instituição e retorna 201 Created" do
        expect {
          post "/institutions", params: valid_params, headers: headers
        }.to change { Institution.count }.by(1)
        
        expect(response).to have_http_status(:created)
        expect(json_response['name']).to eq("Nova Instituição")
      end

      # Teste 3: Criação de Instituição com parâmetros inválidos (POST /institutions)
      it "retorna 422 Unprocessable Content se os parâmetros forem inválidos" do
        post "/institutions", params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors']).to include("Name can't be blank")
      end
    end

    context "sem um token" do
      # Teste 4: Criação de Instituição sem token (POST /institutions)
      it "retorna 401 Unauthorized" do
        post "/institutions", params: valid_params, headers: headers_sem_token
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /institutions/:id" do
    let(:update_params) { { institution: { name: "Nome Atualizado" } }.to_json }

    # Teste 5: Atualização de Instituição sem token (PATCH /institutions/:id)
    it "retorna 401 Unauthorized se não houver token" do
      patch "/institutions/#{institution.id}", params: update_params, headers: headers_sem_token
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 6: Atualização de Instituição com token válido (PATCH /institutions/:id)
    it "atualiza a instituição se houver um token" do
      patch "/institutions/#{institution.id}", params: update_params, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq("Nome Atualizado")
    end
  end

  # Regra de Negócio (DELETE)
  describe "DELETE /institutions/:id" do
    # Teste 7: Exclusão de Instituição sem token (DELETE /institutions/:id)
    it "retorna 401 Unauthorized se não houver token" do
      delete "/institutions/#{institution.id}", headers: headers_sem_token
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 8: Exclusão de Instituição com token válido (DELETE /institutions/:id)
    it "retorna 204 No Content se a instituição puder ser deletada" do
      expect {
        delete "/institutions/#{institution.id}", headers: headers
      }.to change { Institution.count }.by(-1)
      
      expect(response).to have_http_status(:no_content)
    end

    # Teste 9: Exclusão de Instituição associada a um Material (DELETE /institutions/:id)
    it "retorna 422 Unprocessable Content se a instituição estiver associada a um material" do
      # 1. Cria um material associado à instituição
      Material.create!(
        user: user, author: institution, type: "Article", 
        title: "Artigo que impede o delete", doi: "10.1234/teste-inst", status: "draft"
      )

      # 2. Tenta deletar a instituição
      expect {
        delete "/institutions/#{institution.id}", headers: headers
      }.not_to change { Institution.count } # A contagem não deve mudar
      
      # 3. Verifica o status e a mensagem de erro
      expect(response).to have_http_status(:unprocessable_content)
      expect(json_response['errors']).to include("Cannot delete record because dependent materials exist")
    end
  end
end