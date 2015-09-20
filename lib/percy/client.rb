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

    attr_reader :config

    def initialize(options = {})
      @config = options[:config] || Percy::Config.new
    end
  end
end
