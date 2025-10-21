class PeopleController < ApplicationController
  skip_before_action :authorize_request, only: [:index, :show]
  before_action :set_person, only: [:show, :update, :destroy]

  # GET /people
  # Lista todas as pessoas (autores), paginado
  def index
    @pagy, @people = pagy(Person.all)
    render json: {
      authors: @people,
      pagination: pagy_metadata(@pagy)
    }
  end

  # GET /people/:id
  def show
    render json: @person
  end

  # POST /people
  # (Rota protegida - @current_user é necessário)
  def create
    @person = Person.new(person_params)

    if @person.save
      render json: @person, status: :created
    else
      render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /people/:id
  # (Rota protegida - @current_user é necessário)
  def update
    if @person.update(person_params)
      render json: @person
    else
      render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /people/:id
  # (Rota protegida - @current_user é necessário)
  def destroy
    # Se um autor estiver associado a materiais, o model (dependent: :restrict_with_error)
    # irá impedir a exclusão e gerar um erro, o que é o comportamento correto.
    if @person.destroy
      head :no_content
    else
      render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_person
    @person = Person.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Autor (Pessoa) não encontrado' }, status: :not_found
  end

  def person_params
    # Validações dos campos (Req 3.6)
    params.require(:person).permit(:name, :date_of_birth)
  end
end