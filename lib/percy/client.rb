require 'json'
require 'percy/config'
require 'percy/client/environment'
require 'percy/client/connection'
require 'percy/client/version'
require 'percy/client/builds'
require 'percy/client/snapshots'
require 'percy/client/resources'

module Percy
  class Client
    include Percy::Client::Connection
    include Percy::Client::Builds
    include Percy::Client::Snapshots
    include Percy::Client::Resources

    class Error < Exception; end
    class TimeoutError < Error; end
    class ConnectionFailed < Error; end
    class HttpError < Error
      attr_reader :status
      attr_reader :method
      attr_reader :url
      attr_reader :body

      def initialize(status, method, url, body, *args)
        @status = status
        @method = method
        @url = url
        @body = body
        super(*args)
      end
    end

    class ClientError < HttpError; end  # 4xx;
    class BadRequestError < ClientError; end  # 400.
    class UnauthorizedError < ClientError; end  # 401.
    class PaymentRequiredError < ClientError; end  # 402.
    class ForbiddenError < ClientError; end  # 403.
    class NotFoundError < ClientError; end  # 404.
    class ConflictError < ClientError; end  # 409.

    class ServerError < HttpError; end  # 5xx.
    class InternalServerError < ServerError; end  # 500.
    class BadGatewayError < ServerError; end  # 502.
    class ServiceUnavailableError < ServerError; end  # 503.

    attr_reader :config

    def initialize(options = {})
      @config = options[:config] || Percy::Config.new
    end
  end
end
