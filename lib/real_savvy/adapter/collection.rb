class RealSavvy::Adapter::Collection < RealSavvy::Adapter::Base
  path_prefix_is 'collections'

  include RealSavvy::Concern::ShowForAdapter
  include RealSavvy::Concern::IndexForAdapter
  include RealSavvy::Concern::CreateForAdapter
  include RealSavvy::Concern::UpdateForAdapter
  include RealSavvy::Concern::DestroyForAdapter
  include RealSavvy::Concern::InvitesActionsForAdapter

  def add(id:, property_ids:)
    put("./api/v3/#{path_prefix}/#{id}/add", {property_ids: property_ids})
  end

  def remove(id:, property_ids:)
    delete("./api/v3/#{path_prefix}/#{id}/remove", {property_ids: property_ids})
  end

  def search(id:, market_id: nil, page_size: nil, page_number: nil, page: {}, sort: {}, filter: {})
    page[:size] ||= page_size
    page[:number] ||= page_number
    post("./api/v3/#{path_prefix}/#{id}/properties/search", {filter: filter, market_id: market_id, page: page, sort: sort})
  end

  def cluster(id:, market_id: nil, page_size: nil, page_number: nil, page: {}, sort: {}, filter: {}, precision: nil)
    page[:size] ||= page_size
    page[:number] ||= page_number
    post("./api/v3/#{path_prefix}/#{id}/properties/map/clusters", {filter: filter, market_id: market_id, page: page, sort: sort, precision: precision})
  end
end
