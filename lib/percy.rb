require 'percy/client'

module Percy
  class << self
    attr_accessor :access_token
  end

  def self.options
    {
      access_token: access_token,
    }
  end

  # API client based on configured options.
  #
  # @return [Percy::Client] API client.
  def self.client
    @client = Percy::Client.new(options) unless defined?(@client)
    @client
  end

  # @private
  def self.respond_to_missing?(method_name, include_private = false)
    client.respond_to?(method_name, include_private)
  end if RUBY_VERSION >= '1.9'

  # @private
  def self.respond_to?(method_name, include_private = false)
    client.respond_to?(method_name, include_private) || super
  end if RUBY_VERSION < '1.9'

  def self.method_missing(method_name, *args, &block)
    return super if !client.respond_to?(method_name)
    client.send(method_name, *args, &block)
  end
  private :method_missing
end
