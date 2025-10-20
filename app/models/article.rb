class Article < Material
  #Regex para formato DOI
  DOI_REGEX = /\A10\.\d{4,9}\/[-._;()\/:A-Z0-9]+\z/i

  validates :doi, 
    presence: true,
    uniqueness: true,
    format: { with: DOI_REGEX, message: "deve seguir o formato padrão de DOI (ex.: 10.1000/xyz123)" }
end