class Book < Material
  validates :isbn, 
    presence: true, 
    uniqueness: true,
    numericality: { only_integer: true, message: "must contain only numbers" },
    length: { is: 13, message: "must contain exactly 13 digits" }

  validates :page_count, 
    presence: true, 
    numericality: { only_integer: true, greater_than: 0 }

end