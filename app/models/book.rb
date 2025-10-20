class Book < Material
  validates :isbn, 
    presence: true, 
    uniqueness: true,
    length: { is: 13 }, 
    numericality: { only_integer: true, message: "deve conter apenas números" }

  validates :page_count, 
    presence: true, 
    numericality: { only_integer: true, greater_than: 0 }
end