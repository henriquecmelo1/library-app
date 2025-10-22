require 'rails_helper'

RSpec.describe Person, type: :model do
  
  # Um hash de atributos válidos para uma Pessoa
  let(:valid_attributes) do
    {
      name: "Machado de Assis",
      date_of_birth: Date.new(1839, 6, 21)
    }
  end

  describe "Validações" do

    # Teste 0: Attributos válidos
    context "quando todos os atributos são válidos" do
      it "é válido" do
        person = Person.new(valid_attributes)
        expect(person).to be_valid
      end
    end

    # --- TESTES DE NOME (Req 3.6) ---
    context "validação do nome" do
      # Teste 1: Presença de nome
      it "é inválido sem um nome" do
        person = Person.new(valid_attributes.except(:name))
        expect(person).not_to be_valid
        expect(person.errors[:name]).to include("can't be blank")
      end

      # Teste 2: Tamanho do nome
      it "é inválido se o nome tiver menos de 3 caracteres" do
        person = Person.new(valid_attributes.merge(name: "Al"))
        expect(person).not_to be_valid
        expect(person.errors[:name]).to include("is too short (minimum is 3 characters)")
      end

      # Teste 3: Tamanho do nome
      it "é inválido se o nome tiver mais de 80 caracteres" do
        long_name = "a" * 81
        person = Person.new(valid_attributes.merge(name: long_name))
        expect(person).not_to be_valid
        expect(person.errors[:name]).to include("is too long (maximum is 80 characters)")
      end
    end

    # --- TESTES DE DATA DE NASCIMENTO (Req 3.6) ---
    context "validação da data de nascimento" do
      # Teste 4: Presença de data de nascimento
      it "é inválido sem uma data de nascimento" do
        person = Person.new(valid_attributes.except(:date_of_birth))
        expect(person).not_to be_valid
        expect(person.errors[:date_of_birth]).to include("can't be blank")
      end

      # Teste 5: Data de nascimento no futuro
      it "é inválido se a data de nascimento for futura" do
        future_date = Date.today + 1.day
        person = Person.new(valid_attributes.merge(date_of_birth: future_date))
        
        expect(person).not_to be_valid
        expect(person.errors[:date_of_birth]).to include("can not be in the future")
      end
    end
  end

  # --- BLOCO DE ASSOCIAÇÕES ---
  describe "Associações e Regras de Negócio" do
    
    let!(:user) { User.create!(email: "person_test@exemplo.com", password: "password123") }
    let!(:author) { Person.create!(valid_attributes) }

    # Teste 6: Restrição de exclusão com materiais associados
    it "não pode ser destruído se tiver materiais associados (dependent: :restrict_with_error)" do
      Book.create!(
        title: "Livro Associado",
        status: "draft",
        user: user,
        author: author, # <--- Associado
        isbn: "1234567890123",
        page_count: 10
      )
      
      author.destroy # Tenta destruir a pessoa com material associado

      expect(author).not_to be_destroyed 
      
      # Verifica se o erro correto foi adicionado ao objeto
      expect(author.errors[:base]).to include("Cannot delete record because dependent materials exist")
    end

    # Teste 7: Permitir exclusão sem materiais associados
    it "pode ser destruído se não tiver materiais associados" do
      # (Nenhum material é criado neste teste)
      
      # Tenta destruir a pessoa e espera que mude a contagem
      expect { author.destroy }.to change { Person.count }.by(-1)
      
      # Verifica se a pessoa FOI destruída
      expect(author).to be_destroyed
    end
  end
end