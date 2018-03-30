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
      expect(collection.type).to eql('collections')

      expect(collection.relationships.user.type).to eql('users')
      expect(collection.relationships.collaborators).to be_a(Array)

      expect(collection.attributes).to be_a(RealSavvy::Attributes)
      expect(collection.attributes.name).to eql('Favorite Homes')

      expect(collection.links).to be_a(RealSavvy::Links)

      expect(collection.meta).to be_a(RealSavvy::Meta)
    end
  end

  context 'token' do
    it 'maulformed token raises error' do
      expect{ RealSavvy::JWT::Token.decode('foobar') }.to raise_error(RealSavvy::JWT::BadCredentials)
    end

    it 'gives the correct verb range' do
      expect(RealSavvy::JWT::Token.verbs_matches('public')).to eq %w{public read write admin}
      expect(RealSavvy::JWT::Token.verbs_matches('read')).to eq  %w{read write admin}
      expect(RealSavvy::JWT::Token.verbs_matches('write')).to eq %w{write admin}
      expect(RealSavvy::JWT::Token.verbs_matches('admin')).to eq ['admin']
    end

    context 'share token' do
      before(:each) do
        RealSavvy::JWT::Config.retrieve_audience { |token| TestRealSavvySite.new(token.claims['aud']) }
        RealSavvy::JWT::Config.retrieve_subject { |token| TestRealSavvyUser.new(token.claims['sub']) }
        RealSavvy::JWT::Config.validate_token { true }
      end

      it 'can down cast a signed JWT token to a share token and then to short share token' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['read'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        share_token = jwt_token.to_share_token

        expect(share_token.header['alg']).to eq 'none'
        expect(share_token.site).to eq jwt_token.site
        expect(share_token.user).to eq jwt_token.user

        expect(share_token.token).to_not eq jwt_token.token
        expect(share_token.short_token).to_not eq share_token.token
        expect(share_token.short_token.length).to be < share_token.token.length
        expect(JSON.parse(Base64.urlsafe_decode64(share_token.short_token)).keys.length).to eq 2
      end
    end

    context 'scopes' do
      before(:each) do
        RealSavvy::JWT::Config.retrieve_audience { |token| TestRealSavvySite.new(token.claims['aud']) }
        RealSavvy::JWT::Config.retrieve_subject { |token| TestRealSavvyUser.new(token.claims['sub']) }
        RealSavvy::JWT::Config.validate_token { true }
      end

      it 'error is raised when asking for a none existing scope with bang method' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['public'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)
        expect{ jwt_token.scope_includes!('foobar') }.to raise_error(RealSavvy::JWT::Unauthorized)
      end

      it 'gives acccess to public all scoped actions if based verb is given as scope' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['public'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        expect(jwt_token.scope_includes?('public')).to be true
        expect(jwt_token.scope_includes?('read')).to be false
        expect(jwt_token.scope_includes?('write')).to be false
        expect(jwt_token.scope_includes?('admin')).to be false

        expect(jwt_token.scope_includes?('leads', 'public')).to be true
        expect(jwt_token.scope_includes?('leads', 'read')).to be false
        expect(jwt_token.scope_includes?('leads', 'write')).to be false
        expect(jwt_token.scope_includes?('leads', 'admin')).to be false
      end

      it 'gives acccess to read all scoped actions if based verb is given as scope' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['read'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        expect(jwt_token.scope_includes?('public')).to be true
        expect(jwt_token.scope_includes?('read')).to be true
        expect(jwt_token.scope_includes?('write')).to be false
        expect(jwt_token.scope_includes?('admin')).to be false

        expect(jwt_token.scope_includes?('leads', 'public')).to be true
        expect(jwt_token.scope_includes?('leads', 'read')).to be true
        expect(jwt_token.scope_includes?('leads', 'write')).to be false
        expect(jwt_token.scope_includes?('leads', 'admin')).to be false
      end

      it 'gives acccess to write all scoped actions if based verb is given as scope' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['write'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        expect(jwt_token.scope_includes?('public')).to be true
        expect(jwt_token.scope_includes?('read')).to be true
        expect(jwt_token.scope_includes?('write')).to be true
        expect(jwt_token.scope_includes?('admin')).to be false

        expect(jwt_token.scope_includes?('leads', 'public')).to be true
        expect(jwt_token.scope_includes?('leads', 'read')).to be true
        expect(jwt_token.scope_includes?('leads', 'write')).to be true
        expect(jwt_token.scope_includes?('leads', 'admin')).to be false
      end

      it 'gives acccess to write all scoped actions if based verb is given as scope' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['admin'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        expect(jwt_token.scope_includes?('public')).to be true
        expect(jwt_token.scope_includes?('read')).to be true
        expect(jwt_token.scope_includes?('write')).to be true
        expect(jwt_token.scope_includes?('admin')).to be true

        expect(jwt_token.scope_includes?('leads', 'public')).to be true
        expect(jwt_token.scope_includes?('leads', 'read')).to be true
        expect(jwt_token.scope_includes?('leads', 'write')).to be true
        expect(jwt_token.scope_includes?('leads', 'admin')).to be true
      end

      it 'public access to a namespace does not grant top level public access' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['leads:public'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        expect(jwt_token.scope_includes?('public')).to be false
        expect(jwt_token.scope_includes?('read')).to be false
        expect(jwt_token.scope_includes?('write')).to be false
        expect(jwt_token.scope_includes?('admin')).to be false

        expect(jwt_token.scope_includes?('leads', 'public')).to be true
        expect(jwt_token.scope_includes?('leads', 'read')).to be false
        expect(jwt_token.scope_includes?('leads', 'write')).to be false
        expect(jwt_token.scope_includes?('leads', 'admin')).to be false

        expect(jwt_token.scope_includes?('users', 'public')).to be false
        expect(jwt_token.scope_includes?('users', 'read')).to be false
        expect(jwt_token.scope_includes?('users', 'write')).to be false
        expect(jwt_token.scope_includes?('users', 'admin')).to be false
      end

      it 'read access to a namespace does not grant top level read access' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['leads:read'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        expect(jwt_token.scope_includes?('public')).to be false
        expect(jwt_token.scope_includes?('read')).to be false
        expect(jwt_token.scope_includes?('write')).to be false
        expect(jwt_token.scope_includes?('admin')).to be false

        expect(jwt_token.scope_includes?('leads', 'public')).to be true
        expect(jwt_token.scope_includes?('leads', 'read')).to be true
        expect(jwt_token.scope_includes?('leads', 'write')).to be false
        expect(jwt_token.scope_includes?('leads', 'admin')).to be false

        expect(jwt_token.scope_includes?('users', 'public')).to be false
        expect(jwt_token.scope_includes?('users', 'read')).to be false
        expect(jwt_token.scope_includes?('users', 'write')).to be false
        expect(jwt_token.scope_includes?('users', 'admin')).to be false
      end

      it 'write access to a namespace does not grant top level write access' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['leads:write'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        expect(jwt_token.scope_includes?('public')).to be false
        expect(jwt_token.scope_includes?('read')).to be false
        expect(jwt_token.scope_includes?('write')).to be false
        expect(jwt_token.scope_includes?('admin')).to be false

        expect(jwt_token.scope_includes?('leads', 'public')).to be true
        expect(jwt_token.scope_includes?('leads', 'read')).to be true
        expect(jwt_token.scope_includes?('leads', 'write')).to be true
        expect(jwt_token.scope_includes?('leads', 'admin')).to be false

        expect(jwt_token.scope_includes?('users', 'public')).to be false
        expect(jwt_token.scope_includes?('users', 'read')).to be false
        expect(jwt_token.scope_includes?('users', 'write')).to be false
        expect(jwt_token.scope_includes?('users', 'admin')).to be false
      end

      it 'admin access to a namespace does not grant top level admin access' do
        scoped_token_string = RealSavvyTokenStringCreator.create('scopes' => ['leads:admin'])
        jwt_token = RealSavvy::JWT::Token.decode(scoped_token_string)

        expect(jwt_token.scope_includes?('public')).to be false
        expect(jwt_token.scope_includes?('read')).to be false
        expect(jwt_token.scope_includes?('write')).to be false
        expect(jwt_token.scope_includes?('admin')).to be false

        expect(jwt_token.scope_includes?('leads', 'public')).to be true
        expect(jwt_token.scope_includes?('leads', 'read')).to be true
        expect(jwt_token.scope_includes?('leads', 'write')).to be true
        expect(jwt_token.scope_includes?('leads', 'admin')).to be true

        expect(jwt_token.scope_includes?('users', 'public')).to be false
        expect(jwt_token.scope_includes?('users', 'read')).to be false
        expect(jwt_token.scope_includes?('users', 'write')).to be false
        expect(jwt_token.scope_includes?('users', 'admin')).to be false
      end
    end

    context 'for site' do
      before(:each) do
        RealSavvy::JWT::Config.retrieve_audience { |token| TestRealSavvySite.new(token.claims['aud']) }
        RealSavvy::JWT::Config.retrieve_subject { |token| TestRealSavvySite.new(token.claims['sub']) }
      end

      it 'can handle a valid token' do
        RealSavvy::JWT::Config.validate_token { true }

        jwt_token = RealSavvy::JWT::Token.decode(token)

        expect(jwt_token.for_site?).to be true
        expect(jwt_token.for_site!).to be true
        expect(jwt_token.for_user?).to be false
        expect{ jwt_token.for_user! }.to raise_error(RealSavvy::JWT::Unauthorized)
        expect(jwt_token.imposter?).to be false
        expect(jwt_token.valid?).to be true
      end

      it 'can handle a none valid token' do
        RealSavvy::JWT::Config.validate_token { false }

        jwt_token = RealSavvy::JWT::Token.decode(token)

        expect(jwt_token.for_site?).to be true
        expect(jwt_token.for_site!).to be true
        expect(jwt_token.for_user?).to be false
        expect{ jwt_token.for_user! }.to raise_error(RealSavvy::JWT::Unauthorized)
        expect(jwt_token.imposter?).to be false
        expect(jwt_token.valid?).to be false
      end
    end

    context 'for user' do
      before(:each) do
        RealSavvy::JWT::Config.retrieve_audience { |token| TestRealSavvySite.new(token.claims['aud']) }
        RealSavvy::JWT::Config.retrieve_subject { |token| TestRealSavvyUser.new(token.claims['sub']) }
      end

      it 'short token works correctly for token' do
        RealSavvy::JWT::Config.validate_token { true }

        jwt_token = RealSavvy::JWT::Token.decode(token)

        expect(jwt_token.short_token).to_not eq jwt_token.token
        expect(jwt_token.short_token.length).to be < jwt_token.token.length
      end

      it 'can handle a valid token' do
        RealSavvy::JWT::Config.validate_token { true }

        jwt_token = RealSavvy::JWT::Token.decode(token)

        expect(jwt_token.for_site?).to be false
        expect{ jwt_token.for_site! }.to raise_error(RealSavvy::JWT::Unauthorized)
        expect(jwt_token.for_user?).to be true
        expect(jwt_token.for_user!).to be true
        expect(jwt_token.imposter?).to be false
        expect(jwt_token.valid?).to be true
      end

      it 'can handle a none valid token' do
        RealSavvy::JWT::Config.validate_token { false }

        jwt_token = RealSavvy::JWT::Token.decode(token)

        expect(jwt_token.for_site?).to be false
        expect{ jwt_token.for_site! }.to raise_error(RealSavvy::JWT::Unauthorized)
        expect(jwt_token.for_user?).to be true
        expect(jwt_token.for_user!).to be true
        expect(jwt_token.imposter?).to be false
        expect(jwt_token.valid?).to be false
      end
    end

    context 'for imposter' do
      before(:each) do
        RealSavvy::JWT::Config.retrieve_audience { |token| TestRealSavvySite.new(token.claims['aud']) }
        RealSavvy::JWT::Config.retrieve_subject { |token| TestRealSavvyImposter.new(token.claims['sub']) }

        it 'can handle a valid token' do
          RealSavvy::JWT::Config.validate_token { true }

          jwt_token = RealSavvy::JWT::Token.decode(token)

          expect(jwt_token.for_site?).to be false
          expect{ jwt_token.for_site! }.to raise_error(RealSavvy::JWT::Unauthorized)
          expect(jwt_token.for_user?).to be true
          expect(jwt_token.for_user!).to be true
          expect(jwt_token.imposter?).to be true
          expect(jwt_token.valid?).to be true
        end

        it 'can handle a none valid token' do
          RealSavvy::JWT::Config.validate_token { false }

          jwt_token = RealSavvy::JWT::Token.decode(token)

          expect(jwt_token.for_site?).to be false
          expect{ jwt_token.for_site! }.to raise_error(RealSavvy::JWT::Unauthorized)
          expect(jwt_token.for_user?).to be true
          expect(jwt_token.for_user!).to be true
          expect(jwt_token.imposter?).to be true
          expect(jwt_token.valid?).to be false
        end
      end
    end
  end
end
