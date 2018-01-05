module RealSavvy::Concern::DestroyForAdapter
  def destroy(id:)
    delete("./api/v3/#{path_prefix}/#{id}")
  end
end
