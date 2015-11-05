RSpec.describe Percy::Client::Snapshots, :vcr do
  let(:content) { "hello world! #{described_class.name}" }
  let(:sha) { Digest::SHA256.hexdigest(content) }

  describe '#create_snapshot' do
    it 'creates a snapshot' do
      build = Percy.create_build('fotinakis/percy-examples')
      resources = []
      resources << Percy::Client::Resource.new('/foo/test.html', sha: sha, is_root: true)
      resources << Percy::Client::Resource.new('/css/test.css', sha: sha)
      snapshot = Percy.create_snapshot(
        build['data']['id'],
        resources,
        name: 'homepage',
        enable_javascript: true,
      )

      expect(snapshot['data']).to be
      expect(snapshot['data']['id']).to be
      expect(snapshot['data']['type']).to eq('snapshots')
      expect(snapshot['data']['attributes']['name']).to eq('homepage')
      expect(snapshot['data']['relationships']['missing-resources']).to be
    end
    it 'fails if no resources are given' do
      build = Percy.create_build('fotinakis/percy-examples')
      expect do
        Percy.create_snapshot(build['data']['id'], [])
      end.to raise_error(Percy::Client::HttpError)
    end
  end
  describe '#finalize_snapshot' do
    it 'finalizes a snapshot' do
      build = Percy.create_build('fotinakis/percy-examples')
      resources = []
      resources << Percy::Client::Resource.new('/foo/test.html', sha: sha, is_root: true)
      resources << Percy::Client::Resource.new('/css/test.css', sha: sha)
      snapshot = Percy.create_snapshot(build['data']['id'], resources, name: 'homepage')

      result = Percy.finalize_snapshot(snapshot['data']['id'])
      expect(result).to eq({'success' => true})
    end
  end
end
