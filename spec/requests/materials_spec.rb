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
    # Teste 8: Busca de Materiais com resultado (GET /materials/search)
    it "retorna 200 OK e os resultados da busca" do
      get "/materials/search?query=Dono" # Busca deve achar o 'material_publicado'
      
      expect(response).to have_http_status(:ok)
      expect(json_response['materials'].count).to eq(1)
      expect(json_response['materials'][0]['title']).to eq("Livro Publicado do Dono")
    end

    # Teste 9: Busca de Materiais sem resultado (GET /materials/search)
    it "retorna 200 OK e um array vazio se a busca não encontrar nada" do
      get "/materials/search?query=Inexistente"
      
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

    # Teste 10: Criação de Livro com dados da OpenLibrary (POST /materials)
    it "chama a OpenLibrary e preenche o título/páginas se eles estiverem faltando" do
      
      # Prepara a resposta JSON que a API externa VAI retornar
      stubbed_response_body = {"publishers":["Signet Classic"],"number_of_pages":216,"isbn_10":["0451526538"],"subject_place":["Mississippi River Valley","Missouri"],"pagination":"xxi, 216 p. ;","covers":[11403183],"lc_classifications":["PS1306 .A1 1997","PS1306.A1 1997"],"key":"/books/OL1017798M","authors":[{"key":"/authors/OL18319A"}],"publish_places":["New York"],"genres":["Fiction."],"classifications":{},"source_records":["marc:marc_records_scriblio_net/part25.dat:213801824:997","marc:marc_loc_updates/v40.i23.records.utf8:2463307:1113","amazon:0451526538","marc:marc_loc_2016/BooksAll.2016.part25.utf8:119958799:1113","ia:adventuresoftoms0000twai_x3x4","bwb:9780451526533"],"title":"The adventures of Tom Sawyer","lccn":["96072233"],"notes":"Includes bibliographical references (p. 213-216).","identifiers":{"librarything":["2236"],"project_gutenberg":["74"],"goodreads":["1929684"]},"languages":[{"key":"/languages/eng"}],"dewey_decimal_class":["813/.4"],"subjects":["Sawyer, Tom (Fictitious character) -- Fiction","Runaway children -- Fiction","Child witnesses -- Fiction","Boys -- Fiction","Mississippi River Valley -- Fiction","Missouri -- Fiction"],"publish_date":"1997","publish_country":"nyu","by_statement":"Mark Twain ; with an introduction by Robert S. Tilton.","oclc_numbers":["36792831"],"works":[{"key":"/works/OL53919W"}],"type":{"key":"/type/edition"},"ocaid":"adventuresoftoms0000twai_x3x4","latest_revision":14,"revision":14,"created":{"type":"/type/datetime","value":"2008-04-01T03:28:50.625462"},"last_modified":{"type":"/type/datetime","value":"2021-10-08T20:02:44.638815"}}.to_json


      # Mocka a chamada: Intercepta a chamada GET e retorna nossa resposta
      stub_request(:get, "https://openlibrary.org/isbn/#{isbn}.json")
        .to_return(status: 200, body: stubbed_response_body, headers: { 'Content-Type' => 'application/json' })

      # 3. Faz a chamada (sem title)
      post "/materials", params: params_sem_titulo, headers: headers_dono

      # 4. Verifica os resultados
      expect(response).to have_http_status(:created)
      
      # O teste real: O 'title' veio da nossa resposta "mockada"?
      expect(json_response['title']).to eq("The adventures of Tom Sawyer")
      expect(json_response['page_count']).to eq(216)
    end

    # Teste 11: Criação de Livro com ISBN válido, mas dados inseridos pelo usuário (POST /materials)
    it "não sobrescreve título/páginas se eles forem fornecidos pelo usuário" do
      # Mocka a chamada para garantir que a API externa não sobrescreva
      stub_request(:get, "https://openlibrary.org/isbn/#{isbn}.json")
        .to_return(status: 200, body: "{}", headers: { 'Content-Type' => 'application/json' })  
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
end