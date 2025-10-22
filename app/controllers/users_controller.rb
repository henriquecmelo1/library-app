class UsersController < ApplicationController

  skip_before_action :authorize_request, only: [:create]

  def create # Signup (post /signup)
    @user = User.new(user_params)

    if @user.save
      render json: { message: "User created successfully!" }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def show # Check login
    render json: { message: "Authenticated user", user: @current_user }, status: :ok
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
