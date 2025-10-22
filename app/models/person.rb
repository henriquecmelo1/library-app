class Person < ApplicationRecord
  # Associações
  # 'as: :author' define a associação polimórfica
  # dependent: :restrict_with_error impede que um autor seja excluído se tiver materiais associados
  has_many :materials, as: :author, dependent: :restrict_with_error

  
  validates :name, presence: true, length: { in: 3..80 }
  validates :date_of_birth, presence: true
  validate :date_of_birth_cannot_be_in_the_future

  private

  def date_of_birth_cannot_be_in_the_future
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, "can not be in the future")
    end
  end
end