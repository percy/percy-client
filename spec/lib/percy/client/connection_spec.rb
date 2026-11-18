RSpec.describe Percy::Client::Connection do
  let(:user_agent) do
    "Percy/#{api_version} #{client_info} percy-client/#{Percy::Client::VERSION} "\
    "(#{environment_info}; ruby/#{ruby_version}; #{ci_name}/#{ci_version})"
  end
  let(:content_type) { 'application/vnd.api+json' }
  let(:api_version) { 'v1' }
  let(:ruby_version) { '2.2.6p396' }
  let(:client_info) { 'percy-capybara/3.1.0' }
  let(:environment_info) { 'Rails/4.2.1' }
  let(:ci_name) { :gitlab }
  let(:ci_version) { '8.14.3-ee' }
  let(:uri) { "#{Percy.config.api_url}/test" }

  # Statuses mapped to a Percy::Client::ServerError subclass, which are the ones retried.
  # 501 is deliberately absent: it maps to the generic HttpError and is not retried.
  SERVER_ERROR_CODES = ([500, 502, 503, 504] + (520..530).to_a).freeze

  shared_examples_for 'a connection that sets headers with HTTP method' do |http_method|
    it 'sets headers' do
      stub_request(http_method, uri)
        .with(headers: {'User-Agent' => user_agent, 'Content-Type' => content_type})
        .to_return(body: {foo: true}.to_json)

      expect(Percy.client).to receive(:_api_version).and_return(api_version)
      expect(Percy.client).to receive(:_ruby_version).and_return(ruby_version)

      expect(Percy.client).to receive(:client_info).and_return(client_info)
      expect(Percy.client).to receive(:environment_info).and_return(environment_info)

      expect(Percy::Client::Environment).to receive(:current_ci).and_return(ci_name)
      expect(Percy::Client::Environment).to receive(:ci_version).and_return(ci_version)

      expect(response).to eq('foo' => true)
    end
  end

  describe '#connection' do
    # Guard against a silent fallback to Net::HTTP (e.g. Faraday 2 without faraday-excon).
    it 'uses the excon adapter' do
      builder = Percy.client.connection.builder
      adapter_class =
        if Gem::Version.new(Faraday::VERSION) >= Gem::Version.new('1')
          builder.adapter.klass
        else
          builder.handlers.last.klass
        end

      expect(adapter_class).to eq(Faraday::Adapter::Excon)
    end

    it 'sends the token auth header when an access token is configured' do
      config = Percy::Config.new
      config.access_token = 'abc123'
      client = Percy::Client.new(config: config)
      stub_request(:get, uri)
        .with(headers: {'Authorization' => 'Token token="abc123"'})
        .to_return(body: {foo: true}.to_json)

      expect(client.get(uri)).to eq('foo' => true)
    end
  end

  describe '.load_excon_adapter!' do
    it 'does nothing on Faraday < 2, which has its own excon adapter' do
      expect(described_class).not_to receive(:gem)
      expect(described_class).not_to receive(:require)
      expect(described_class.load_excon_adapter!(faraday_version: '0.15.4')).to eq(false)
    end

    it 'rejects faraday-excon 1.x on Faraday 2 with an actionable error' do
      expect(described_class).to receive(:gem).with('faraday-excon', '>= 2.0')
        .and_raise(Gem::LoadError, "can't activate faraday-excon (>= 2.0), already activated " \
          'faraday-excon-1.1.0')
      expect(described_class).not_to receive(:require)
      expect do
        described_class.load_excon_adapter!(faraday_version: '2.8.1')
      end.to raise_error(LoadError, /needs faraday-excon >= 2\.0 .*-1\.1\.0.*bundle update/)
    end

    it 'activates and loads faraday-excon 2.x on Faraday 2' do
      expect(described_class).to receive(:gem).with('faraday-excon', '>= 2.0').ordered
      expect(described_class).to receive(:require).with('faraday/excon').ordered.and_return(true)
      described_class.load_excon_adapter!(faraday_version: '2.8.1')
    end
  end

  describe '#get' do
    subject(:response) { Percy.client.get(uri) }

    it_behaves_like 'a connection that sets headers with HTTP method', :get

    it 'performs a GET request to the api_url and parses response' do
      stub_request(:get, uri).to_return(body: {foo: true}.to_json)
      expect(response).to eq('foo' => true)
    end

    it 'raises customized timeout errors' do
      stub_request(:get, uri).to_raise(Faraday::TimeoutError)
      expect { response }.to raise_error(Percy::Client::TimeoutError)
    end

    it 'raises customized connection failed errors' do
      stub_request(:get, uri).to_raise(Faraday::ConnectionFailed)
      expect { response }.to raise_error(Percy::Client::ConnectionFailed)
    end

    it 'retries on 5XX errors' do
      allow(Percy.client).to receive(:sleep)

      # Call the client directly: `response` is memoized and would only request once.
      SERVER_ERROR_CODES.each do |error_code|
        stub_request(:get, uri)
          .to_return(body: {foo: true}.to_json, status: error_code)
          .then.to_return(body: {foo: true}.to_json, status: 200)

        expect(Percy.client.get(uri)).to eq('foo' => true)
      end
    end

    it 'does not retry on 501' do
      stub = stub_request(:get, uri).to_return(body: {foo: true}.to_json, status: 501)

      expect { response }.to raise_error(Percy::Client::HttpError)
      expect(stub).to have_been_requested.once
    end

    it 'raises error after 3 retries' do
      stub_request(:get, uri)
        .to_return(body: {foo: true}.to_json, status: 502).times(3)

      expect { response }.to raise_error(Percy::Client::BadGatewayError)
    end
  end

  describe '#post' do
    subject(:response) { Percy.client.post(uri, {}) }

    it_behaves_like 'a connection that sets headers with HTTP method', :post

    it 'performs a POST request to the api_url and parses response' do
      stub_request(:post, uri).to_return(body: {foo: true}.to_json)
      expect(response).to eq('foo' => true)
    end

    it 'passes through arguments' do
      stub_request(:post, uri)
        .with(headers: {'User-Agent' => user_agent, 'Content-Type' => content_type})
        .to_return(body: {foo: true}.to_json)

      expect(Percy.client).to receive(:_user_agent).and_return(user_agent)
      expect(response).to eq('foo' => true)
    end

    it 'raises customized timeout errors' do
      stub_request(:post, uri).to_raise(Faraday::TimeoutError)
      expect { response }.to raise_error(Percy::Client::TimeoutError)
    end

    it 'raises customized connection failed errors' do
      stub_request(:post, uri).to_raise(Faraday::ConnectionFailed)
      expect { response }.to raise_error(Percy::Client::ConnectionFailed)
    end

    context 'with retries enabled' do
      subject(:response) { Percy.client.post(uri, {}, retries: 3) }

      it 'raises an exception on retry exhaustion' do
        stub_request(:post, uri).to_raise(Faraday::TimeoutError)
        expect { response }.to raise_error(Percy::Client::TimeoutError)
      end
    end

    shared_examples_for 'HTTP status raises custom error class' do |http_status, error_class|
      subject(:request) { Percy.client.post(uri, {}, retries: 0) }

      it 'raises custom error classes for some HTTP errors' do
        stub_request(:post, uri).to_return(body: {foo: true}.to_json, status: http_status.to_i)
        expect { request }.to raise_error(error_class)
      end
    end

    http_errors = {
      '400' => Percy::Client::BadRequestError,
      '401' => Percy::Client::UnauthorizedError,
      '402' => Percy::Client::PaymentRequiredError,
      '403' => Percy::Client::ForbiddenError,
      '404' => Percy::Client::NotFoundError,
      '409' => Percy::Client::ConflictError,
      '500' => Percy::Client::InternalServerError,
      '502' => Percy::Client::BadGatewayError,
      '503' => Percy::Client::ServiceUnavailableError,
      '504' => Percy::Client::GatewayTimeoutError,
      '520' => Percy::Client::CloudflareError,
      '530' => Percy::Client::CloudflareError,
    }

    http_errors.each do |http_status, error_class|
      include_examples 'HTTP status raises custom error class', http_status, error_class
    end

    it 'retries on server errors' do
      allow(Percy.client).to receive(:sleep)

      # Call the client directly: `response` is memoized and would only request once.
      SERVER_ERROR_CODES.each do |error_code|
        stub_request(:post, uri)
          .to_return(body: {foo: true}.to_json, status: error_code)
          .then.to_return(body: {foo: true}.to_json, status: 200)

        expect(Percy.client.post(uri, {})).to eq('foo' => true)
      end
    end

    it 'raises error after 3 retries' do
      stub_request(:post, uri)
        .to_return(body: {foo: true}.to_json, status: 502).times(3)

      expect { response }.to raise_error(Percy::Client::BadGatewayError)
    end
  end
end
