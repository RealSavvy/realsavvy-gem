class RealSavvy::Adapter::SavedSearch < RealSavvy::Adapter::Base
  path_prefix_is 'saved_searches'

  include RealSavvy::Concern::ShowForAdapter
  include RealSavvy::Concern::IndexForAdapter
  include RealSavvy::Concern::CreateForAdapter
  include RealSavvy::Concern::UpdateForAdapter
  include RealSavvy::Concern::DestroyForAdapter
  
  include RealSavvy::Concern::InvitesActionsForAdapter
end
