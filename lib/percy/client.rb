require 'json'
require 'percy/client/connection'
require 'percy/client/local_git'
require 'percy/client/version'
require 'percy/client/builds'
require 'percy/client/snapshots'
require 'percy/client/resources'

module Percy
  class Client
    include Percy::Client::Connection
    include Percy::Client::LocalGit
    include Percy::Client::Builds
    include Percy::Client::Snapshots
    include Percy::Client::Resources

    API_BASE_URL = ENV['PERCY_API'] || 'https://percy.io'
    API_VERSION = ENV['PERCY_API_VERSION'] || 'v1'

    attr_accessor :access_token

    def initialize(options = {})
      @access_token = options[:access_token] || ENV['PERCY_TOKEN']
    end

    def base_url
      API_BASE_URL
    end

    def base_path
      "/api/#{API_VERSION}"
    end

    def full_base
      "#{base_url}#{base_path}"
    end
  end
end
