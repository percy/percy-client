require 'faraday'

module Percy
  class Client
    module Connection
      class FaradayNiceErrorMiddleware < Faraday::Response::Middleware
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
        @connection = Faraday.new(url: base_url) do |faraday|
          faraday.request :token_auth, @access_token if @access_token

          faraday.use Faraday::Adapter::HTTPClient
          faraday.use Percy::Client::Connection::FaradayNiceErrorMiddleware
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
