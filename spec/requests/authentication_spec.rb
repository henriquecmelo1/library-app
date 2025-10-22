require 'rails_helper'

RSpec.describe "Authentication API", type: :request do

  # --- Bloco de Setup ---
  # Precisamos de um usuário existente para tentar fazer login
  let!(:user) do
    User.create!(
      email: "login@teste.com",
      password: "senha-correta-123",
      password_confirmation: "senha-correta-123"
    )
  end
  
  # O cabeçalho padrão para nossas requisições
  let(:headers) { { "Content-Type" => "application/json" } }
  
  def json_response
    JSON.parse(response.body)
  end
  # --- Fim do Setup ---

  describe "POST /login" do
    
    context "com credenciais válidas" do
      let(:valid_params) do
        { email: "login@teste.com", password: "senha-correta-123" }.to_json
      end
      
      # Teste 0: Login com credenciais válidas (POST /login)
      it "retorna 200 OK e um token JWT válido" do
        post "/login", params: valid_params, headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key("token")
        
        # Tenta decodificar o token para garantir que é um JWT válido
        decoded_token = JWT.decode(json_response['token'], ENV['JWT_SECRET_KEY'])
        
        expect(decoded_token[0]['user_id']).to eq(user.id)
      end
    end
    
    context "com credenciais inválidas" do
      # Teste 1: Login com senha inválida (POST /login)
      it "retorna 401 Unauthorized se a senha estiver errada" do
        invalid_params = { email: "login@teste.com", password: "senha-errada" }.to_json
        post "/login", params: invalid_params, headers: headers
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq("Email or password is invalid")
      end
      
      # Teste 2: Login com e-mail inválido (POST /login)
      it "retorna 401 Unauthorized se o e-mail não existir" do
        invalid_params = { email: "nao-existe@teste.com", password: "senha-correta-123" }.to_json
        post "/login", params: invalid_params, headers: headers
        
        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq("Email or password is invalid")
      end
    end
  end
end