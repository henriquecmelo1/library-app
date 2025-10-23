require 'rails_helper'

RSpec.describe "Materials API", type: :request do

  # --- Bloco de Setup ---
  # Dados necessários para os testes
  let!(:user_dono) { User.create!(email: "dono@email.com", password: "password123") }
  let!(:user_outro) { User.create!(email: "outro@email.com", password: "password123") }
  let!(:author) { Person.create!(name: "Autor Testável", date_of_birth: "1980-01-01") }

  # Material publicado que pertence ao 'user_dono'
  let!(:material_publicado) do
    user_dono.materials.create!(
      title: "Livro Publicado do Dono",
      description: "Uma descrição única para a busca.", 
      status: "published", 
      author: author,
      type: "Book",
      isbn: "1111111111111",
      page_count: 100
    )
  end

  # Rascunho que pertence ao 'user_dono'
  let!(:material_rascunho) do
    user_dono.materials.create!(
      title: "Rascunho do Dono",
      status: "draft",
      author: author,
      type: "Article",
      doi: "10.1234/rascunho"
    )
  end

  # Gerando os tokens
  let(:token_dono) { JWT.encode({ user_id: user_dono.id }, ENV['JWT_SECRET_KEY']) }
  let(:token_outro) { JWT.encode({ user_id: user_outro.id }, ENV['JWT_SECRET_KEY']) }

  # Definindo os cabeçalhos
  let(:headers_dono) { { "Authorization" => "Bearer #{token_dono}", "Content-Type" => "application/json" } }
  let(:headers_outro) { { "Authorization" => "Bearer #{token_outro}", "Content-Type" => "application/json" } }
  let(:headers_sem_token) { { "Content-Type" => "application/json" } }
  
  # Helper para parsear o JSON
  def json_response
    JSON.parse(response.body)
  end
  # --- Fim do Setup ---


  # Listagem de Materiais
  describe "GET /materials" do
    # Teste 0: Listagem de Materiais (GET /materials)
    it "retorna 200 OK e uma lista de materiais *publicados*" do
      get "/materials"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['materials'].count).to eq(1) # Só deve achar o 'material_publicado'
      expect(json_response['materials'][0]['title']).to eq("Livro Publicado do Dono")
    end
  end

  describe "GET /materials/:id" do
    # Teste 1: Visualização de Material por id (GET /materials/:id)
    it "retorna 200 OK e os dados do material" do
      get "/materials/#{material_publicado.id}"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['title']).to eq("Livro Publicado do Dono")
    end
  end

  # Criação de Materiais
  describe "POST /materials" do
    let(:valid_params) do
      { material: { type: "Video", title: "Novo Video", status: "draft",
                    author_id: author.id, author_type: "Person", duration_in_minutes: 5 }
      }.to_json
    end

    # Teste 2: Criação de Material sem token (POST /materials)
    it "retorna 401 Unauthorized se nenhum token for enviado" do
      post "/materials", params: valid_params, headers: headers_sem_token
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 3: Criação de Material com token válido (POST /materials)
    it "retorna 201 Created se um token válido for enviado" do
      expect {
        post "/materials", params: valid_params, headers: headers_dono
      }.to change { Material.count }.by(1)
      
      expect(response).to have_http_status(:created)
      expect(json_response['title']).to eq("Novo Video")
      expect(json_response['user_id']).to eq(user_dono.id) # Verifica se associou ao dono
    end
  end

  # Permissões de Dono (PATCH e DELETE) 
  # PATCH
  describe "PATCH /materials/:id" do
    let(:update_params) { { material: { title: "Título Atualizado" } }.to_json }

    # Teste 4: Atualização de Material por não-dono (PATCH /materials/:id)
    it "retorna 401 Unauthorized se o token for de outro usuário (não-dono)" do
      patch "/materials/#{material_publicado.id}", params: update_params, headers: headers_outro
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 5: Atualização de Material por dono (PATCH /materials/:id)
    it "retorna 200 OK se o token for do dono" do
      patch "/materials/#{material_publicado.id}", params: update_params, headers: headers_dono
      expect(response).to have_http_status(:ok)
      expect(json_response['title']).to eq("Título Atualizado")
    end
  end

  # DELETE
  describe "DELETE /materials/:id" do

    # Teste 6: Exclusão de Material por não-dono (DELETE /materials/:id)
    it "retorna 401 Unauthorized se o token for de outro usuário (não-dono)" do
      delete "/materials/#{material_publicado.id}", headers: headers_outro
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 7: Exclusão de Material por dono (DELETE /materials/:id)
    it "retorna 204 No Content se o token for do dono" do
      expect {
        delete "/materials/#{material_publicado.id}", headers: headers_dono
      }.to change { Material.count }.by(-1)
      
      expect(response).to have_http_status(:no_content)
    end
  end

  # Busca e Paginação (GET /materials/search) 
  describe "GET /materials/search" do
    # Teste 8: Busca sem parâmetros (GET /materials/search)
    it "retorna 400 Bad Request se nenhum parâmetro de busca for fornecido" do
      get "/materials/search"
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).to eq("Search parameter must be one of these: title, author, description")
    end

    # Teste 9: Busca com parâmetros (GET /materials/search?title) 
    it "retorna 200 OK e resultados ao buscar por 'title'" do
      get "/materials/search?title=Publicado"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['materials'].count).to eq(1)
      expect(json_response['materials'][0]['title']).to eq("Livro Publicado do Dono")
    end

    # Teste 10: Busca com parâmetros (GET /materials/search?author)
    it "retorna 200 OK e resultados ao buscar por 'author'" do
      # O nome do nosso autor é "Autor Testável"
      get "/materials/search?author=Test"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['materials'].count).to eq(1)
    end
    
    # Teste 11: Busca com parâmetros (GET /materials/search?description)
    it "retorna 200 OK e resultados ao buscar por 'description'" do
      # A descrição é "Uma descrição única para a busca."
      get "/materials/search?description=busca"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['materials'].count).to eq(1)
    end
    
    # Teste 12: Busca sem resultados (GET /materials/search)
    it "retorna 200 OK e um array vazio se a busca não encontrar nada" do
      get "/materials/search?title=Inexistente"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['materials'].count).to eq(0)
    end
  end

  # Consumo de API Externa (POST /materials com mock) 
  describe "POST /materials (com API Externa)" do
    let(:isbn) { "9780451526533" } # ISBN-13
    let(:params_sem_titulo) do
      { material: { type: "Book", status: "draft", author_id: author.id,
                    author_type: "Person", isbn: isbn }
      }.to_json
    end

    # Teste 13: Criação de Livro com dados da OpenLibrary (POST /materials)
    it "chama a OpenLibrary e preenche o título/páginas se eles estiverem faltando", :api => true do
      
      # --- Código Removido ---
      # O 'stubbed_response_body' foi removido.
      # O 'stub_request' foi removido.
      # A chamada de rede real agora é permitida.
      # ----------------------

      # 3. Faz a chamada (sem title)
      # Esta ação agora vai disparar uma chamada de rede real de dentro do seu controller
      post "/materials", params: params_sem_titulo, headers: headers_dono

      # 4. Verifica os resultados
      expect(response).to have_http_status(:created)
      
      # O teste real: O 'title' veio da API EXTERNA?
      # NOTA: Este teste pode quebrar se a OpenLibrary mudar esses dados!
      expect(json_response['title']).to eq("The adventures of Tom Sawyer")
      expect(json_response['page_count']).to eq(216)
    end

    # Teste 14: Criação de Livro com ISBN válido, mas dados inseridos pelo usuário (POST /materials)
    it "não sobrescreve título/páginas se eles forem fornecidos pelo usuário" do
      params_com_titulo = { material: 
                                      { 
                                        type: "Book", status: "draft", author_id: author.id,
                                        author_type: "Person", isbn: isbn, title: "Título do Usuário", page_count: 150
                                      }
                          }.to_json

      post "/materials", params: params_com_titulo, headers: headers_dono

      # 4. Verifica os resultados
      expect(response).to have_http_status(:created)

      # O teste real: O 'title' veio da nossa resposta "mockada"?
      expect(json_response['title']).to eq("Título do Usuário")
      expect(json_response['page_count']).to eq(150)

    end
  end

  # Testes de Mudança de Status (PATCH /materials/:id/push_status e /pull_status)
  # Push Status
  describe "PATCH /materials/:id/push_status" do
    # Teste 15: Tentativa de push_status sem token
    it "retorna 401 Unauthorized se não houver token" do
      patch "/materials/#{material_rascunho.id}/push_status", headers: headers_sem_token
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 16: Tentativa de push_status por não-dono
    it "retorna 401 Unauthorized se o token for de outro usuário (não-dono)" do
      patch "/materials/#{material_rascunho.id}/push_status", headers: headers_outro
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 17: Draft -> Published
    it "muda o status de 'draft' para 'published'" do
      patch "/materials/#{material_rascunho.id}/push_status", headers: headers_dono
      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq("published")
    end
    
    # Teste 18: Published -> Archived
    it "muda o status de 'published' para 'archived'" do
      # 'material_publicado' já está published
      patch "/materials/#{material_publicado.id}/push_status", headers: headers_dono
      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq("archived")
    end
    
    # Teste 19: Tentativa de push_status de 'archived' (estado final)
    it "retorna 400 Bad Request ao tentar 'push' de 'archived'" do
      material_publicado.update!(status: :archived) # Força o estado
      patch "/materials/#{material_publicado.id}/push_status", headers: headers_dono
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).to include("It's not possible to advance the status 'archived'")
    end
  end

  # Pull Status
  describe "PATCH /materials/:id/pull_status" do
    # Teste 20: Tentativa de pull_status sem token
    it "retorna 401 Unauthorized se não houver token" do
      patch "/materials/#{material_publicado.id}/pull_status", headers: headers_sem_token
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 21: Tentativa de pull_status por não-dono
    it "retorna 401 Unauthorized se o token for de outro usuário (não-dono)" do
      patch "/materials/#{material_publicado.id}/pull_status", headers: headers_outro
      expect(response).to have_http_status(:unauthorized)
    end

    # Teste 22: Published -> Draft
    it "muda o status de 'published' para 'draft'" do
       patch "/materials/#{material_publicado.id}/pull_status", headers: headers_dono
       expect(response).to have_http_status(:ok)
       expect(json_response['status']).to eq("draft")
    end

    # Teste 23: Archived -> Published
    it "muda o status de 'archived' para 'published'" do
      material_publicado.update!(status: :archived) # Força o estado
      patch "/materials/#{material_publicado.id}/pull_status", headers: headers_dono
      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq("published")
    end
    
    # Teste 24: Tentativa de pull_status de 'draft' (estado inicial)
    it "retorna 400 Bad Request ao tentar 'pull' de 'draft'" do
      # 'material_rascunho' já está draft
      patch "/materials/#{material_rascunho.id}/pull_status", headers: headers_dono
      expect(response).to have_http_status(:bad_request)
      expect(json_response['error']).to include("It's not possible to revert the status 'draft'")
    end
  end
end