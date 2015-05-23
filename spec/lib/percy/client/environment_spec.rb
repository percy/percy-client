RSpec.describe Percy::Client::Environment do
  before(:each) do
    @original_env = ENV['TRAVIS_BUILD_ID']
    # Unset Percy vars.
    ENV['PERCY_PULL_REQUEST'] = nil

    # Unset Travis vars.
    ENV['TRAVIS_BUILD_ID'] = nil

    # Unset Jenkins vars.
    ENV['JENKINS_URL'] = nil
    ENV['ghprbPullId'] = nil
  end
  after(:each) { ENV['TRAVIS_BUILD_ID'] = @original_env }

  context 'no known CI environment' do
    describe '#current_ci' do
      it 'is nil' do
        expect(Percy::Client::Environment.current_ci).to be_nil
      end
    end
    describe '#pull_request_number' do
      it 'returns nil if no CI environment' do
        expect(Percy::Client::Environment.pull_request_number).to be_nil
      end
      it 'preferences the PERCY_PULL_REQUEST environment variable over all others' do
        ENV['PERCY_PULL_REQUEST'] = '123'
        ENV['TRAVIS_BUILD_ID'] = '1234'
        ENV['TRAVIS_PULL_REQUEST'] = '256'
        expect(Percy::Client::Environment.pull_request_number).to eq('123')
      end
    end
  end
  context 'in Jenkins CI' do
    before(:each) do
      ENV['JENKINS_URL'] = 'http://localhost:8080/'
      ENV['ghprbPullId'] = '123'
    end

    describe '#current_ci' do
      it 'is :jenkins' do
        expect(Percy::Client::Environment.current_ci).to eq(:jenkins)
      end
    end
    describe '#pull_request_number' do
      it 'reads from the environment' do
        expect(Percy::Client::Environment.pull_request_number).to eq('123')
      end
    end
  end
  context 'in Travis CI' do
    before(:each) do
      ENV['TRAVIS_BUILD_ID'] = '1234'
      ENV['TRAVIS_PULL_REQUEST'] = '256'
    end

    describe '#current_ci' do
      it 'is :travis' do
        expect(Percy::Client::Environment.current_ci).to eq(:travis)
      end
    end
    describe '#pull_request_number' do
      it 'reads from the environment' do
        expect(Percy::Client::Environment.pull_request_number).to eq('256')
      end
    end
  end
  describe 'local git repo methods' do
    describe '#repo' do
      it 'returns the current local repo name' do
        expect(Percy::Client::Environment.repo).to eq('percy/percy-client')
      end
    end
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
