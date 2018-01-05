module RealSavvy::Concern::UpdateForAdapter
  def update(id:, attributes: {})
    put("./api/v3/#{path_prefix}/#{id}", {data: {attributes: attributes}})
  end
end
