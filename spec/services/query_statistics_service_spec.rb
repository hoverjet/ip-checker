RSpec.describe QueryStatisticsService do
  let(:ip) { create(:ip) }
  let(:time_from) { 1.day.ago }
  let(:time_to) { Time.now }

  subject { described_class.call(ip_id: ip.id, time_from: time_from, time_to: time_to) }

  context 'when there are pings without packet loss' do
    before do
      create(:ping, ip: ip, rtt: 100.0)
      create(:ping, ip: ip, rtt: 150.0)
      create(:ping, ip: ip, rtt: 200.0)
    end

    it 'calculates the correct statistics' do
      result = subject.value!.each_with_object({}) { |(k, v), h| h[k] = v.to_f }
      expect(result).to eq({
                             avg_rtt: 150.0,
                             min_rtt: 100.0,
                             max_rtt: 200.0,
                             median_rtt: 150.0,
                             stddev_rtt: 50.0,
                             loss_percentage: 0.0
                           })
    end
  end

  context 'when there are pings with some packet loss' do
    before do
      create(:ping, ip: ip, rtt: 100.0)
      create(:ping, ip: ip, rtt: 150.0)
      create(:ping, :packet_loss, ip: ip) # Assuming :packet_loss trait represents a lost packet
    end

    it 'calculates the correct statistics' do
      result = subject.value!.each_with_object({}) { |(k, v), h| h[k] = v.to_f.round(2) }
      expect(result).to eq({
                             avg_rtt: 125.0,
                             min_rtt: 100.0,
                             max_rtt: 150.0,
                             median_rtt: 125.0,
                             stddev_rtt: 35.36,
                             loss_percentage: 33.33
                           })
    end
  end

  context 'when all pings have packet loss' do
    before do
      create_list(:ping, 3, :packet_loss, ip: ip)
    end

    it 'calculates the correct statistics' do
      result = subject.value!
      expect(result).to eq({
                             avg_rtt: nil,
                             min_rtt: nil,
                             max_rtt: nil,
                             median_rtt: nil,
                             stddev_rtt: nil,
                             loss_percentage: 100.0
                           })
    end
  end

  context 'when there are no pings' do
    it 'returns an error' do
      expect(subject).to be_a_failure
      expect(subject.failure).to eq('No records found in statistics')
    end
  end
end
