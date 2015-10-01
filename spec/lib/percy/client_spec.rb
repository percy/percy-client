RSpec.describe Percy::Client do
  describe '#config' do
    it 'returns the config object given when initialized' do
      config = Percy::Config.new
      client = Percy::Client.new(config: config)
      expect(client.config).to eq(config)
      expect(client.config.keys).to eq([
        :access_token,
        :api_url,
        :debug,
        :repo,
      ])
      expect(client.config.access_token).to be_nil
      expect(client.config.api_url).to eq(ENV['PERCY_API'])
      expect(client.config.debug).to eq(false)
      expect(client.config.repo).to eq('percy/percy-client')
    end
  end
end