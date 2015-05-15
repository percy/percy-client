RSpec.describe Percy::Client do
  describe '#base_url' do
    it 'returns the base API URL' do
      expect(Percy.client.base_url).to eq('http://localhost:3000')
    end
  end
  describe '#base_path' do
    it 'returns the base API URL path' do
      expect(Percy.client.base_path).to eq('/api/v1')
    end
  end
  describe '#full_base' do
    it 'returns the full base API URL path' do
      expect(Percy.client.full_base).to eq('http://localhost:3000/api/v1')
    end
  end
end