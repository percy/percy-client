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
  end
  describe '#finalize_build' do
    it 'finalizes a build' do
      build = Percy.create_build('fotinakis/percy-examples')
      result = Percy.finalize_build(build['data']['id'])
      expect(result).to eq({'success' => true})
    end
  end
end
