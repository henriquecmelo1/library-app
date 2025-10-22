require 'rails_helper'

RSpec.describe Institution, type: :model do
  
  # Um hash de atributos válidos para uma Instituição
  let(:valid_attributes) do
    {
      name: "Universidade de Testes",
      city: "Recife"
    }
  end

  describe "Validações" do

    # Teste 0: Atributos válidos
    context "quando todos os atributos são válidos" do
      it "é válido" do
        institution = Institution.new(valid_attributes)
        expect(institution).to be_valid
      end
    end

    # --- TESTES DE NOME (Req 3.7) ---
    context "validação do nome" do
      # Teste 1: Nome ausente
      it "é inválido sem um nome" do
        institution = Institution.new(valid_attributes.except(:name))
        expect(institution).not_to be_valid
        expect(institution.errors[:name]).to include("can't be blank")
      end

      # Teste 2: Nome muito curto
      it "é inválido se o nome tiver menos de 3 caracteres" do
        institution = Institution.new(valid_attributes.merge(name: "U"))
        expect(institution).not_to be_valid
        expect(institution.errors[:name]).to include("is too short (minimum is 3 characters)")
      end

      # Teste 3: Nome muito longo
      it "é inválido se o nome tiver mais de 120 caracteres" do
        long_name = "a" * 121
        institution = Institution.new(valid_attributes.merge(name: long_name))
        expect(institution).not_to be_valid
        expect(institution.errors[:name]).to include("is too long (maximum is 120 characters)")
      end
    end

    # --- TESTES DE CIDADE (Req 3.7) ---
    context "validação da cidade" do
      # Teste 4: Cidade ausente
      it "é inválido sem uma cidade" do
        institution = Institution.new(valid_attributes.except(:city))
        expect(institution).not_to be_valid
        expect(institution.errors[:city]).to include("can't be blank")
      end

      # Teste 5: Cidade muito curta
      it "é inválido se a cidade tiver menos de 2 caracteres" do
        institution = Institution.new(valid_attributes.merge(city: "a"))
        expect(institution).not_to be_valid
        expect(institution.errors[:city]).to include("is too short (minimum is 2 characters)")
      end

      # Teste 6: Cidade muito longa
      it "é inválido se a cidade tiver mais de 80 caracteres" do
        long_city = "a" * 81
        institution = Institution.new(valid_attributes.merge(city: long_city))
        expect(institution).not_to be_valid
        expect(institution.errors[:city]).to include("is too long (maximum is 80 characters)")
      end
    end
  end

  # --- BLOCO DE ASSOCIAÇÕES ---
  describe "Associações e Regras de Negócio" do
    
    let!(:user) { User.create!(email: "inst_test@exemplo.com", password: "password123") }
    let!(:author_inst) { Institution.create!(valid_attributes) }

    # Teste 7: Restrição de exclusão com materiais associados 
    it "não pode ser destruído se tiver materiais associados (dependent: :restrict_with_error)" do
      # Material associado a esta instituição
      Article.create!(
        title: "Artigo Associado",
        status: "draft",
        user: user,
        author: author_inst, # <--- Associado
        doi: "10.1234/inst-test"
      )
      
      # Tenta destruir a instituição
      author_inst.destroy
      
      # Verifica se a instituição NÃO foi destruída
      expect(author_inst).not_to be_destroyed
      
      # Verifica se o erro correto foi adicionado ao objeto
      expect(author_inst.errors[:base]).to include("Cannot delete record because dependent materials exist")
    end

    # Teste 8: Exclusão sem materiais associados
    it "pode ser destruído se não tiver materiais associados" do
      # Tenta destruir a instituição e espera que mude a contagem
      expect { author_inst.destroy }.to change { Institution.count }.by(-1)
      
      # Verifica se a instituição FOI destruída
      expect(author_inst).to be_destroyed
    end
  end
end