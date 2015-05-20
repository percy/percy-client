RSpec.describe Percy::Client::LocalGit do
  describe '#repo' do
    it 'returns the current local repo name' do
      expect(Percy::Client::LocalGit.repo).to eq('percy/percy-client')
    end
  end
  describe '#commit' do
    it 'returns current local commit data' do
      commit = Percy::Client::LocalGit.commit
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
