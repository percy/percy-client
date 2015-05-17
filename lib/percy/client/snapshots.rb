module Percy
  class Client
    module Snapshots
      def create_snapshot(build_id, resources, options = {})
        raise ArgumentError if !resources.responds_to?(:each)

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
        post("#{full_base}/builds/#{build_id}/snapshots/", data)
      end
    end
  end
end
