class RealSavvy::Adapter::Agent < RealSavvy::Adapter::Base
  path_prefix_is 'agents'

  include RealSavvy::Concern::ShowForAdapter
  include RealSavvy::Concern::IndexForAdapter
end
