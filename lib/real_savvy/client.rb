require 'real_savvy/connection'
require 'real_savvy/concern'
require 'real_savvy/adapter'

class RealSavvy::Client
  ADAPTER_LOOKUP = {
    agent_profiles: RealSavvy::Adapter::AgentProfile,
    agents: RealSavvy::Adapter::Agent,
    broker_offices: RealSavvy::Adapter::BrokerOffice,
    collections: RealSavvy::Adapter::Collection,
    markets: RealSavvy::Adapter::Market,
    open_houses: RealSavvy::Adapter::OpenHouse,
    properties: RealSavvy::Adapter::Property,
    listings: RealSavvy::Adapter::Property,
    saved_searches: RealSavvy::Adapter::SavedSearch,
    site: RealSavvy::Adapter::Site,
    sites: RealSavvy::Adapter::Site,
    users: RealSavvy::Adapter::User,
    user: RealSavvy::Adapter::User,
  }.freeze

  def initialize(token:, api_url: 'https://api.realsavvy.com', logger: nil, impersonated_user_id: nil)
    @token = token
    @logger = logger
    @impersonated_user_id = impersonated_user_id
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

  def impersonated_user_id
    @impersonated_user_id
  end

  class AdapterProxy
    attr_reader :adapter

    def initialize(adapter)
      @adapter = adapter
    end

    private

    def method_missing(method, *args, &block)
      response = @adapter.send(method, *args, &block)
      RealSavvy::Document.new(response.body, status: response.status)
    end
  end

  def get_adapter(name)
    resource_adapaters[name] ||= AdapterProxy.new(ADAPTER_LOOKUP[name].new(connection: connection))
  end

  private

  def resource_adapaters
    @resource_adapaters ||= {}
  end

  def method_missing(m, *args, &block)
    if ADAPTER_LOOKUP[m]
      get_adapter(m)
    else
      super
    end
  end
end
