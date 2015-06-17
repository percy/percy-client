require 'uri'
require 'faraday'

module Percy
  class Client
    module Connection
      class NoCookiesHTTPClientAdapter < Faraday::Adapter::HTTPClient
        def client
          @client ||= ::HTTPClient.new
          @client.cookie_manager = nil
          @client
        end
      end

      class NiceErrorMiddleware < Faraday::Response::Middleware
        CLIENT_ERROR_STATUS_RANGE = 400...600

        def on_complete(env)
          case env[:status]
          when 407
            # Mimic the behavior that we get with proxy requests with HTTPS.
            raise Faraday::Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
          when CLIENT_ERROR_STATUS_RANGE
            raise Percy::Client::ClientError.new(
              env, "Got #{env.status} (#{env.method.upcase} #{env.url}):\n#{env.body}")
          end
        end
      end

      def connection
        return @connection if defined?(@connection)
        parsed_uri = URI.parse(config.api_url)
        base_url = "#{parsed_uri.scheme}://#{parsed_uri.host}:#{parsed_uri.port}"
        @connection = Faraday.new(url: base_url) do |faraday|
          faraday.request :token_auth, config.access_token if config.access_token

          faraday.use Percy::Client::Connection::NoCookiesHTTPClientAdapter
          faraday.use Percy::Client::Connection::NiceErrorMiddleware
        end
        @connection
      end

      def get(path)
        response = connection.get do |request|
          request.url(path)
          request.headers['Content-Type'] = 'application/vnd.api+json'
        end
        JSON.parse(response.body)
      end

      def post(path, data)
        response = connection.post do |request|
          request.url(path)
          request.headers['Content-Type'] = 'application/vnd.api+json'
          request.body = data.to_json
        end
        JSON.parse(response.body)
      end
    end
  end
end
