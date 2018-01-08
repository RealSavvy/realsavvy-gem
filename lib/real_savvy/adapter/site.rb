class RealSavvy::Adapter::Site < RealSavvy::Adapter::Base
  path_prefix_is 'sites'

  def me
    get("./api/v3/#{path_prefix}/me")
  end
end
