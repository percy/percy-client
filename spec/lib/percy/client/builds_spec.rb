RSpec.describe Percy::Client::Builds, :vcr do
  describe '#create_build' do
    it 'creates a build' do
      build = Percy.create_build('fotinakis/percy-examples')
      expect(build).to be
      expect(build['data']).to be
      expect(build['data']['id']).to be
      expect(build['data']['type']).to eq('builds')
      expect(build['data']['attributes']['state']).to eq('pending')
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
