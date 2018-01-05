require 'real_savvy/connection'
require 'real_savvy/concern'
require 'real_savvy/adapter'

Dir[File.dirname(__FILE__) + '/adapaters/*.rb'].each {|file| require file }

class RealSavvy::Client
  def initialize(token:, logger: nil)
    @token = token
    @logger = logger
  end

  def connection
    @connection ||= RealSavvy::Connection.new(client: self)
  end

  def logger
    @logger
  end

  def logging?
    !!@logging
  end

  def token
    @token
  end

  def properties
    resource_adapaters[:properties] ||= RealSavvy::Adapter::Property.new(connection: connection)
  end

  private

  def resource_adapaters
    @resource_adapaters ||= {}
  end
end
