module Percy
  class Client
    module Builds
      def create_build(repo_slug)
        commit = Percy.current_local_commit
        data = {
          'data' => {
            'type' => 'builds',
            'attributes' => {
              'commit-sha' => commit[:sha],
              'commit-branch' => commit[:branch],
              'commit-committed-at' => commit[:committed_at],
              'commit-author-name' => commit[:author_name],
              'commit-author-email' => commit[:author_email],
              'commit-committer-name' => commit[:committer_name],
              'commit-committer-email' => commit[:committer_email],
              'commit-message' => commit[:message],
              'pull-request-number' => nil,
            },
          }
        }
        post("#{full_base}/repos/#{repo_slug}/builds/", data)
      end

      def finalize_build(build_id)
        post("#{full_base}/builds/#{build_id}/finalize", {})
      end
    end
  end
end


