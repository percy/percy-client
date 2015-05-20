require 'json'
require 'percy/config'
require 'percy/client/connection'
require 'percy/client/local_git'
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
    class ClientError < Error
      attr_accessor :env
      def initialize(env, *args)
        @env = env
        super(*args)
      end
    end

    attr_reader :config

    def initialize(options = {})
      @config = options[:config] || Percy::Config.new
    end
  end
end
