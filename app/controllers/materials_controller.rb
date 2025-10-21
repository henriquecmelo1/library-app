class MaterialsController < ApplicationController
  
 # rotas publicas
  skip_before_action :authorize_request, only: [:index, :show, :search]

  # Encontra o material para :show, :update, :destroy
  before_action :set_material, only: [:show, :update, :destroy]

  # Verifica se o usuário é o dono para :update, :destroy
  before_action :check_owner, only: [:update, :destroy]

  # GET /materials
  def index
    
    @pagy, @records = pagy(Material.order(:id))
    
    render json: {
      materials: @records,
      pagination: pagy_metadata(@pagy)
    }
  end

  # GET /materials/search
  def search
    query = params[:query]
    if query.blank?
      return render json: { error: 'O parâmetro "query" é obrigatório' }, status: :bad_request
    end

    # Busca em materiais, e nos nomes de autores (Pessoa ou Instituição)
    @materials = Material.all
                         .joins("LEFT JOIN people ON materials.author_id = people.id AND materials.author_type = 'Person'")
                         .joins("LEFT JOIN institutions ON materials.author_id = institutions.id AND materials.author_type = 'Institution'")
                         .where("materials.title ILIKE :q OR materials.description ILIKE :q OR people.name ILIKE :q OR institutions.name ILIKE :q", q: "%#{query}%")
                         .distinct

    @pagy, @records = pagy(@materials)
    
    render json: {
      materials: @records,
      pagination: pagy_metadata(@pagy)
    }
  end

  # GET /materials/:id
  def show
    # @material é definido pelo :set_material
    render json: @material
  end

  # POST /materials
  # Cria um material (Book, Article, Video)
  def create
    Rails.logger.info "Creating material with params: #{params.inspect}" # Log the request parameters
    # 1. Filtra os parâmetros
    local_params = material_params

    # 2. Chama a API Externa se for um Livro (Req 2.5)
    if local_params[:type] == 'Book' && local_params[:isbn].present?
      # Só chama a API se o título ou as páginas estiverem faltando
      if local_params[:title].blank? || local_params[:page_count].blank?
        book_data = OpenLibraryService.fetch_book_data(local_params[:isbn])
        
        # Se a API retornou dados, preenche o que faltava
        if book_data
          local_params[:title] = book_data[:title] if local_params[:title].blank?
          local_params[:page_count] = book_data[:page_count] if local_params[:page_count].blank?
        end
      end
    end

    # 3. Constroí o material associado ao usuário logado (Req 3.2)
    # @current_user vem do ApplicationController
    @material = @current_user.materials.build(local_params)

    # 4. Salva (O Rails usará as validações corretas do modelo filho)
    if @material.save
      render json: @material, status: :created
    else
      render json: { errors: @material.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /materials/:id
  def update
    # @material é definido pelo :set_material
    # A checagem de dono já foi feita pelo :check_owner
    if @material.update(material_params)
      render json: @material
    else
      render json: { errors: @material.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /materials/:id
  def destroy
    # @material é definido pelo :set_material
    # A checagem de dono já foi feita pelo :check_owner
    @material.destroy
    head :no_content # Retorna status 204 (No Content)
  end

  private

  # Método "Strong Parameters"
  def material_params
    # Precisamos permitir todos os campos de todos os tipos de material (STI)
    params.require(:material).permit(
      :title, :description, :status, :author_id, :author_type,
      :type, # O campo que define o STI (Book, Article, Video)
      :isbn, :page_count, # Campos de Book
      :doi,                # Campos de Article
      :duration_in_minutes # Campos de Video
    )
  end

  def set_material
    @material = Material.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Material não encontrado' }, status: :not_found
  end

  # Verifica se o usuário logado é o criador do material (Req 2.3)
  def check_owner
    unless @material.user_id == @current_user.id
      render json: { error: 'Não autorizado' }, status: :unauthorized
    end
  end
end