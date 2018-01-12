require 'faraday'
require 'faraday_middleware'

class RealSavvy::Connection
  attr_reader :faraday

  def initialize(client:)
    @faraday = ::Faraday.new(client.api_url) do |faraday|
                  faraday.request :json
                  faraday.response :json

                  faraday.response :logger, client.logger if client.logging?
                  faraday.adapter Faraday.default_adapter

                  faraday.headers['Authorization'] = "Bearer #{client.token}"
                  faraday.params['impersonated_user_id'] = client.impersonated_user_id if client.impersonated_user_id
              end
  end

  private

  def delegate(m, *args, &block)
    faraday.send(m, *args, &block)
  end

  def method_missing(m, *args, &block)
    delegate(m, *args, &block)
  end
end
