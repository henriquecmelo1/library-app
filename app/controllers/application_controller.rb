class ApplicationController < ActionController::API
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern


  include Pagy::Backend # Paginação
  
  wrap_parameters false # Evita criar parâmetros aninhados automaticamente

  before_action :authorize_request # Autentica todas as requisições por padrão

  private

  def authorize_request
    header = request.headers["Authorization"]

    # Remove Bearer
    token = header.split(" ").last if header

    begin
      secret_key = ENV["JWT_SECRET_KEY"]

      @decoded = JWT.decode(token, secret_key)

      @current_user = User.find(@decoded[0]["user_id"])

    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: "Não autorizado" }, status: :unauthorized
    end
  end
end
