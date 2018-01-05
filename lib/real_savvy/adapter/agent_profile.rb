class RealSavvy::Adapter::AgentProfile < RealSavvy::Adapter::Base
  path_prefix_is 'agent_profiles'

  include RealSavvy::Concern::ComplexShowForAdapter
  include RealSavvy::Concern::IndexForAdapter
end
