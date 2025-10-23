# frozen_string_literal: true

module Types
  class PersonType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :date_of_birth, GraphQL::Types::ISO8601Date
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
