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

  def magic_link(id)
    post("./api/v3/#{path_prefix}/#{id}/magic_link")
  end

  def add_role(id, role)
    post("./api/v3/#{path_prefix}/#{id}/roles", role: role)
  end

  def remove_role(id, role)
    delete("./api/v3/#{path_prefix}/#{id}/roles", role: role)
  end
end
