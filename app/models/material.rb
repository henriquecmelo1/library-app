class Material < ApplicationRecord
  belongs_to :user
  belongs_to :author, polymorphic: true # Pode ser Person ou Institution

  enum :status, {
    draft: 'rascunho',
    published: 'publicado',
    archived: 'arquivado'
  }, validate: true 

  validates :title, presence: true, length: { in: 3..100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :status, presence: true
  validates :author, presence: true
  validates :user, presence: true

  def as_json(options = {})
    super(options.merge(include: {
      author: {
        only: [:id, :name, :date_of_birth, :city]
      }
    })).compact
  end

  private

  def compact(hash = self.as_json)
    hash.transform_values do |value|
      value.is_a?(Hash) || value.is_a?(Array) ? compact(value) : value
    end.reject { |_, v| v.nil? }
  end
end