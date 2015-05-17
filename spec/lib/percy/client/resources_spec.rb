require 'digest'

RSpec.describe Percy::Client::Resources, :vcr do
  describe 'Percy::Client::Resource' do
    let(:content) { '<h1>hello world!</h1>' }
    let(:sha) { Digest::SHA256.hexdigest(content) }

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
end
