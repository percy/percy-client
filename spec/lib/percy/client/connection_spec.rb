RSpec.describe Percy::Client::Connection do
  describe '#get' do
    it 'performs a GET request to the base_url and parses response' do
      stub_request(:get, build_url('/test')).to_return(body: {foo: true}.to_json)
      data = Percy.client.get('/test')
      expect(data).to eq({'foo' => true})
    end
  end
  describe '#post' do
    it 'performs a POST request to the base_url and parses response' do
      stub_request(:post, build_url('/test')).to_return(body: {foo: true}.to_json)
      data = Percy.client.post('/test', {})
      expect(data).to eq({'foo' => true})
    end
  end
end
