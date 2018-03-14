class RealSavvy::Adapter::Market < RealSavvy::Adapter::Base
  path_prefix_is 'markets'

  include RealSavvy::Concern::ShowForAdapter
  include RealSavvy::Concern::IndexForAdapter
  include RealSavvy::Concern::CreateForAdapter
  include RealSavvy::Concern::UpdateForAdapter
  include RealSavvy::Concern::DestroyForAdapter
end
