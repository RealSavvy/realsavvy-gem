class RealSavvy::Adapter::Property < RealSavvy::Adapter::Base
  path_prefix_is 'properties'

  include RealSavvy::Concern::ComplexShowForAdapter

  def search(filter: {}, market_id: nil, page_size: nil, page_number: nil, page: {})
    page[:size] ||= page_size
    page[:number] ||= page_number
    post("./api/v3/#{path_prefix}/search", {filter: filter, market_id: market_id, page: page})
  end

  def cluster(filter: {}, market_id: nil, page_size: nil, page_number: nil, page: {}, precision: nil)
    page[:size] ||= page_size
    page[:number] ||= page_number
    post("./api/v3/#{path_prefix}/map/clusters", {filter: filter, market_id: market_id, page: page, precision: precision})
  end
end
