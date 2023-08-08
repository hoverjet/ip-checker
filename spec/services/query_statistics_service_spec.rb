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

  context 'when IP was enabled only in a specific period' do
    let(:enabled_start) { 5.days.ago }
    let(:enabled_end) { 1.day.ago }
    let(:time_from) { enabled_start.beginning_of_day }
    let(:time_to) { enabled_end.end_of_day }

    before do
      create(:ip_enabled_history, ip: ip, enabled: true, changed_at: enabled_start)
      create(:ip_enabled_history, ip: ip, enabled: false, changed_at: enabled_end)
      create(:ping, ip: ip, rtt: 100.0, timestamp: 2.days.ago)
    end

    it 'considers pings only from the enabled period' do
      result = subject.value!
      expect(result[:avg_rtt]).to eq(100.0)
    end
  end

  context 'when IP was enabled in two different periods' do
    let(:enabled_start1) { 7.days.ago }
    let(:enabled_end1) { 5.days.ago }
    let(:enabled_start2) { 3.days.ago }
    let(:enabled_end2) { 1.day.ago }
    let(:time_from) { 7.days.ago.beginning_of_day }
    let(:time_to) { 1.day.ago.end_of_day }

    before do
      create(:ip_enabled_history, ip: ip, enabled: true, changed_at: enabled_start1)
      create(:ip_enabled_history, ip: ip, enabled: false, changed_at: enabled_end1)
      create(:ip_enabled_history, ip: ip, enabled: true, changed_at: enabled_start2)
      create(:ip_enabled_history, ip: ip, enabled: false, changed_at: enabled_end2)
      create(:ping, ip: ip, rtt: 100.0, timestamp: 6.days.ago)
      create(:ping, ip: ip, rtt: 50.0, timestamp: 2.days.ago)
    end

    it 'considers pings from both enabled periods' do
      result = subject.value!
      expect(result[:avg_rtt]).to eq(75.0) # Average of two pings from different periods
    end
  end

  context 'when IP was enabled in two different periods, then was disabled, and now again enabled and has a ping' do
    let(:enabled_start1) { 7.days.ago }
    let(:enabled_end1) { 5.days.ago }
    let(:enabled_start2) { 3.days.ago }
    let(:enabled_end2) { 1.day.ago }
    let(:time_from) { 7.days.ago.beginning_of_day }
    let(:time_to) { Time.current }

    before do
      create(:ip_enabled_history, ip: ip, enabled: true, changed_at: enabled_start1)
      create(:ip_enabled_history, ip: ip, enabled: false, changed_at: enabled_end1)
      create(:ip_enabled_history, ip: ip, enabled: true, changed_at: enabled_start2)
      create(:ip_enabled_history, ip: ip, enabled: false, changed_at: enabled_end2)
      create(:ping, ip: ip, rtt: 100.0, timestamp: 6.days.ago)
      create(:ping, ip: ip, rtt: 50.0, timestamp: 2.days.ago)
      create(:ping, ip: ip, rtt: 30.0, timestamp: 6.hours.ago)
    end

    it 'considers pings from both enabled periods, including the recent one' do
      result = subject.value!
      expect(result[:avg_rtt]).to eq(60.0) # Average of three pings from different periods
    end
  end
end
