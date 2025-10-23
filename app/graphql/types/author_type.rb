# frozen_string_literal: true

module Types
  class AuthorType < Types::BaseUnion
    description "Representa um Author que pode ser de diferentes subclasses"
    possible_types Types::PersonType, Types::InstitutionType

    def self.resolve_type(object, _context)
      case object
      when Person
        Types::PersonType
      when Institution
        Types::InstitutionType
      else
        raise "Unknown Author type: #{object.class.name}"
      end
    end
  end
end
