class ApplicationController < ActionController::API
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Evita criar parâmetros aninhados automaticamente
  wrap_parameters false

  before_action :authorize_request

  private

  def authorize_request
    # 1. Pega o token do cabeçalho 'Authorization'
    header = request.headers["Authorization"]

    # Remove o "Bearer " do início do token
    token = header.split(" ").last if header

    begin
      # 2. Pega sua chave secreta
      secret_key = ENV["JWT_SECRET_KEY"]

      # 3. Decodifica o token
      @decoded = JWT.decode(token, secret_key)

      # 4. Encontra o usuário pelo ID que estava no token
      @current_user = User.find(@decoded[0]["user_id"])

    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      # 5. Se o token for inválido ou o usuário não existir, retorna erro
      render json: { error: "Não autorizado" }, status: :unauthorized
    end
  end
end
