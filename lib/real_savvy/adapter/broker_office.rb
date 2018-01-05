class RealSavvy::Adapter::BrokerOffice < RealSavvy::Adapter::Base
  path_prefix_is 'broker_offices'

  include RealSavvy::Concern::ComplexShowForAdapter
  include RealSavvy::Concern::IndexForAdapter
end
