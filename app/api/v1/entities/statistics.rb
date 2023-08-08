module V1
  module Entities
    class Statistics < Grape::Entity
      format_with(:custom_number) do |number|
        number.nil? ? nil : number.to_f.round(3)
      end

      expose :avg_rtt, documentation: { desc: 'Average Round-Trip Time' }, format_with: :custom_number
      expose :min_rtt, documentation: { desc: 'Minimum Round-Trip Time' }, format_with: :custom_number
      expose :max_rtt, documentation: { desc: 'Maximum Round-Trip Time' }, format_with: :custom_number
      expose :median_rtt, documentation: {  desc: 'Median Round-Trip Time' }, format_with: :custom_number
      expose :stddev_rtt, documentation: { desc: 'Standard Deviation of Round-Trip Time' }, format_with: :custom_number
      expose :loss_percentage, documentation: { desc: 'Packet Loss Percentage' }, format_with: :custom_number
    end
  end
end
