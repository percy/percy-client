RSpec.describe Percy::Client::Connection do
  describe '#connection' do
    it 'disables cookies on faraday httpclient adapter' do
      expect(Percy.client.connection.builder.app.client.cookie_manager).to be_nil
    end
  end
  describe '#get' do
    it 'performs a GET request to the api_url and parses response' do
      stub_request(:get, "#{Percy.config.api_url}/test").to_return(body: {foo: true}.to_json)
      data = Percy.client.get("#{Percy.config.api_url}/test")
      expect(data).to eq({'foo' => true})
    end
  end
  describe '#post' do
    it 'performs a POST request to the api_url and parses response' do
      stub_request(:post, "#{Percy.config.api_url}/test").to_return(body: {foo: true}.to_json)
      data = Percy.client.post("#{Percy.config.api_url}/test", {})
      expect(data).to eq({'foo' => true})
    end
  end
end
