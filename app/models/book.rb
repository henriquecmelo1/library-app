class Book < Material
  validates :isbn, 
    presence: true, 
    uniqueness: true,
    numericality: { only_integer: true, message: "deve conter apenas números" }

  validates :page_count, 
    presence: true, 
    numericality: { only_integer: true, greater_than: 0 }

  validate :isbn_length
  def isbn_length
    unless isbn.length == 10 || isbn.length == 13
      errors.add(:isbn, "must be exactly 10 or 13 characters")
    end
  end

end