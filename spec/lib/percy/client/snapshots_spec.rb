RSpec.describe Percy::Client::Snapshots, :vcr do
  describe '#create_snapshot' do
    it 'creates a build' do
      build = Percy.create_build('fotinakis/percy-examples')
      snapshot = Percy.create_snapshot(build['data']['id'], resources)

      expect(snapshot['data']).to be
      expect(snapshot['data']['id']).to be
      expect(snapshot['data']['type']).to eq('snapshots')
      expect(snapshot['data']['attributes']['state']).to eq('pending')
    end
  end
end
