class RealSavvy::Adapter::User < RealSavvy::Adapter::Base
  path_prefix_is 'users'

  include RealSavvy::Concern::ShowForAdapter
  include RealSavvy::Concern::IndexForAdapter
  include RealSavvy::Concern::CreateForAdapter
  include RealSavvy::Concern::UpdateForAdapter
  include RealSavvy::Concern::DestroyForAdapter

  def me
    get("./api/v3/#{path_prefix}/me")
  end
end
