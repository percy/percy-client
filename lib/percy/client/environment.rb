module Percy
  class Client
    module Environment
      GIT_FORMAT_LINES = [
        'COMMIT_SHA:%H',
        'AUTHOR_NAME:%an',
        'AUTHOR_EMAIL:%ae',
        'COMMITTER_NAME:%an',
        'COMMITTER_EMAIL:%ae',
        'COMMITTED_DATE:%ai',
        # Note: order is important, this must come last because the regex is a multiline match.
        'COMMIT_MESSAGE:%B'
      ].freeze

      class Error < Exception; end
      class RepoNotFoundError < Exception; end
      class BranchNotFoundError < Exception; end

      def self.current_ci
        return :travis if ENV['TRAVIS_BUILD_ID']
        return :jenkins if ENV['JENKINS_URL'] && ENV['ghprbPullId']  # Pull Request Builder plugin.
        return :circle if ENV['CIRCLECI']
        return :codeship if ENV['CI_NAME'] && ENV['CI_NAME'] == 'codeship'
      end

      def self.commit_sha
        return ENV['PERCY_COMMIT'] if ENV['PERCY_COMMIT']

        case current_ci
        when :jenkins
          ENV['ghprbActualCommit']
        when :travis
          ENV['TRAVIS_COMMIT']
        when :circle
          ENV['CIRCLE_SHA1']
        when :codeship
          ENV['CI_COMMIT_ID']
        else
          'HEAD'
        end
      end

      def self.commit
        format = GIT_FORMAT_LINES.join('%n')  # "git show" format uses %n for newlines.
        output = `git show --quiet #{commit_sha} --format="#{format}"`.strip
        data = {
          sha: output.match(/COMMIT_SHA:(.*)/)[1],
          branch: branch,
          committed_at: output.match(/COMMITTED_DATE:(.*)/)[1],
          author_name: output.match(/AUTHOR_NAME:(.*)/)[1],
          author_email: output.match(/AUTHOR_EMAIL:(.*)/)[1],
          committer_name: output.match(/COMMITTER_NAME:(.*)/)[1],
          committer_email: output.match(/COMMITTER_EMAIL:(.*)/)[1],
          message: output.match(/COMMIT_MESSAGE:(.*)/m)[1],
        }
      end

      # The name of the target branch that the build will be compared against.
      def self.branch
        return ENV['PERCY_BRANCH'] if ENV['PERCY_BRANCH']

        result = case current_ci
        when :jenkins
          ENV['ghprbTargetBranch']
        when :travis
          ENV['TRAVIS_BRANCH']
        when :circle
          ENV['CIRCLE_BRANCH']
        when :codeship
          ENV['CI_BRANCH']
        else
          # Discover from current git repo branch name.
          `git rev-parse --abbrev-ref HEAD`.strip
        end
        if result == ''
          raise Percy::Client::Environment::BranchNotFoundError.new('No target branch found.')
        end
        result
      end

      def self.repo
        return ENV['PERCY_REPO_SLUG'] if ENV['PERCY_REPO_SLUG']

        case current_ci
        when :travis
          ENV['TRAVIS_REPO_SLUG']
        when :circle
          "#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}"
        else
          origin_url = `git config --get remote.origin.url`
          if origin_url == ''
            raise Percy::Client::Environment::RepoNotFoundError.new('No local git repository found.')
          end
          match = origin_url.match(Regexp.new('[:/]([^/]+\/[^/]+)\.git'))
          match[1]
        end
      end

      def self.pull_request_number
        return ENV['PERCY_PULL_REQUEST'] if ENV['PERCY_PULL_REQUEST']

        case current_ci
        when :jenkins
          # GitHub Pull Request Builder plugin.
          ENV['ghprbPullId']
        when :travis
          ENV['TRAVIS_PULL_REQUEST'] if ENV['TRAVIS_PULL_REQUEST'] != 'false'
        when :circle
          if ENV['CI_PULL_REQUESTS'] && ENV['CI_PULL_REQUESTS'] != ''
            ENV['CI_PULL_REQUESTS'].split('/')[-1]
          end
        when :codeship
          # Unfortunately, codeship always returns 'false' for CI_PULL_REQUEST. For now, return nil.
        end
      end
    end
  end
end
