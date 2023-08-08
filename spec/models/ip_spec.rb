RSpec.describe Ip do
  describe 'hooks' do
    describe 'after_create' do
      subject { ip.save }

      let(:ip) { build(:ip, enabled: true) }

      it 'saves an enabled history record' do
        expect { subject }.to change { IpEnabledHistory.count }.by(1)
        expect(IpEnabledHistory.last.enabled).to eq(ip.enabled)
      end
    end

    describe 'after_update' do
      subject { ip.update(enabled: enabled_value) }

      let!(:ip) { create(:ip, enabled: true) }

      context 'when enabled is changed' do
        let(:enabled_value) { false }

        it 'saves an enabled history record' do
          expect { subject }.to change { IpEnabledHistory.count }.by(1)
          expect(IpEnabledHistory.last.enabled).to eq(enabled_value)
          expect(IpEnabledHistory.last.ip_id).to eq(ip.id)
        end
      end

      context 'when enabled is not changed' do
        let(:enabled_value) { ip.enabled }

        it 'does not save an enabled history record' do
          expect { subject }.not_to change { IpEnabledHistory.count }
        end
      end
    end
  end
end
