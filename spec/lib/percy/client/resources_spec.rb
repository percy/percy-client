require 'digest'

RSpec.describe Percy::Client::Resources, :vcr do
  let(:content) { "hello world! #{described_class.name}" }
  let(:sha) { Digest::SHA256.hexdigest(content) }

  describe 'Percy::Client::Resource' do
    it 'can be initialized with minimal data' do
      resource = Percy::Client::Resource.new('/foo.html', sha: sha)
      expect(resource.serialize).to eq({
        'type' => 'resources',
        'id' => sha,
        'attributes' => {
          'resource-url' => '/foo.html',
          'mimetype' => nil,
          'is-root' => nil,
        },
      })
    end
    it 'can be initialized with all data' do
      resource = Percy::Client::Resource.new(
        '/foo new.html',
        sha: sha,
        is_root: true,
        mimetype: 'text/html',
        content: content,
      )
      expect(resource.serialize).to eq({
        'type' => 'resources',
        'id' => sha,
        'attributes' => {
          'resource-url' => '/foo%20new.html',
          'mimetype' => 'text/html',
          'is-root' => true,
        },
      })
    end
    it 'errors if not given sha or content' do
      expect { Percy::Client::Resource.new('/foo.html') }.to raise_error(ArgumentError)
    end
  end
  describe '#upload_resource' do
    it 'returns true with success' do
      build = Percy.create_build('fotinakis/percy-examples')
      resources = [Percy::Client::Resource.new('/foo/test.html', sha: sha, is_root: true)]
      Percy.create_snapshot(build['data']['id'], resources, name: 'homepage')

      # Verify that upload_resource hides conflict errors, though they are output to stderr.
      expect(Percy.upload_resource(build['data']['id'], content)).to be_truthy
      expect(Percy.upload_resource(build['data']['id'], content)).to be_truthy
    end
  end
end
