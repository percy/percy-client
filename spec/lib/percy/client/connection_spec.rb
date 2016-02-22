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
      end.to raise_error(Percy::Client::BadGatewayError)
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
    it 'raises custom error classes for some HTTP errors' do
      stub_request(:post, "#{Percy.config.api_url}/test")
        .to_return(body: {foo: true}.to_json, status: 400)
        .then.to_return(body: {foo: true}.to_json, status: 401)
        .then.to_return(body: {foo: true}.to_json, status: 402)
        .then.to_return(body: {foo: true}.to_json, status: 403)
        .then.to_return(body: {foo: true}.to_json, status: 404)
        .then.to_return(body: {foo: true}.to_json, status: 409)
        .then.to_return(body: {foo: true}.to_json, status: 500)
        .then.to_return(body: {foo: true}.to_json, status: 502)
        .then.to_return(body: {foo: true}.to_json, status: 503)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::BadRequestError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::UnauthorizedError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::PaymentRequiredError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::ForbiddenError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::NotFoundError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::ConflictError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::InternalServerError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::BadGatewayError)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {}, retries: 0)
      end.to raise_error(Percy::Client::ServiceUnavailableError)
    end
    it 'retries on server errors' do
      stub_request(:post, "#{Percy.config.api_url}/test")
        .to_return(body: {foo: true}.to_json, status: 500)
        .then.to_return(body: {foo: true}.to_json, status: 200)

      data = Percy.client.post("#{Percy.config.api_url}/test", {})
      expect(data).to eq({'foo' => true})
    end
    it 'raises error after 3 retries' do
      stub_request(:post, "#{Percy.config.api_url}/test")
        .to_return(body: {foo: true}.to_json, status: 502).times(3)
      expect do
        Percy.client.post("#{Percy.config.api_url}/test", {})
      end.to raise_error(Percy::Client::BadGatewayError)
    end
  end
end
