module RealSavvy::Concern::IndexForAdapter
  def index(page_size: nil, page_number: nil, page: {}, sort: {}, filter: {})
    page[:size] ||= page_size
    page[:number] ||= page_number
    get("./api/v3/#{path_prefix}", {page: page, sort: sort, filter: filter})
  end
end
