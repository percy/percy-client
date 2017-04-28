require 'digest'

RSpec.describe Percy::Client::Resources, :vcr do
  let(:content) { "hello world! #{described_class.name}" }
  let(:sha) { Digest::SHA256.hexdigest(content) }

  describe 'Percy::Client::Resource' do
    it 'can be initialized with minimal data' do
      resource = Percy::Client::Resource.new('/foo.html', sha: sha)
      expect(resource.serialize).to eq(
        'type' => 'resources',
        'id' => sha,
        'attributes' => {
          'resource-url' => '/foo.html',
          'mimetype' => nil,
          'is-root' => nil,
        },
      )
    end
    it 'can be initialized with all data' do
      resource = Percy::Client::Resource.new(
        '/foo new.html',
        sha: sha,
        is_root: true,
        mimetype: 'text/html',
        content: content,
      )
      expect(resource.serialize).to eq(
        'type' => 'resources',
        'id' => sha,
        'attributes' => {
          'resource-url' => '/foo%20new.html',
          'mimetype' => 'text/html',
          'is-root' => true,
        },
      )
    end
    it 'errors if not given sha or content' do
      expect { Percy::Client::Resource.new('/foo.html') }.to raise_error(ArgumentError)
    end

    describe 'two resources with same properties' do
      subject(:resource) { Percy::Client::Resource.new('/some-content', sha: '123456', mimetype: 'text/plain') }

      let(:other) { Percy::Client::Resource.new('/some-content', sha: '123456', mimetype: 'text/plain') }

      it { is_expected.to eq(other) }
      it { is_expected.to eql(other) }
      it { expect(resource.hash).to eq(other.hash) }
      it('makes their array unique') { expect([resource, other].uniq).to eq([resource]) }
    end

    describe 'two resources with different sha' do
      subject(:resource) { Percy::Client::Resource.new('/some-content', sha: '123456', mimetype: 'text/plain') }

      let(:other) { Percy::Client::Resource.new('/some-content', sha: '654321', mimetype: 'text/plain') }

      it { is_expected.not_to eq(other) }
      it { is_expected.not_to eql(other) }
      it { expect(resource.hash).not_to eq(other.hash) }
      it('makes array unique') { expect([resource, other].uniq).to eq([resource, other]) }
    end

    describe 'two resources with different url' do
      subject(:resource) { Percy::Client::Resource.new('/some-content', sha: '123456', mimetype: 'text/plain') }

      let(:other) { Percy::Client::Resource.new('/different-content', sha: '123456', mimetype: 'text/plain') }

      it { is_expected.not_to eq(other) }
      it { is_expected.not_to eql(other) }
      it { expect(resource.hash).not_to eq(other.hash) }
      it('makes array unique') { expect([resource, other].uniq).to eq([resource, other]) }
    end

    describe 'two resources with different mimetype' do
      subject(:resource) { Percy::Client::Resource.new('/some-content', sha: '123456', mimetype: 'text/plain') }

      let(:other) { Percy::Client::Resource.new('/some-content', sha: '123456', mimetype: 'text/x-plain') }

      it { is_expected.not_to eq(other) }
      it { is_expected.not_to eql(other) }
      it { expect(resource.hash).not_to eq(other.hash) }
      it('makes array unique') { expect([resource, other].uniq).to eq([resource, other]) }
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
