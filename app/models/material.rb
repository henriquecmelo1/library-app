class Material < ApplicationRecord
  belongs_to :user
  belongs_to :author, polymorphic: true # Pode ser Person ou Institution

  enum :status, {
    draft: 'rascunho',
    published: 'publicado',
    archived: 'arquivado'
  }

  
  validates :title, presence: true, length: { in: 3..100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :status, presence: true
  validates :author, presence: true
  validates :user, presence: true
end