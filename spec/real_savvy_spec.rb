require "spec_helper"

RSpec.describe RealSavvy do
  it 'can get each adapter behind a proxy form the client' do
    RealSavvy::Client::ADAPTER_LOOKUP.each do |method, adapter|
      expect(client.send(method)).to be_a(RealSavvy::Client::AdapterProxy)
      expect(client.send(method).adapter).to be_a(adapter)
    end
  end


  context 'agent profile' do
    it 'index' do
      expect(client.agent_profiles.index).to be_a(RealSavvy::Document)
    end

    it 'show' do
      expect(client.agent_profiles.show(complex_id: sample_complex_id)).to be_a(RealSavvy::Document)
    end
  end

  context 'agent' do
    it 'index' do
      expect(client.agents.index).to be_a(RealSavvy::Document)
    end

    it 'show' do
      expect(client.agents.show(id: 5)).to be_a(RealSavvy::Document)
    end
  end
end
