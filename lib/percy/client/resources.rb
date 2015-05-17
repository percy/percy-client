require 'base64'
require 'digest'

module Percy
  class Client

    # A simple data container object used to pass data to create_snapshot.
    class Resource
      attr_accessor :sha
      attr_accessor :resource_url
      attr_accessor :is_root
      attr_accessor :mimetype

      def initialize(sha, resource_url, options = {})
        @sha = sha
        @resource_url = resource_url
        @is_root = options[:is_root]
        @mimetype = options[:mimetype]
      end

      def serialize
        {
          'type' => 'resources',
          'id' => sha,
          'resource-url' => resource_url,
          'mimetype' => mimetype,
          'is-root' => is_root,
        }
      end
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
          post("#{full_base}/builds/#{build_id}/resources/", data)
        rescue Percy::Client::ClientError => e
          raise e if e.env.status != 409
          STDERR.puts "[percy] Warning: unnecessary resource reuploaded with SHA-256: #{sha}"
        end
        true
      end
    end
  end
end
