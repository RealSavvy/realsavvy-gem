class RealSavvy::Adapter::User < RealSavvy::Adapter::Base
  path_prefix_is 'sites'

  def me
    get("./api/v3/#{path_prefix}/me")
  end
end
