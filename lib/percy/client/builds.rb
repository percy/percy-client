module Percy
  class Client
    module Builds
      def create_build(repo, options = {})
        pull_request_number = options[:pull_request_number] ||
          Percy::Client::Environment.pull_request_number
        commit_data = options[:commit_data] || Percy::Client::Environment.commit
        resources = options[:resources]
        parallel_nonce = options[:parallel_nonce] || Percy::Client::Environment.parallel_nonce
        parallel_total_shards = options[:parallel_total_shards] \
          || Percy::Client::Environment.parallel_total_shards

        # Only pass parallelism data if it all exists and there is more than 1 shard.
        in_parallel_environment = parallel_nonce && \
          parallel_total_shards && parallel_total_shards > 1
        if !in_parallel_environment
          parallel_nonce = nil
          parallel_total_shards = nil
        end

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
              'parallel-nonce' => parallel_nonce,
              'parallel-total-shards' => parallel_total_shards,
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

        build_data = post("#{config.api_url}/repos/#{repo}/builds/", data)
        Percy.logger.debug { "Build #{build_data['data']['id']} created" }
        parallelism_msg = if parallel_total_shards
          "#{parallel_total_shards} shards detected (nonce: #{parallel_nonce.inspect})"
        else
          'not detected'
        end
        Percy.logger.debug { "Parallel test environment: #{parallelism_msg}" }
        build_data
      end

      def finalize_build(build_id)
        post("#{config.api_url}/builds/#{build_id}/finalize", {})
      end
    end
  end
end


