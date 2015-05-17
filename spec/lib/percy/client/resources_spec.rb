require 'digest'

RSpec.describe Percy::Client::Resources, :vcr do
  let(:content) { 'hello world!' }
  let(:sha) { Digest::SHA256.hexdigest(content) }

  describe 'Percy::Client::Resource' do
    it 'can be initialized with minimal data' do
      resource = Percy::Client::Resource.new(sha, '/foo.html')
      expect(resource.serialize).to eq({
        'type' => 'resources',
        'id' => sha,
        'resource-url' => '/foo.html',
        'mimetype' => nil,
        'is-root' => nil,
      })
    end
    it 'can be initialized with all data' do
      resource = Percy::Client::Resource.new(sha, '/foo.html', is_root: true, mimetype: 'text/html')
      expect(resource.serialize).to eq({
        'type' => 'resources',
        'id' => sha,
        'resource-url' => '/foo.html',
        'mimetype' => 'text/html',
        'is-root' => true,
      })
    end
  end
  describe '#upload_resource' do
    it 'returns true with success' do
      build = Percy.create_build('fotinakis/percy-examples')
      resources = [Percy::Client::Resource.new(sha, '/foo/test.html', is_root: true)]
      Percy.create_snapshot(build['data']['id'], resources, name: 'homepage')

      # Verify that upload_resource hides conflict errors, though they are output to stderr.
      expect(Percy.upload_resource(build['data']['id'], content)).to be_truthy
      expect(Percy.upload_resource(build['data']['id'], content)).to be_truthy
    end
  end
end
