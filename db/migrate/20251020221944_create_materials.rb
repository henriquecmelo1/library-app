class CreateMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :materials do |t|
      t.string :title
      t.text :description
      t.string :status
      t.references :user, null: false, foreign_key: true
      t.references :author, polymorphic: true, null: false
      t.string :type #Coluna para Single Table Inheritance (STI) -> Livro, Artigo, Vídeo
      t.string :isbn
      t.integer :page_count
      t.string :doi
      t.integer :duration_in_minutes
      t.timestamps
    end


    add_index :materials, :isbn, unique: true
    add_index :materials, :doi, unique: true
    add_index :materials, :type # Índice para otimizar consultas STI
  end
end