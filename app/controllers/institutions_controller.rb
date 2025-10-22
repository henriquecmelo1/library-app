class InstitutionsController < ApplicationController
  # Libera o 'authorize_request' para as rotas públicas de visualização
  skip_before_action :authorize_request, only: [:index, :show]

  # Encontra a instituição para :show, :update, :destroy
  before_action :set_institution, only: [:show, :update, :destroy]

  # GET /institutions
  # Lista todas as instituições (autores), paginado
  def index
    @pagy, @institutions = pagy(Institution.all)
    render json: {
      authors: @institutions,
      pagination: pagy_metadata(@pagy)
    }
  end

  # GET /institutions/:id
  def show
    render json: @institution
  end

  # POST /institutions
  # (Rota protegida - @current_user é necessário)
  def create
    @institution = Institution.new(institution_params)

    if @institution.save
      render json: @institution, status: :created
    else
      render json: { errors: @institution.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH /institutions/:id
  # (Rota protegida - @current_user é necessário)
  def update
    if @institution.update(institution_params)
      render json: @institution
    else
      render json: { errors: @institution.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /institutions/:id
  # (Rota protegida - @current_user é necessário)
  def destroy
    if @institution.destroy
      head :no_content
    else
      render json: { errors: @institution.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_institution
    @institution = Institution.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Author (institution) not found' }, status: :not_found
  end

  def institution_params
    # Validações dos campos (Req 3.7)
    params.require(:institution).permit(:name, :city)
  end
end