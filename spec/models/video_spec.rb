require 'rails_helper'

RSpec.describe Video, type: :model do
  
  # --- BLOCO DE SETUP ---
  # Dados necessários para que um Material (Vídeo) seja válido
  let!(:user) { User.create!(email: "video_user@exemplo.com", password: "password123") }
  let!(:author) { Person.create!(name: "Video Author", date_of_birth: "1990-01-01") }

  # Um hash de atributos válidos para um Vídeo
  let(:valid_attributes) do
    {
      title: "Vídeo de Teste Válido",
      status: "draft",
      user: user,
      author: author,
      duration_in_minutes: 10 # Duração válida (Req 3.5)
    }
  end
  # --- FIM DO SETUP ---

  describe "Validações" do

    # Teste 0: Atributos válidos
    context "quando todos os atributos são válidos" do
      it "é válido" do
        video = Video.new(valid_attributes)
        expect(video).to be_valid
      end
    end

    # --- TESTES DE VALIDAÇÕES HERDADAS (DO MATERIAL) ---
    context "validações herdadas de Material" do
      # Teste 1: Presença de título
      it "é inválido sem um título" do
        video = Video.new(valid_attributes.except(:title))
        expect(video).not_to be_valid
        expect(video.errors[:title]).to include("can't be blank")
      end

      # Teste 2: Presença de autor
      it "é inválido sem um autor" do
        video = Video.new(valid_attributes.except(:author))
        expect(video).not_to be_valid
        expect(video.errors[:author]).to include("can't be blank")
      end
    end

    # --- TESTES DE VALIDAÇÕES ESPECÍFICAS (DO VIDEO) ---
    context "validações específicas de Video (Duração)" do
      
      # Teste 3: Presença de duração
      it "é inválido sem uma duração" do
        video = Video.new(valid_attributes.except(:duration_in_minutes))
        expect(video).not_to be_valid
        expect(video.errors[:duration_in_minutes]).to include("can't be blank")
      end
      
      # Teste 4: Duração deve ser maior que zero
      it "é inválido se a duração for zero" do
        video = Video.new(valid_attributes.merge(duration_in_minutes: 0))
        expect(video).not_to be_valid
        expect(video.errors[:duration_in_minutes]).to include("must be greater than 0")
      end

      # Teste 5: Duração deve ser um número positivo
      it "é inválido se a duração for negativa" do
        video = Video.new(valid_attributes.merge(duration_in_minutes: -10))
        expect(video).not_to be_valid
        expect(video.errors[:duration_in_minutes]).to include("must be greater than 0")
      end

      # Teste 6: Duração deve ser um número inteiro
      it "é inválido se a duração não for um número inteiro" do
        video = Video.new(valid_attributes.merge(duration_in_minutes: 10.5))
        expect(video).not_to be_valid
        expect(video.errors[:duration_in_minutes]).to include("must be an integer")
      end
    end
  end
end