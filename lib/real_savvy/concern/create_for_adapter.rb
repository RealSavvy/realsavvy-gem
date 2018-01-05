module RealSavvy::Concern::CreateForAdapter
  def create(attributes: {})
    post("./api/v3/#{path_prefix}", {data: {attributes: attributes}})
  end
end
