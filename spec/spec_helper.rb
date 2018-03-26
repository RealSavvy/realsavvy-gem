require 'bundler/setup'
require 'pry'
require 'real_savvy'
require 'ostruct'
require 'json'
require 'securerandom'
require 'openssl'


module RealSavvyTestSupport
  COMPLEX_ID = 'north_texas_real_estate_information_systems~72621119'.freeze
  EXAMPLE_FILE = File.read(File.dirname(__FILE__) + '/fixtures/jsonapi.json').freeze
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(2048)
  PUBLIC_KEY = PRIVATE_KEY.public_key
end

class RealSavvyTokenStringCreator
  def self.create(payload={})
    payload = {
      "iss" => SecureRandom.hex(50),
      "aud" => "audience-#{SecureRandom.hex(50)}",
      "sub" => "subject-#{SecureRandom.hex(50)}"
    }.merge(payload)
    JWT.encode(payload, RealSavvyTestSupport::PRIVATE_KEY, 'RS256')
  end
end

module TestRealSavvyObject
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def ==(o)
    o.class == self.class && o.id == id
  end
end

class TestRealSavvyUser
  include TestRealSavvyObject
  include RealSavvy::JWT::User
end

class TestRealSavvySite
  include TestRealSavvyObject
  include RealSavvy::JWT::Site
end

class TestRealSavvyImposter
  include TestRealSavvyObject
  include RealSavvy::JWT::Imposter

  def user
    TestRealSavvyUser.new
  end
end

RealSavvy::JWT::Config.public_key = RealSavvyTestSupport::PUBLIC_KEY

RSpec.shared_examples 'Global helpers' do |sufix|
  before(:each) do
    allow_any_instance_of(RealSavvy::Connection).to receive(:delegate).and_return(response)
  end

  let(:token) do
    RealSavvyTokenStringCreator.create("scopes" => ["public"])
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

  let(:sample_id) do
    5
  end

  let(:feed) do
    sample_complex_id.split('~')[0]
  end

  let(:key) do
    sample_complex_id.split('~')[1]
  end

  let(:attributes) do
    {foobar: 1}
  end

  let(:email) do
    'andrew@realsavvy.com'
  end

  let(:given) do
    '7471381390813'
  end

  let(:filter) do
    {
      price: {
        min: 100_000,
        max: 200_000,
      }
    }
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context 'Global helpers'
end

RSpec.shared_examples 'show example' do
  it 'uses the given parameter' do
    expect(adapter_instance.show(id: sample_id)).to be_a(RealSavvy::Document)
  end
end

RSpec.shared_examples 'complex show example' do
  it 'show with a one part complex' do
    expect(adapter_instance.show(complex_id: sample_complex_id)).to be_a(RealSavvy::Document)
  end

  it 'show with a two part complex' do
    expect(adapter_instance.show(feed: feed, key: key)).to be_a(RealSavvy::Document)
  end
end

RSpec.shared_examples 'index example' do
  it 'uses the given parameter' do
    expect(adapter_instance.index).to be_a(RealSavvy::Document)
  end
end

RSpec.shared_examples 'create example' do
  it 'uses the given parameter' do
    expect(adapter_instance.create(attributes: attributes)).to be_a(RealSavvy::Document)
  end
end

RSpec.shared_examples 'update example' do
  it 'uses the given parameter' do
    expect(adapter_instance.update(id: sample_id, attributes: attributes)).to be_a(RealSavvy::Document)
  end
end

RSpec.shared_examples 'destroy example' do
  it 'uses the given parameter' do
    expect(adapter_instance.destroy(id: sample_id)).to be_a(RealSavvy::Document)
  end
end

RSpec.shared_examples 'invite examples' do
  it 'invite' do
    expect(adapter_instance.invite(id: sample_id, email: email)).to be_a(RealSavvy::Document)
  end

  it 'accept_invite' do
    expect(adapter_instance.accept_invite(id: sample_id, given: given)).to be_a(RealSavvy::Document)
  end

  it 'uninvite' do
    expect(client.collections.uninvite(id: sample_id, email: email)).to be_a(RealSavvy::Document)
  end
end

RSpec.shared_examples 'search examples' do
  it 'search' do
    expect(adapter_instance.search(id: sample_id, filter: filter)).to be_a(RealSavvy::Document)
  end

  it 'cluster' do
    expect(adapter_instance.search(id: sample_id, filter: filter)).to be_a(RealSavvy::Document)
  end
end
