module Percy
  class Client
    module LocalGit
      GIT_FORMAT_LINES = [
        'COMMIT_SHA:%H',
        'AUTHOR_DATE:%ai',
        'AUTHOR_NAME:%an',
        'AUTHOR_EMAIL:%ae',
        'COMMITTER_NAME:%an',
        'COMMITTER_EMAIL:%ae',
        'COMMITTER_DATE:%ai',
        # Note: order is important, this must come last because the regex is a multiline match.
        'COMMIT_MESSAGE:%B'
      ].freeze

      class Error < Exception; end
      class NoLocalRepo < Exception; end

      def current_local_commit
        commit = ENV['PERCY_COMMIT'] || 'HEAD'
        branch = ENV['PERCY_BRANCH'] || `git rev-parse --abbrev-ref HEAD`.strip
        if branch == ''
          raise Percy::Client::LocalGit::NoLocalRepo.new('No local git repository found.')
        end

        format = GIT_FORMAT_LINES.join('%n')  # "git show" format uses %n for newlines.
        output = `git show --quiet #{commit} --format="#{format}"`.strip
        data = {
          sha: output.match(/COMMIT_SHA:(.*)/)[1],
          branch: branch,
          committed_at: output.match(/AUTHOR_DATE:(.*)/)[1],
          author_name: output.match(/AUTHOR_NAME:(.*)/)[1],
          author_email: output.match(/AUTHOR_EMAIL:(.*)/)[1],
          committer_name: output.match(/COMMITTER_NAME:(.*)/)[1],
          committer_email: output.match(/COMMITTER_EMAIL:(.*)/)[1],
          message: output.match(/COMMIT_MESSAGE:(.*)/m)[1],
        }
      end

      def current_local_repo
        origin_url = `git config --get remote.origin.url`
        if origin_url == ''
          raise Percy::Client::LocalGit::NoLocalRepo.new('No local git repository found.')
        end
        match = origin_url.match(Regexp.new('[:/]([^/]+\/.+)\.git'))
        match[1]
      end
    end
  end
end
