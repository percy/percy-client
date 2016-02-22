module Percy
  class Config
    # @!attribute [w] access_token
    #   @return [String] Percy repo access token.
    # @!attribute api_url
    #   @return [String] Base URL for API requests. Default: https://percy.io/api/v1/
    # @!attribute debug
    #   @return [Boolean] Whether or not to enable debug logging.
    # @!attribute repo
    #   @return [String] Git repo name.
    # @!attribute default_widths
    #   @return [Array] List of default widths for snapshot rendering unless overridden.

    attr_accessor :access_token
    attr_accessor :api_url
    attr_accessor :debug
    attr_accessor :repo
    attr_accessor :default_widths

    # List of configurable keys for {Percy::Client}
    # @return [Array] Option keys.
    def keys
      @keys ||= [
        :access_token,
        :api_url,
        :debug,
        :repo,
        :default_widths,
      ]
    end

    def access_token
      @access_token ||= ENV['PERCY_TOKEN']
    end

    def api_url
      @api_url ||= ENV['PERCY_API'] || 'https://percy.io/api/v1'
    end

    def debug
      @debug ||= ENV['PERCY_DEBUG'] == '1'
    end

    def repo
      @repo ||= Percy::Client::Environment.repo
    end

    # List of default widths sent for every snapshot, unless overridden on a per-snapshot basis.
    def default_widths
      @default_widths ||= []
    end
  end
end