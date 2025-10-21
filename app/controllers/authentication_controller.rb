class AuthenticationController < ApplicationController
  skip_before_action :authorize_request, only: [ :login ]

  def login # Login (post /login)
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])

      secret_key = ENV["JWT_SECRET_KEY"]

      payload = {
        user_id: @user.id,
        exp: 1.minute.from_now.to_i
      }

      token = JWT.encode(payload, secret_key)

      render json: { token: token }, status: :ok
    else
      render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
    end
  end
end
