require 'rails_helper'

RSpec.describe Article, type: :model do
  
  # --- BLOCO DE SETUP ---
  # Dados necessários para que um Material (Artigo) seja válido
  let!(:user) { User.create!(email: "article_user@exemplo.com", password: "password123") }
  let!(:author) { Person.create!(name: "Article Author", date_of_birth: "1990-01-01") }

  # Um hash de atributos válidos para um Artigo
  let(:valid_attributes) do
    {
      title: "Artigo de Teste Válido",
      status: "draft",
      user: user,
      author: author,
      doi: "10.1000/xyz123" # DOI Válido (Req 3.4)
    }
  end
  # --- FIM DO SETUP ---

  describe "Validações" do

    # Teste 0: Caso válido geral
    context "quando todos os atributos são válidos" do
      it "é válido" do
        article = Article.new(valid_attributes)
        expect(article).to be_valid
      end
    end

    # --- TESTES DE VALIDAÇÕES HERDADAS (DO MATERIAL) ---
    context "validações herdadas de Material" do
      # Teste 1: Presença de título
      it "é inválido sem um título" do
        article = Article.new(valid_attributes.except(:title))
        expect(article).not_to be_valid
        expect(article.errors[:title]).to include("can't be blank")
      end

      # Teste 2: Presença de autor
      it "é inválido sem um autor" do
        article = Article.new(valid_attributes.except(:author))
        expect(article).not_to be_valid
        expect(article.errors[:author]).to include("can't be blank")
      end
    end

    # --- TESTES DE VALIDAÇÕES ESPECÍFICAS (DO ARTICLE) ---
    context "validações específicas de Article (DOI)" do
      
      # Teste 3: Presença de DOI
      it "é inválido sem um DOI" do
        article = Article.new(valid_attributes.except(:doi))
        expect(article).not_to be_valid
        expect(article.errors[:doi]).to include("can't be blank")
      end

      # Teste 4: Formato do DOI
      it "é inválido se o formato do DOI for incorreto" do
        # Exemplos de formatos inválidos
        invalid_dois = ["12345", "nao-e-doi", "10.100/xyz", "abc.1234/xyz"]
        
        invalid_dois.each do |invalid_doi|
          article = Article.new(valid_attributes.merge(doi: invalid_doi))
          expect(article).not_to be_valid
          expect(article.errors[:doi]).to include("must follow DOI's format (ex.: 10.1000/xyz123)")
        end
      end
      
      # Teste 5: Unicidade do DOI
      it "é inválido se o DOI já existir" do

        Article.create!(valid_attributes)
        other_article = Article.new(valid_attributes.merge(title: "Outro Titulo"))
        
        expect(other_article).not_to be_valid
        expect(other_article.errors[:doi]).to include("has already been taken")
      end
    end
  end
end