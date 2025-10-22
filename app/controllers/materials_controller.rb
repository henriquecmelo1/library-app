class MaterialsController < ApplicationController
  
 # rotas publicas
  skip_before_action :authorize_request, only: [:index, :show, :search]

  # Encontra o material para :show, :update, :destroy
  before_action :set_material, only: [:show, :update, :destroy, :push_status, :pull_status]

  # Verifica se o usuário é o dono para :update, :destroy
  before_action :check_owner, only: [:update, :destroy, :push_status, :pull_status]

  # GET /materials
  def index

    @pagy, @records = pagy(Material.where(status: 'published').order(:id))

    render json: {
      materials: @records,
      pagination: pagy_metadata(@pagy)
    }
  end

  # GET /materials/search
  def search
    # Começamos com a base da query: materiais publicados
    @materials = Material.where(status: 'published')

    # Verificamos os parâmetros um por um
    if params[:title].present?
      @materials = @materials.where("materials.title ILIKE ?", "%#{params[:title]}%")
    
    elsif params[:author].present?
      @materials = @materials.joins("LEFT JOIN people ON materials.author_id = people.id AND materials.author_type = 'Person'")
                             .joins("LEFT JOIN institutions ON materials.author_id = institutions.id AND materials.author_type = 'Institution'")
                             .where("people.name ILIKE :q OR institutions.name ILIKE :q", q: "%#{params[:author]}%")
    
    elsif params[:description].present?
      @materials = @materials.where("materials.description ILIKE ?", "%#{params[:description]}%")
    
    else
      return render json: { error: 'Search parameter must be one of these: title, author, description' }, status: :bad_request
    end

    # Aplicamos o distinct (para o caso do join de autor) e a paginação
    @pagy, @records = pagy(@materials.distinct)
    
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
  
    local_params = material_params

    # Chama a API OpenLibrary se for um livro
    if local_params[:type] == 'Book' && local_params[:isbn].present?
      # Checa se falta alguma coisa
      if local_params[:title].blank? || local_params[:page_count].blank?
        book_data = OpenLibraryService.fetch_book_data(local_params[:isbn])
        
        # Preenche caso a API tenha retornado dados
        if book_data
          local_params[:title] = book_data[:title] if local_params[:title].blank?
          local_params[:page_count] = book_data[:page_count] if local_params[:page_count].blank?
        end
      end
    end

    # Associa ao usuário logado
    @material = @current_user.materials.build(local_params)

    # Salva
    if @material.save
      render json: @material, status: :created
    else
      render json: { errors: @material.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH /materials/:id
  def update
    # @material é definido pelo :set_material
    # A checagem de dono já foi feita pelo :check_owner
    if @material.update(material_params)
      render json: @material
    else
      render json: { errors: @material.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /materials/:id
  def destroy
    # @material é definido pelo :set_material
    # A checagem de dono já foi feita pelo :check_owner
    @material.destroy
    head :no_content # Retorna status 204 (No Content)
  end

  # PATCH /materials/:id/push_status

  def push_status
    # Usamos um 'case' para controlar a transição
    case @material.status
    when "draft"
      if @material.update(status: :published)
        render json: @material, status: :ok
      else
        render json: { errors: @material.errors.full_messages }, status: :unprocessable_content
      end
    when "published"
      if @material.update(status: :archived)
        render json: @material, status: :ok
      else
        render json: { errors: @material.errors.full_messages }, status: :unprocessable_content
      end
    when "archived"
      render json: { error: "Não é possível avançar o status 'arquivado'" }, status: :bad_request
    end
  end

  # PATCH /materials/:id/pull_status
  def pull_status
    case @material.status
    when "archived"
      if @material.update(status: :published)
        render json: @material, status: :ok
      else
        render json: { errors: @material.errors.full_messages }, status: :unprocessable_entity
      end
    when "published"
      if @material.update(status: :draft)
        render json: @material, status: :ok
      else
        render json: { errors: @material.errors.full_messages }, status: :unprocessable_entity
      end
    when "draft"
      render json: { error: "Não é possível reverter o status 'rascunho'" }, status: :bad_request
    end
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
    render json: { error: 'Material not found' }, status: :not_found
  end

  # Verifica se o usuário logado é o criador do material (Req 2.3)
  def check_owner
    unless @material.user_id == @current_user.id
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end