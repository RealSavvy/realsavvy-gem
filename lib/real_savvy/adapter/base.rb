class RealSavvy::Adapter::Base
  include RealSavvy::Concern::DelegateToConnection

  def self.path_prefix_is path_prefix
    @path_prefix = path_prefix
  end

  def self.path_prefix
    @path_prefix
  end

  def path_prefix
    self.class.path_prefix
  end

  def initialize(connection:)
    @connection = connection
  end
end
