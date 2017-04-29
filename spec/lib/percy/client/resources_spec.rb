require 'digest'

# rubocop:disable RSpec/MultipleDescribes
RSpec.describe Percy::Client::Resources, :vcr do
  let(:content) { "hello world! #{described_class.name}" }
  let(:sha) { Digest::SHA256.hexdigest(content) }

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

RSpec.describe Percy::Client::Resource do
  let(:content) { "hello world! #{described_class.name}" }
  let(:sha) { Digest::SHA256.hexdigest(content) }

  it 'can be initialized with minimal data' do
    resource = described_class.new('/foo.html', sha: sha)
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
    resource = described_class.new(
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
    expect { described_class.new('/foo.html') }.to raise_error(ArgumentError)
  end

  describe 'object equality' do
    subject(:resource) { described_class.new('/some-content', sha: sha, mimetype: mimetype) }

    let(:sha) { '123456' }
    let(:mimetype) { 'text/plain' }

    describe 'two resources with same properties' do
      let(:other) { described_class.new('/some-content', sha: sha, mimetype: mimetype) }

      it { is_expected.to eq(other) }
      it { is_expected.to eql(other) }
      it { expect(resource.hash).to eq(other.hash) }
      it('makes their array unique') { expect([resource, other].uniq).to eq([resource]) }
    end

    describe 'two resources with different sha' do
      let(:other) { described_class.new('/some-content', sha: sha.reverse, mimetype: mimetype) }

      it { is_expected.not_to eq(other) }
      it { is_expected.not_to eql(other) }
      it { expect(resource.hash).not_to eq(other.hash) }
      it('makes array unique') { expect([resource, other].uniq).to eq([resource, other]) }
    end

    describe 'two resources with different url' do
      let(:other) { described_class.new('/different-content', sha: sha, mimetype: mimetype) }

      it { is_expected.not_to eq(other) }
      it { is_expected.not_to eql(other) }
      it { expect(resource.hash).not_to eq(other.hash) }
      it('makes array unique') { expect([resource, other].uniq).to eq([resource, other]) }
    end

    describe 'two resources with different mimetype' do
      let(:other) { described_class.new('/some-content', sha: sha, mimetype: 'text/css') }

      it { is_expected.not_to eq(other) }
      it { is_expected.not_to eql(other) }
      it { expect(resource.hash).not_to eq(other.hash) }
      it('makes array unique') { expect([resource, other].uniq).to eq([resource, other]) }
    end
  end
end
