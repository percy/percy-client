RSpec.describe Percy::Client::LocalGit do
  describe '#current_local_repo' do
    it 'returns the current local repo name' do
      expect(Percy.current_local_repo).to eq('percy-io/percy-client')
    end
  end
  describe '#current_local_commit' do
    it 'returns current local commit data' do
      commit = Percy.current_local_commit
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
