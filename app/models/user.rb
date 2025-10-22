class User < ApplicationRecord
  has_secure_password #passowrd_digest

  has_many :materials, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "format is invalid" }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end