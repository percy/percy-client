require 'openssl'
require 'uri'
require 'faraday'

module Percy
  class Client
    module Connection
      class NoCookiesHTTPClientAdapter < Faraday::Adapter::HTTPClient
        def client
          @client ||= ::HTTPClient.new
          @client.cookie_manager = nil
          @client.ssl_config.options |= OpenSSL::SSL::OP_NO_SSLv2
          @client.ssl_config.options |= OpenSSL::SSL::OP_NO_SSLv3
          @client
        end
      end

      class NiceErrorMiddleware < Faraday::Response::Middleware
        CLIENT_ERROR_STATUS_RANGE = 400...600

        def on_complete(env)
          error_class = nil
          case env[:status]
          when 400
            error_class = Percy::Client::BadRequestError
          when 401
            error_class = Percy::Client::UnauthorizedError
          when 402
            error_class = Percy::Client::PaymentRequiredError
          when 403
            error_class = Percy::Client::ForbiddenError
          when 404
            error_class = Percy::Client::NotFoundError
          when 409
            error_class = Percy::Client::ConflictError
          when 500
            error_class = Percy::Client::InternalServerError
          when 502
            error_class = Percy::Client::BadGatewayError
          when 503
            error_class = Percy::Client::ServiceUnavailableError
          when CLIENT_ERROR_STATUS_RANGE  # Catchall.
            error_class = Percy::Client::HttpError
          end
          raise error_class.new(
              env.status, env.method.upcase, env.url, env.body,
              "Got #{env.status} (#{env.method.upcase} #{env.url}):\n#{env.body}") if error_class
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

      def get(path, options = {})
        retries = options[:retries] || 3
        begin
          response = connection.get do |request|
            request.url(path)
            request.headers['Content-Type'] = 'application/vnd.api+json'
          end
        rescue Faraday::TimeoutError
          raise Percy::Client::TimeoutError
        rescue Faraday::ConnectionFailed
          raise Percy::Client::ConnectionFailed
        rescue Percy::Client::HttpError => e
          # Retry on 502 errors.
          if e.status == 502 && (retries -= 1) >= 0
            sleep(rand(1..3))
            retry
          end
          raise e
        end
        JSON.parse(response.body)
      end

      def post(path, data, options = {})
        retries = options[:retries] || 3
        begin
          response = connection.post do |request|
            request.url(path)
            request.headers['Content-Type'] = 'application/vnd.api+json'
            request.body = data.to_json
          end
        rescue Faraday::TimeoutError
          raise Percy::Client::TimeoutError
        rescue Faraday::ConnectionFailed
          raise Percy::Client::ConnectionFailed
        rescue Percy::Client::ServerError => e
          if (retries -= 1) >= 0
            sleep(rand(1..3))
            retry
          end
          raise e
        end
        JSON.parse(response.body)
      end
    end
  end
end
