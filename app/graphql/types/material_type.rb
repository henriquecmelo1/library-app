# frozen_string_literal: true

module Types
  class MaterialType < Types::BaseObject
    field :id, ID, null: false
    field :title, String
    field :description, String
    field :status, String
    field :user_id, Integer, null: false
    field :author, Types::AuthorType, null: false
    field :type, String
    field :isbn, String
    field :page_count, Integer
    field :doi, String
    field :duration_in_minutes, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
