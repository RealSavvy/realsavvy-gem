class RealSavvy::Adapter::Property < RealSavvy::Adapter::Base
  path_prefix_is 'properties'

  include RealSavvy::Concern::ComplexShowForAdapter

  def search(market_id: nil, page_size: nil, page_number: nil, page: {}, sort: {}, filter: {})
    page[:size] ||= page_size
    page[:number] ||= page_number
    post("./api/v3/#{path_prefix}/search", {filter: filter, market_id: market_id, page: page, sort: sort})
  end

  def cluster(market_id: nil, page_size: nil, page_number: nil, page: {}, sort: {}, filter: {}, precision: nil)
    page[:size] ||= page_size
    page[:number] ||= page_number
    post("./api/v3/#{path_prefix}/map/clusters", {filter: filter, market_id: market_id, page: page, sort: sort, precision: precision})
  end
end
