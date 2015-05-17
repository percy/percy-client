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
    end
  end
end
