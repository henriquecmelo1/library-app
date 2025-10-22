require 'rails_helper'

RSpec.describe Book, type: :model do
  
  # --- BLOCO DE SETUP ---
  # Precisamos de um User e um Author válidos para que o Material seja válido
  let!(:user) { User.create!(email: "book_user@exemplo.com", password: "password123") }
  let!(:author) { Person.create!(name: "Book Author", date_of_birth: "1990-01-01") }

  # Um hash de atributos válidos para um Livro
  let(:valid_attributes) do
    {
      title: "Livro de Teste Válido",
      status: "draft",
      user: user,
      author: author,
      isbn: "9783161484100", # ISBN-13 válido
      page_count: 150
    }
  end
  # --- FIM DO SETUP ---

  describe "Validações" do

    # Teste 0: Objeto válido com todos os atributos corretos
    context "quando todos os atributos são válidos" do
      it "é válido" do
        book = Book.new(valid_attributes)
        expect(book).to be_valid
      end
    end

    # --- TESTES DE VALIDAÇÕES HERDADAS (DO MATERIAL) ---
    # Teste 1: Validações herdadas de Material
    context "validações herdadas de Material" do
      it "é inválido sem um título" do
        book = Book.new(valid_attributes.except(:title)) # Remove o :title
        expect(book).not_to be_valid
        expect(book.errors[:title]).to include("can't be blank")
      end

      # Teste 2: Validação do autor
      it "é inválido sem um autor" do
        book = Book.new(valid_attributes.except(:author)) # Remove o :author
        expect(book).not_to be_valid
        expect(book.errors[:author]).to include("can't be blank")
      end

      # Teste 3: Validação do usuário
      it "é inválido sem um usuário" do
        book = Book.new(valid_attributes.except(:user)) # Remove o :user
        expect(book).not_to be_valid
        expect(book.errors[:user]).to include("can't be blank")
      end
    end

    # --- TESTES DE VALIDAÇÕES ESPECÍFICAS (DO BOOK) ---
    context "validações específicas de Book" do
      
      # Teste 4: Teste do tamanho do ISBN
      it "é inválido se o ISBN tiver 11 caracteres" do
        book = Book.new(valid_attributes.merge(isbn: "12345678901"))
        expect(book).not_to be_valid
        expect(book.errors[:isbn]).to include("must contain exactly 13 digits")
      end

      # Teste 5: Teste do ISBN numérico
      it "é inválido se o ISBN não for numérico" do
        book = Book.new(valid_attributes.merge(isbn: "1234567890ABC"))
        expect(book).not_to be_valid
        expect(book.errors[:isbn]).to include("must contain only numbers")
      end

      # Teste 6: Teste de unicidade do ISBN
      it "é inválido se o ISBN já existir" do
        Book.create!(valid_attributes)
        other_book = Book.new(valid_attributes.merge(title: "Outro Titulo"))
        
        expect(other_book).not_to be_valid
        expect(other_book.errors[:isbn]).to include("has already been taken")
      end
      
      # Teste 7: Teste do número de páginas positivo maior que zero
      it "é inválido se o número de páginas for zero" do
        book = Book.new(valid_attributes.merge(page_count: 0))
        expect(book).not_to be_valid
        expect(book.errors[:page_count]).to include("must be greater than 0")
      end
    end
  end
end