RSpec.describe Percy::Client::Environment do
  before(:each) do
    @original_env = ENV['TRAVIS_BUILD_ID']
    # Unset Percy vars.
    ENV['PERCY_COMMIT'] = nil
    ENV['PERCY_BRANCH'] = nil
    ENV['PERCY_PULL_REQUEST'] = nil
    ENV['PERCY_REPO_SLUG'] = nil

    # Unset Travis vars.
    ENV['TRAVIS_BUILD_ID'] = nil
    ENV['TRAVIS_COMMIT'] = nil
    ENV['TRAVIS_PULL_REQUEST'] = nil
    ENV['TRAVIS_REPO_SLUG'] = nil

    # Unset Jenkins vars.
    ENV['JENKINS_URL'] = nil
    ENV['ghprbPullId'] = nil
    ENV['ghprbTargetBranch'] = nil
  end
  after(:each) { ENV['TRAVIS_BUILD_ID'] = @original_env }

  context 'no known CI environment' do
    describe '#current_ci' do
      it 'is nil' do
        expect(Percy::Client::Environment.current_ci).to be_nil
      end
    end
    describe '#branch' do
      it 'reads from the current local repo' do
        expect(Percy::Client::Environment.branch).to_not be_empty
      end
      it 'can be overridden with PERCY_BRANCH' do
        ENV['PERCY_BRANCH'] = 'test-branch'
        expect(Percy::Client::Environment.branch).to eq('test-branch')
      end
    end
    describe '#commit_sha' do
      it 'reads from the current local repo' do
        expect(Percy::Client::Environment.commit_sha).to eq('HEAD')
      end
      it 'can be overridden with PERCY_COMMIT' do
        ENV['PERCY_COMMIT'] = 'test-commit'
        expect(Percy::Client::Environment.commit_sha).to eq('test-commit')
      end
    end
    describe '#pull_request_number' do
      it 'returns nil if no CI environment' do
        expect(Percy::Client::Environment.pull_request_number).to be_nil
      end
      it 'can be overridden with PERCY_PULL_REQUEST' do
        ENV['PERCY_PULL_REQUEST'] = '123'
        ENV['TRAVIS_BUILD_ID'] = '1234'
        ENV['TRAVIS_PULL_REQUEST'] = '256'
        expect(Percy::Client::Environment.pull_request_number).to eq('123')
      end
    end
    describe '#repo' do
      it 'returns the current local repo name' do
        expect(Percy::Client::Environment.repo).to eq('percy/percy-client')
      end
      it 'can be overridden with PERCY_REPO_SLUG' do
        ENV['PERCY_REPO_SLUG'] = 'percy/slug'
        expect(Percy::Client::Environment.repo).to eq('percy/slug')
      end
    end
  end
  context 'in Jenkins CI' do
    before(:each) do
      ENV['JENKINS_URL'] = 'http://localhost:8080/'
      ENV['ghprbPullId'] = '123'
      ENV['ghprbTargetBranch'] = 'jenkins-target-branch'
      ENV['ghprbActualCommit'] = 'jenkins-actual-commit'
    end

    describe '#current_ci' do
      it 'is :jenkins' do
        expect(Percy::Client::Environment.current_ci).to eq(:jenkins)
      end
    end
    describe '#branch' do
      it 'reads from the CI environment' do
        expect(Percy::Client::Environment.branch).to eq('jenkins-target-branch')
      end
    end
    describe '#commit_sha' do
      it 'reads from the CI environment' do
        expect(Percy::Client::Environment.commit_sha).to eq('jenkins-actual-commit')
      end
    end
    describe '#pull_request_number' do
      it 'reads from the CI environment' do
        expect(Percy::Client::Environment.pull_request_number).to eq('123')
      end
    end
    describe '#repo' do
      it 'returns the current local repo name' do
        expect(Percy::Client::Environment.repo).to eq('percy/percy-client')
      end
    end
  end
  context 'in Travis CI' do
    before(:each) do
      ENV['TRAVIS_BUILD_ID'] = '1234'
      ENV['TRAVIS_PULL_REQUEST'] = '256'
      ENV['TRAVIS_REPO_SLUG'] = 'travis/repo-slug'
    end

    describe '#repo' do
      it 'reads from the CI environment' do
        expect(Percy::Client::Environment.repo).to eq('travis/repo-slug')
      end
    end
    describe '#current_ci' do
      it 'is :travis' do
        expect(Percy::Client::Environment.current_ci).to eq(:travis)
      end
    end
    describe '#pull_request_number' do
      it 'reads from the CI environment' do
        expect(Percy::Client::Environment.pull_request_number).to eq('256')
      end
    end
    describe '#repo' do
      it 'reads from the CI environment' do
        expect(Percy::Client::Environment.repo).to eq('travis/repo-slug')
      end
    end
  end
  describe 'local git repo methods' do
    describe '#commit' do
      it 'returns current local commit data' do
        commit = Percy::Client::Environment.commit
        expect(commit[:author_email]).to match(/.+@.+\..+/)
        expect(commit[:author_name]).to_not be_empty
        expect(commit[:branch]).to_not be_empty
        expect(commit[:committed_at]).to_not be_empty
        expect(commit[:committer_email]).to_not be_empty
        expect(commit[:committer_name]).to_not be_empty
        expect(commit[:message]).to_not be_empty
        expect(commit[:sha]).to_not be_empty
        expect(commit[:sha].length).to eq(40)
      end
    end
  end
end
