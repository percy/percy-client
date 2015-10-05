RSpec.describe Percy::Client::Builds, :vcr do
  let(:content) { "hello world! #{described_class.name}" }
  let(:sha) { Digest::SHA256.hexdigest(content) }

  describe '#create_build' do
    before(:each) { ENV['PERCY_PULL_REQUEST'] = '123' }
    after(:each) { ENV['PERCY_PULL_REQUEST'] = nil }
    it 'creates a build' do
      build = Percy.create_build('fotinakis/percy-examples')
      expect(build).to be
      expect(build['data']).to be
      expect(build['data']['id']).to be
      expect(build['data']['type']).to eq('builds')
      expect(build['data']['attributes']['state']).to eq('pending')
      expect(build['data']['attributes']['is-pull-request']).to be_truthy
      expect(build['data']['attributes']['pull-request-number']).to eq(123)
      expect(build['data']['relationships']['missing-resources']).to be
      expect(build['data']['relationships']['missing-resources']['data']).to_not be
    end
    it 'accepts optional resources' do
      resources = []
      resources << Percy::Client::Resource.new('/css/test.css', sha: sha)

      build = Percy.create_build('fotinakis/percy-examples', resources: resources)
      expect(build).to be
      expect(build['data']).to be
      expect(build['data']['id']).to be
      expect(build['data']['type']).to eq('builds')
      expect(build['data']['attributes']['state']).to eq('pending')
      expect(build['data']['attributes']['is-pull-request']).to be_truthy
      expect(build['data']['attributes']['pull-request-number']).to eq(123)
      expect(build['data']['relationships']['missing-resources']).to be
      expect(build['data']['relationships']['missing-resources']['data']).to be
      expect(build['data']['relationships']['missing-resources']['data'].length).to eq(1)
    end
    context 'parallel test environment' do
      it 'raises an error if either parallel_nonce or parallel_total_shards is given alone' do
        expect do
          Percy.create_build('fotinakis/percy-examples', parallel_nonce: 123)
        end.to raise_error(ArgumentError)
        expect do
          Percy.create_build('fotinakis/percy-examples', parallel_total_shards: 2)
        end.to raise_error(ArgumentError)
      end
    end
  end
  describe '#finalize_build' do
    it 'finalizes a build' do
      build = Percy.create_build('fotinakis/percy-examples')
      result = Percy.finalize_build(build['data']['id'])
      expect(result).to eq({'success' => true})
    end
  end
end
