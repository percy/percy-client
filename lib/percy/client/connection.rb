require 'openssl'
require 'uri'
require 'faraday'

module Percy
  class Client
    module Connection
      # Faraday 2.x ships adapters as separate gems, so load the excon adapter from faraday-excon.
      # Only on Faraday >= 2: Faraday 0.x has a built-in excon adapter that faraday-excon 1.x would
      # replace, and Faraday 1.x loads faraday-excon itself.
      #
      # faraday-excon 1.x declares no faraday dependency but only works with Faraday < 2, and a
      # gemspec cannot tie the faraday-excon range to the installed faraday (Faraday 0.x installs
      # need faraday-excon < 2 to resolve). So on Faraday 2, faraday-excon >= 2.0 is activated
      # explicitly before requiring it. Kernel#gem (and Bundler's override of it) raises
      # Gem::LoadError when only 1.x is available or locked, which is turned into an actionable
      # error instead of a NoMethodError from inside faraday-excon 1.x's adapter.
      def self.load_excon_adapter!(faraday_version: Faraday::VERSION)
        return false if Gem::Version.new(faraday_version) < Gem::Version.new('2')

        begin
          gem 'faraday-excon', '>= 2.0'
        rescue Gem::LoadError => e
          raise LoadError,
            "percy-client: Faraday #{faraday_version} needs faraday-excon >= 2.0 " \
            "(#{e.message}). Change any faraday-excon pin in your Gemfile to '>= 2.0', then " \
            'run `bundle update faraday-excon`.'
        end

        require 'faraday/excon'
      end

      # Inherits from Faraday::Middleware (present in Faraday 0.x, 1.x and 2.x) and defines #call
      # itself, because Faraday::Response::Middleware was removed in Faraday 2.
      class NiceErrorMiddleware < Faraday::Middleware
        CLIENT_ERROR_STATUS_RANGE = 400...600

        def call(request_env)
          @app.call(request_env).on_complete do |response_env|
            on_complete(response_env)
          end
        end

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
          when 504
            error_class = Percy::Client::GatewayTimeoutError
          when 520..530
            error_class = Percy::Client::CloudflareError
          when CLIENT_ERROR_STATUS_RANGE # Catchall.
            error_class = Percy::Client::HttpError
          end

          return unless error_class

          raise error_class.new(
            env.status, env.method.upcase, env.url, env.body,
            "Got #{env.status} (#{env.method.upcase} #{env.url}):\n#{env.body}",
          )
        end
      end

      def connection
        return @connection if defined?(@connection)

        parsed_uri = URI.parse(config.api_url)
        base_url = "#{parsed_uri.scheme}://#{parsed_uri.host}:#{parsed_uri.port}"

        @connection = Faraday.new(url: base_url) do |faraday|
          # Faraday 2 removed the :token_auth middleware, and its replacement (:authorization) does
          # not exist in Faraday 0.15. Setting the header directly works on 0.15 through 2.x and
          # sends exactly what :token_auth sent, including its String#inspect quoting/escaping.
          if config.access_token
            faraday.headers['Authorization'] = "Token token=#{config.access_token.to_s.inspect}"
          end
          faraday.use Percy::Client::Connection::NiceErrorMiddleware
          faraday.adapter :excon
        end

        @connection
      end

      def get(path, options = {})
        retries = options[:retries] || 3

        begin
          response = connection.get do |request|
            request.url(path)
            request.headers.merge! _headers
          end
        rescue Faraday::TimeoutError
          raise Percy::Client::TimeoutError
        rescue Faraday::ConnectionFailed
          raise Percy::Client::ConnectionFailed
        rescue Percy::Client::ServerError => e
          # Retry on 5XX errors.
          if (retries -= 1) >= 0
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
            request.headers.merge! _headers
            request.body = data.to_json
          end
        rescue Faraday::TimeoutError
          if (retries -= 1) >= 0
            retry
          end
          raise Percy::Client::TimeoutError
        rescue Faraday::ConnectionFailed
          raise Percy::Client::ConnectionFailed
        rescue Percy::Client::ServerError => e
          # Retry on 5XX errors.
          if (retries -= 1) >= 0
            sleep(rand(1..3))
            retry
          end

          raise e
        end

        JSON.parse(response.body)
      end

      def _headers
        {
          'Content-Type' => 'application/vnd.api+json',
          'User-Agent' => _user_agent,
        }
      end

      def _user_agent
        # rubocop 0.58 (from percy-style) does not accept a leading-underscore method memoizing
        # into @_user_agent; renaming would break _reset_user_agent, so keep the name as on master.
        @_user_agent ||= begin # rubocop:disable Naming/MemoizedInstanceVariableName
          client = [
            "Percy/#{_api_version}",
            client_info,
            "percy-client/#{VERSION}",
          ].compact.join(' ')

          environment = [
            environment_info,
            "ruby/#{_ruby_version}",
            Percy::Client::Environment.ci_info,
          ].compact.join('; ')

          "#{client} (#{environment})"
        end
      end

      def _reset_user_agent
        @_user_agent = nil
      end

      def _api_version
        config.api_url.match(/\w+$/).to_s
      end

      def _ruby_version
        "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"
      end

      load_excon_adapter!
    end
  end
end
