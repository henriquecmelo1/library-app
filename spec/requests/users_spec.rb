require 'rails_helper'

RSpec.describe "Users API", type: :request do

  # --- Bloco de Setup ---
  let(:headers) { { "Content-Type" => "application/json" } }
  
  # Parâmetros válidos para um novo usuário
  let(:valid_params) do
    {
      email: "novo-usuario@teste.com",
      password: "senha-valida-123",
      password_confirmation: "senha-valida-123"
    }.to_json
  end
  
  def json_response
    JSON.parse(response.body)
  end
  # --- Fim do Setup ---

  describe "POST /signup" do
    
    context "com parâmetros válidos" do
      # Teste 0: Criação de Usuário com parâmetros válidos (POST /signup)
      it "cria um novo usuário e retorna 201 Created com uma mensagem de sucesso" do
        # Esperamos que o 'User.count' mude em +1
        expect {
          post "/signup", params: valid_params, headers: headers
        }.to change { User.count }.by(1)

        # Verifica o status HTTP
        expect(response).to have_http_status(:created)

        # Verifica a mensagem de sucesso
        expect(json_response['message']).to eq("User created successfully!")
      end
    end
    
    context "com parâmetros inválidos" do
      # Teste 1: Criação de Usuário com senha curta (POST /signup)
      it "retorna 422 Unprocessable Content se a senha for curta" do
        invalid_params = {
          email: "usuario-senha-curta@teste.com",
          password: "123", # <--- Inválido
          password_confirmation: "123"
        }.to_json
        
        post "/signup", params: invalid_params, headers: headers
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors']).to include("Password is too short (minimum is 6 characters)")
      end
      
      # Teste 2: Criação de Usuário com confirmação de senha inválida (POST /signup)
      it "retorna 422 Unprocessable Content se a confirmação de senha falhar" do
        invalid_params = {
          email: "usuario-senha-errada@teste.com",
          password: "password123",
          password_confirmation: "password456" # <--- Inválido
        }.to_json
        
        post "/signup", params: invalid_params, headers: headers
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors']).to include("Password confirmation doesn't match Password")
      end
      
      # Teste 3: Criação de Usuário com e-mail já existente (POST /signup)
      it "retorna 422 Unprocessable Content se o e-mail já existir" do
        # 1. Cria o usuário primeiro
        User.create!(email: "ja-existe@teste.com", password: "password123")
        
        # 2. Tenta criar de novo com os mesmos dados
        params_duplicados = {
          email: "ja-existe@teste.com", # <--- Inválido
          password: "password123",
          password_confirmation: "password123"
        }.to_json
        
        post "/signup", params: params_duplicados, headers: headers
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['errors']).to include("Email has already been taken")
      end
    end
  end
end