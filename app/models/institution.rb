class Institution < ApplicationRecord
  has_many :materials, as: :author, dependent: :restrict_with_error

  validates :name, presence: true, length: { in: 3..120 }
  validates :city, presence: true, length: { in: 2..80 }
  
end