module Percy
  class Client
    module Snapshots
      def create_snapshot(build_id, resources, options = {})
        raise ArgumentError.new('resources must be an iterable') if !resources.respond_to?(:each)
        name = options[:name]
        data = {
          'data' => {
            'type' => 'snapshots',
            'attributes' => {
              'name' => name,
            },
            'links' => {
              'resources' => resources.map { |r| r.serialize },
            },
          },
        }
        post("#{config.api_url}/builds/#{build_id}/snapshots/", data)
      end
    end
  end
end
