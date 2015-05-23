module Percy
  class Client
    module Builds
      def create_build(repo, options = {})
        pull_request_number = options[:pull_request_number] ||
          Percy::Client::Environment.pull_request_number
        commit_data = options[:commit_data] || Percy::Client::Environment.commit
        data = {
          'data' => {
            'type' => 'builds',
            'attributes' => {
              'commit-sha' => commit_data[:sha],
              'commit-branch' => commit_data[:branch],
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
        post("#{config.api_url}/repos/#{repo}/builds/", data)
      end

      def finalize_build(build_id)
        post("#{config.api_url}/builds/#{build_id}/finalize", {})
      end
    end
  end
end


