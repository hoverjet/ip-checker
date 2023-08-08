RSpec.describe PingService do
  describe '#call' do
    subject { described_class.call(ip_id: ip_id, timeout: timeout) }

    let(:ip_id) { ip.id }
    let(:timeout) { 1 }
    let(:ip_address) { '8.8.8.8' }
    let(:ip) { create(:ip, ip_address: ip_address) }

    context 'when ping is successful' do
      let(:ping_output) { "64 bytes from #{ip_address}: icmp_seq=1 ttl=52 time=23.4 ms\n0% packet loss" }
      before { allow(Open3).to receive(:capture2).and_return([ping_output, nil]) }

      it 'returns success' do
        expect(subject).to be_success
      end

      it 'saves the ping result' do
        expect { subject }.to change { Ping.count }.by(1)
        expect(subject).to be_success

        ping = Ping.order(:timestamp).last
        expect(ping).to have_attributes(
                          ip_id: ip.id,
                          rtt: 23.4,
                          packet_loss: false
                        )
      end
    end

    context 'when ping results in packet loss' do
      let(:ping_output) { "Request timeout for icmp_seq 0\n100% packet loss" }
      before { allow(Open3).to receive(:capture2).and_return([ping_output, nil]) }

      it 'returns success' do
        expect(subject).to be_success
      end

      it 'saves the ping result with nil rtt and packet_loss true' do
        expect { subject }.to change { Ping.count }.by(1)
        ping = Ping.order(:timestamp).last
        expect(ping).to have_attributes(
                          ip_id: ip.id,
                          rtt: nil,
                          packet_loss: true
                        )
      end
    end

    context 'when IP is not found' do
      before do
        ip.destroy
      end

      it 'returns failure' do
        expect(subject).to be_failure
      end

      it 'does not attempt to ping' do
        expect(Open3).not_to receive(:capture2)
        expect { subject }.not_to change { Ping.count }
      end

      it 'does not create a Ping record' do
        expect { subject }.not_to change { Ping.count }
      end
    end
  end
end
