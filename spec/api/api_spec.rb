describe Api, type: :request do
  include Rack::Test::Methods

  def app
    Api
  end

  subject(:response) { JSON.parse(last_response.body) }

  let(:ip_address) { '192.168.1.1' }
  let(:ip) { create(:ip, ip_address: ip_address) }

  context 'POST /ips' do
    it 'creates a new IP and returns it' do
      post 'api/ips', { ip: ip_address, enabled: true }
      expect(last_response.status).to eq(201)
      expect(response).to include('ip_address' => ip_address, 'enabled' => true, 'id' => Ip.order(:id).last.id)
    end
  end

  context 'POST /ips/:id/enable' do
    it 'enables an IP and returns it' do
      post "api/ips/#{ip.id}/enable"
      expect(last_response.status).to eq(201)
      expect(response).to include('ip_address' => ip_address, 'enabled' => true, 'id' => ip.id)
    end
  end

  context 'POST /ips/:id/disable' do
    it 'disables an IP and returns it' do
      post "api/ips/#{ip.id}/disable"
      expect(last_response.status).to eq(201)
      expect(response).to include('ip_address' => ip_address, 'enabled' => false, 'id' => ip.id)
    end
  end

  context 'GET /ips/:id/stats' do
    let(:ip) { create(:ip, ip_address: '192.168.1.1') }

    before do
      stats = {
        avg_rtt: 10.123,
        min_rtt: 5.123,
        max_rtt: 20.123,
        median_rtt: 15.123,
        stddev_rtt: 3.123,
        loss_percentage: 20.0
      }
      result = Dry::Monads::Result::Success.new(stats)
      allow(QueryStatisticsService).to receive(:call).and_return(result)
    end

    it 'gets statistics for an IP' do
      get "api/ips/#{ip.id}/stats", time_from: '2021-01-01', time_to: '2021-01-02'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include(
                                                  'avg_rtt' => 10.123,
                                                  'min_rtt' => 5.123,
                                                  'max_rtt' => 20.123,
                                                  'median_rtt' => 15.123,
                                                  'stddev_rtt' => 3.123,
                                                  'loss_percentage' => 20.0
                                                )
    end
  end

  context 'DELETE /ips/:id' do
    it 'deletes an IP' do
      delete "api/ips/#{ip.id}"
      expect(last_response.status).to eq(200)
      expect(response).to include('message' => 'IP deleted successfully.')
    end
  end
end
