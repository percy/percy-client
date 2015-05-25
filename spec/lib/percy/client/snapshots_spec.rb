RSpec.describe Percy::Client::Snapshots, :vcr do
  let(:content) { 'hello world!' }
  let(:sha) { Digest::SHA256.hexdigest(content) }

  describe '#create_snapshot' do
    it 'creates a build' do
      build = Percy.create_build('fotinakis/percy-examples')
      resources = []
      resources << Percy::Client::Resource.new('/foo/test.html', sha: sha, is_root: true)
      resources << Percy::Client::Resource.new('/css/test.css', sha: sha)
      snapshot = Percy.create_snapshot(build['data']['id'], resources, name: 'homepage')

      expect(snapshot['data']).to be
      expect(snapshot['data']['id']).to be
      expect(snapshot['data']['type']).to eq('snapshots')
      expect(snapshot['data']['attributes']['name']).to eq('homepage')
      expect(snapshot['data']['links']['missing-resources']).to be
    end
    it 'fails if no resources are given' do
      build = Percy.create_build('fotinakis/percy-examples')
      expect do
        Percy.create_snapshot(build['data']['id'], [])
      end.to raise_error(Percy::Client::ClientError)
    end
  end
end
