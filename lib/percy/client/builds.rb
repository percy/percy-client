module Percy
  class Client
    module Builds
      def create_build(repo, options = {})
        pull_request_number = options[:pull_request_number] ||
          Percy::Client::Environment.pull_request_number
        commit_data = options[:commit_data] || Percy::Client::Environment.commit
        resources = options[:resources]

        data = {
          'data' => {
            'type' => 'builds',
            'attributes' => {
              'branch' => commit_data[:branch],
              'commit-sha' => commit_data[:sha],
              'commit-committed-at' => commit_data[:committed_at],
              'commit-author-name' => commit_data[:author_name],
              'commit-author-email' => commit_data[:author_email],
              'commit-committer-name' => commit_data[:committer_name],
              'commit-committer-email' => commit_data[:committer_email],
              'commit-message' => commit_data[:message],
              'pull-request-number' => pull_request_number,
            },
          }
        }

        if resources
          if !resources.respond_to?(:each)
            raise ArgumentError.new(
              'resources argument must be an iterable of Percy::Client::Resource objects')
          end
          relationships_data = {
            'relationships' => {
              'resources' => {
                'data' => resources.map { |r| r.serialize },
              },
            },
          }
          data['data'].merge!(relationships_data)
        end

        post("#{config.api_url}/repos/#{repo}/builds/", data)
      end

      def finalize_build(build_id)
        post("#{config.api_url}/builds/#{build_id}/finalize", {})
      end
    end
  end
end


