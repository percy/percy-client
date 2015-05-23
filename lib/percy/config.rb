module Percy
  class Config
    # @!attribute [w] access_token
    #   @return [String] Percy repo access token.
    # @!attribute api_url
    #   @return [String] Base URL for API requests. Default: https://percy.io/api/v1/

    attr_accessor :access_token
    attr_accessor :api_url
    attr_accessor :repo

    # List of configurable keys for {Percy::Client}
    # @return [Array] Option keys.
    def keys
      @keys ||= [
        :access_token,
        :api_url,
        :repo,
      ]
    end

    def access_token
      @access_token ||= ENV['PERCY_TOKEN']
    end

    def api_url
      @api_url ||= ENV['PERCY_API'] || 'https://percy.io/api/v1'
    end

    def repo
      @repo ||= ENV['PERCY_REPO'] || Percy::Client::Environment.repo
    end
  end
end