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
    it 'raises customized timeout errors' do
      stub_request(:get, "#{Percy.config.api_url}/test").to_raise(Faraday::TimeoutError)
      expect do
        Percy.client.get("#{Percy.config.api_url}/test")
      end.to raise_error(Percy::Client::TimeoutError)
    end
    it 'raises customized connection failed errors' do
      stub_request(:get, "#{Percy.config.api_url}/test").to_raise(Faraday::ConnectionFailed)
      expect do
        Percy.client.get("#{Percy.config.api_url}/test")
      end.to raise_error(Percy::Client::ConnectionFailed)
    end
    it 'retries on 502 errors' do
      stub_request(:get, "#{Percy.config.api_url}/test")
        .to_return(body: {foo: true}.to_json, status: 502)
        .then.to_return(body: {foo: true}.to_json, status: 200)

      data = Percy.client.get("#{Percy.config.api_url}/test")
      expect(data).to eq({'foo' => true})
    end
    it 'raises error after 3 retries' do
      stub_request(:get, "#{Percy.config.api_url}/test")
        .to_return(body: {foo: true}.to_json, status: 502).times(3)
      expect do
        Percy.client.get("#{Percy.config.api_url}/test")
      end.to raise_error(Percy::Client::HttpError)
    end
  end
  describe '#post' do
    it 'performs a POST request to the api_url and parses response' do
      stub_request(:post, "#{Percy.config.api_url}/test").to_return(body: {foo: true}.to_json)
      data = Percy.client.post("#{Percy.config.api_url}/test", {})
      expect(data).to eq({'foo' => true})
    end
    it 'raises customized timeout errors' do
      stub_request(:post, "#{Percy.config.api_url}/test").to_raise(Faraday::TimeoutError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {})
      end.to raise_error(Percy::Client::TimeoutError)
    end
    it 'raises customized connection failed errors' do
      stub_request(:post, "#{Percy.config.api_url}/test").to_raise(Faraday::ConnectionFailed)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {})
      end.to raise_error(Percy::Client::ConnectionFailed)
    end
    it 'retries on 502 errors' do
      stub_request(:post, "#{Percy.config.api_url}/test")
        .to_return(body: {foo: true}.to_json, status: 502)
        .then.to_return(body: {foo: true}.to_json, status: 200)

      data = Percy.client.post("#{Percy.config.api_url}/test", {})
      expect(data).to eq({'foo' => true})
    end
    it 'raises error after 3 retries' do
      stub_request(:post, "#{Percy.config.api_url}/test")
        .to_return(body: {foo: true}.to_json, status: 502).times(3)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {})
      end.to raise_error(Percy::Client::HttpError)
    end
  end
end
