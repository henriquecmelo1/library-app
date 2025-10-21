class UsersController < ApplicationController
  def create # Signup (post /signup)
    Rails.logger.info "Received request with params: #{params.inspect}" # Log the request parameters

    @user = User.new(user_params)

    if @user.save
      render json: { message: "Usuário criado com sucesso!" }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end