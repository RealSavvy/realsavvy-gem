module RealSavvy::Concern::ShowForAdapter
  def show(id:)
    get("./api/v3/#{path_prefix}/#{id}")
  end
end
