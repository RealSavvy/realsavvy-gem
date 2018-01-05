class RealSavvy::Adapter::OpenHouse < RealSavvy::Adapter::Base
  path_prefix_is 'open_houses'

  include RealSavvy::Concern::IndexForAdapter
  include RealSavvy::Concern::ComplexShowForAdapter
end
