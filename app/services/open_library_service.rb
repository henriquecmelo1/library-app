require 'httparty'

class OpenLibraryService
  include HTTParty
  base_uri 'https://openlibrary.org'

  def self.fetch_book_data(isbn)
    response = get("/isbn/#{isbn}.json")

    #
    if response.success? && response.headers['content-type'].include?('application/json')
      parsed_data = response.parsed_response
    
      return {
        title: parsed_data['title'],
        page_count: parsed_data['number_of_pages']
      }
    end
    
    #retorna nil se não encontrar ou der erro
    nil
  
  # Resgata qualquer erro de rede ou parse
  rescue StandardError => e
    Rails.logger.error "OpenLibraryService Error: #{e.message}"
    nil
  end
end