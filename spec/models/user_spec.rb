require 'rails_helper'

RSpec.describe User, type: :model do
  
  # --- BLOCO DE VALIDAÇÕES ---
  describe "Validações" do

    # Teste 0: Caso válido geral
    context "quando todos os atributos são válidos" do
      it "é válido" do
        user = User.new(
          email: "teste@exemplo.com",
          password: "senha-valida-123",
          password_confirmation: "senha-valida-123"
        )
        expect(user).to be_valid
      end
    end

    # --- TESTES DE E-MAIL ---
    context "validação do e-mail" do
      # Teste 1: Validação de presença
      it "é inválido sem um e-mail" do
        user = User.new(email: nil, password: "password123")
        expect(user).not_to be_valid
        # Verifica a mensagem de erro específica
        expect(user.errors[:email]).to include("can't be blank")
      end

      # Teste 2: Validação de formato
      it "é inválido com um formato de e-mail incorreto" do
        user = User.new(password: "password123")
        
        user.email = "naoeumemail"
        expect(user).not_to be_valid

        expect(user.errors[:email]).to include("format is invalid")
      end

      # Teste 3: Validação de unicidade (requer 1 usuário no banco)
      it "é inválido se o e-mail já existir" do
        
        User.create!(email: "duplicado@exemplo.com", password: "password123")
        new_user = User.new(email: "duplicado@exemplo.com", password: "password456")
        
        expect(new_user).not_to be_valid
        expect(new_user.errors[:email]).to include("has already been taken")
      end
    end

    # --- TESTES DE SENHA (PASSWORD) ---
    context "validação da senha" do
      
      # Teste 4: Validação de presença (vem do has_secure_password)
      it "é inválido sem uma senha na criação" do
        user = User.new(email: "teste@exemplo.com", password: nil)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      # Teste 5: Validação de tamanho (length)
      it "é inválido se a senha tiver menos de 6 caracteres" do
        user = User.new(email: "teste@exemplo.com", password: "123")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end

      # Teste 6: Validação de confirmação (vem do has_secure_password)
      it "é inválido se a senha e a confirmação de senha não baterem" do
        user = User.new(
          email: "teste@exemplo.com",
          password: "password123",
          password_confirmation: "outra-senha-456" 
        )
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end

      # Teste 7: Testando o 'if:' da validação (o caso de atualização) (not being used)
      it "é VÁLIDO para um usuário existente atualizar seu e-mail sem fornecer uma nova senha" do
        # 1. Cria um usuário válido e o salva
        user = User.create!(email: "original@exemplo.com", password: "password123")
        
        # 2. Atualiza o e-mail, mas NÃO a senha
        user.email = "novo@exemplo.com"
        
        # 3. O 'if:' na validação da senha deve pular a checagem
        expect(user).to be_valid
      end
    end
  end

  # --- BLOCO DE ASSOCIAÇÕES --- (not being used)
  describe "Associações" do

    let!(:user) { User.create!(email: "user@exemplo.com", password: "password123") }
    let!(:author) { Person.create!(name: "Autor", date_of_birth: "1990-01-01") }
    let!(:material) do
      user.materials.create!(
        title: "Livro para ser deletado",
        status: "draft",
        author: author,
        type: "Book",
        isbn: "1111111111111", 
        page_count: 10
      )
    end

    # Teste 8: dependent: :destroy
    it "destrói os materiais associados quando o usuário é destruído" do
      expect { user.destroy }.to change { Material.count }.by(-1)
    end
  end
end