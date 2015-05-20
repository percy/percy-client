RSpec.describe Percy do
  before(:each) { Percy.reset }
  describe '#config' do
    it 'returns a config object' do
      expect(Percy.config.api_url).to eq('http://localhost:3000/api/v1')
    end
  end
  describe '#client' do
    it 'returns a Percy::Client that is passed the global config object by default' do
      config = Percy.config
      expect(Percy.client.config).to eq(config)
    end
  end
  describe '#reset' do
    it 'clears the main global config object' do
      old_config = Percy.client.config
      Percy.reset
      expect(old_config).to_not eq(Percy.config)
    end
  end
end