require 'bundler/setup'
require 'pry'
require 'real_savvy'


module RealSavvyTestSupport
  COMPLEX_ID = 'north_texas_real_estate_information_systems~72621119'.freeze
  EXAMPLE_FILE = File.read(File.dirname(__FILE__) + '/fixtures/jsonapi.json').freeze
  TOKEN = "9ef62ef16d65f58460481b2ff85b3df157b6e0b36720a2bf3b94be56ad9d77995fbe58ce1a0752fdc3f54710778a7030ec8707ef3f45b11954b98c950fae488c4cf7c9ffa154b39d0f4e9c02c86ac266ac74e71470e2d28f9fefe0b055972b034c29de566f1771bc308d0c1664320a05aa316da0361d619be84202af99f911d5d46cfcab884893362be906586c6b44a20725ac3d82d1b1081ee2efb5f7554c84a48a4b50dd95d96fb4b1a910f6848821e4aade7378f8eefd3c4797cca9320294bc98e807bc26ad1fb7c0986365f97495e7d2c6bd4ccf4faf0d731ec3b14236"
end

RSpec.shared_examples "Global helpers" do |sufix|
  before(:each) do
    RealSavvy::Connection.any_instance.stub(:delegate) { |m, *args, &block| response }
  end

  let(:token) do
    RealSavvyTestSupport::TOKEN
  end

  let(:response) do
    OpenStruct.new(
      status: 200,
      body: JSON.parse(RealSavvyTestSupport::EXAMPLE_FILE)
    )
  end

  let(:client) do
    RealSavvy::Client.new(token: token)
  end

  let(:sample_complex_id) do
    RealSavvyTestSupport::COMPLEX_ID
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context "Global helpers"
end
