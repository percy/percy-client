module Percy
  class Client
    module Snapshots
      def create_snapshot(build_id, resources, options = {})
        if !resources.respond_to?(:each)
          raise ArgumentError.new(
            'resources argument must be an iterable of Percy::Client::Resource objects')
        end
        name = options[:name]
        data = {
          'data' => {
            'type' => 'snapshots',
            'attributes' => {
              'name' => name,
            },
            'relationships' => {
              'resources' => {
                'data' => resources.map { |r| r.serialize },
              },
            },
          },
        }
        post("#{config.api_url}/builds/#{build_id}/snapshots/", data)
      end

      def finalize_snapshot(snapshot_id)
        post("#{config.api_url}/snapshots/#{snapshot_id}/finalize", {})
      end
    end
  end
end
