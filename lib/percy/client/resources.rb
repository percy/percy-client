require 'base64'
require 'digest'
require 'uri'

module Percy
  class Client

    # A simple data container object used to pass data to create_snapshot.
    class Resource
      attr_accessor :sha
      attr_accessor :resource_url
      attr_accessor :is_root
      attr_accessor :mimetype
      attr_accessor :content
      attr_accessor :path

      def initialize(resource_url, options = {})
        @resource_url = resource_url

        if !options[:sha] && !options[:content]
          raise ArgumentError, 'Either "sha" or "content" must be given.'
        end
        @sha = options[:sha] || Digest::SHA256.hexdigest(options[:content])
        @content = options[:content]

        @is_root = options[:is_root]
        @mimetype = options[:mimetype]

        # For optional convenience of temporarily storing the local content and path with this
        # object. These are never included when serialized.
        @content = options[:content]
        @path = options[:path]
      end

      def serialize
        {
          'type' => 'resources',
          'id' => sha,
          'attributes' => {
            'resource-url' => URI.escape(resource_url),
            'mimetype' => mimetype,
            'is-root' => is_root,
          },
        }
      end

      def inspect
        content_msg = content.nil? ? '' : "content.length: #{content.length}"
        "<Resource #{sha} #{resource_url} is_root:#{!!is_root} #{mimetype} #{content_msg}>"
      end
      alias_method :to_s, :inspect
    end

    module Resources
      def upload_resource(build_id, content)
        sha = Digest::SHA256.hexdigest(content)
        data = {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'id' => sha,
              'base64-content' => Base64.strict_encode64(content),
            },
          },
        }
        begin
          post("#{config.api_url}/builds/#{build_id}/resources/", data)
        rescue Percy::Client::ConflictError => e
          raise e if e.status != 409
          STDERR.puts "[percy] Warning: unnecessary resource reuploaded with SHA-256: #{sha}"
        end
        true
      end
    end
  end
end
