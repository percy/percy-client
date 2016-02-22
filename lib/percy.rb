require 'logger'
require 'percy/client'

module Percy
  def self.config
    @config ||= Percy::Config.new
  end

  def self.reset
    @config = nil
    @client = nil
    @logger = nil
  end

  # API client based on configured options.
  #
  # @return [Percy::Client] API client.
  def self.client
    @client = Percy::Client.new(config: config) if !defined?(@client) || !@client
    @client
  end

  # @private
  def self.logger
    @logger if defined?(@logger)
    @logger ||= Logger.new(STDOUT)
    @logger.level = config.debug ? Logger::DEBUG : Logger::INFO
    @logger.formatter = proc do |severity, datetime, progname, msg|
       "[percy][#{severity}] #{msg}\n"
    end
    @logger
  end

  # @private
  def self.respond_to_missing?(method_name, include_private = false)
    client.respond_to?(method_name, include_private)
  end if RUBY_VERSION >= '1.9'

  # @private
  def self.respond_to?(method_name, include_private = false)
    client.respond_to?(method_name, include_private) || super
  end if RUBY_VERSION < '1.9'

  # @private
  def self.method_missing(method_name, *args, &block)
    return super if !client.respond_to?(method_name)
    client.send(method_name, *args, &block)
  end
  private :method_missing
end
