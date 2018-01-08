require 'spec_helper'

RSpec.describe RealSavvy do
  it 'can get each adapter behind a proxy form the client' do
    RealSavvy::Client::ADAPTER_LOOKUP.each do |method, adapter|
      expect(client.send(method)).to be_a(RealSavvy::Client::AdapterProxy)
      expect(client.send(method).adapter).to be_a(adapter)
    end
  end

  context 'agent profile' do
    let(:adapter_instance ) { client.agent_profiles }
    include_examples 'complex show example'
    include_examples 'index example'
  end

  context 'agent' do
    let(:adapter_instance ) { client.agents }
    include_examples 'show example'
    include_examples 'index example'
  end

  context 'broker office' do
    let(:adapter_instance ) { client.broker_offices }
    include_examples 'complex show example'
    include_examples 'index example'
  end

  context 'collection' do
    let(:adapter_instance ) { client.collections }
    include_examples 'show example'
    include_examples 'index example'
    include_examples 'create example'
    include_examples 'update example'
    include_examples 'destroy example'
    include_examples 'invite examples'

    it 'search' do
      expect(adapter_instance.search(id: sample_id, filter: filter)).to be_a(RealSavvy::Document)
    end

    it 'cluster' do
      expect(adapter_instance.search(id: sample_id, filter: filter)).to be_a(RealSavvy::Document)
    end

    it 'add' do
      expect(adapter_instance.add(id: sample_id, property_ids: [sample_complex_id])).to be_a(RealSavvy::Document)
    end

    it 'remove' do
      expect(adapter_instance.remove(id: sample_id, property_ids: [sample_complex_id])).to be_a(RealSavvy::Document)
    end
  end

  context 'markets' do
    let(:adapter_instance ) { client.markets }
    include_examples 'show example'
    include_examples 'index example'
    include_examples 'create example'
    include_examples 'update example'
    include_examples 'destroy example'
  end

  context 'open houses' do
    let(:adapter_instance ) { client.open_houses }
    include_examples 'complex show example'
    include_examples 'index example'
  end

  context 'properties' do
    let(:adapter_instance ) { client.properties }
    include_examples 'complex show example'

    it 'search' do
      expect(adapter_instance.search(filter: filter)).to be_a(RealSavvy::Document)
    end

    it 'cluster' do
      expect(adapter_instance.search(filter: filter)).to be_a(RealSavvy::Document)
    end
  end

  context 'saved searches' do
    let(:adapter_instance ) { client.saved_searches }
    include_examples 'show example'
    include_examples 'index example'
    include_examples 'create example'
    include_examples 'update example'
    include_examples 'destroy example'
    include_examples 'invite examples'
  end

  context 'sites' do
    let(:adapter_instance ) { client.sites }

    it 'me' do
      expect(adapter_instance.me).to be_a(RealSavvy::Document)
    end
  end

  context 'users' do
    let(:adapter_instance ) { client.users }
    include_examples 'show example'
    include_examples 'index example'
    include_examples 'create example'
    include_examples 'update example'
    include_examples 'destroy example'

    it 'me' do
      expect(adapter_instance.me).to be_a(RealSavvy::Document)
    end
  end

  context 'document' do
    it 'are structed correctly' do
      document = client.collections.index
      expect(document.meta).to be_a(RealSavvy::Meta)

      collection = document.results[0]
      expect(collection).to be_a(RealSavvy::Resource::Collection)

      expect(collection.relationships.user).to be_a(RealSavvy::Resource::User)
      expect(collection.relationships.collaborators).to be_a(Array)

      expect(collection.attributes).to be_a(RealSavvy::Attributes)
      expect(collection.attributes.name).to eql('Favorite Homes')

      expect(collection.links).to be_a(RealSavvy::Links)

      expect(collection.meta).to be_a(RealSavvy::Meta)
    end
  end
end
