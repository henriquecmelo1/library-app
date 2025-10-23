# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # 1. Campo para listar TODOS os materiais
    field :materials, [Types::MaterialType], null: false do
      description "Retorna uma lista de todos os materiais publicados"
    end
    
    # 1b. O método que "resolve" (busca) os dados para o campo :materials
    def materials
      # Você pode (e deve) filtrar por status aqui, como na sua API REST
      Material.where(status: 'published')
    end

    # 2. Campo para buscar UM material por ID
    field :material, Types::MaterialType, null: true do
      description "Encontra um material pelo seu ID"
      argument :id, ID, required: true
    end

    # 2b. O método que "resolve" o campo :material
    def material(id:)
      Material.find_by(id: id, status: 'published')
    end

    # --- Consulta para Autores ---
    # (Para cumprir 100% do requisito)
    
    field :person, Types::PersonType, null: true do
      description "Encontra uma Pessoa pelo seu ID"
      argument :id, ID, required: true
    end
    
    def person(id:)
      Person.find_by(id: id)
    end
    
    field :institution, Types::InstitutionType, null: true do
      description "Encontra uma Organização pelo seu ID"
      argument :id, ID, required: true
    end
    
    def institution(id:)
      Institution.find_by(id: id)
    end


  end
end
