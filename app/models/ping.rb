class Ping < Sequel::Model
  many_to_one :ip

  # def self.query_statistics(ip_id:, time_from:, time_to:)
  #   percentile_expr = Sequel.lit('PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rtt) AS median_rtt')
  #   dataset = where(ip_id: ip_id)
  #               .where{timestamp >= time_from}
  #               .where{timestamp <= time_to}
  #   results = dataset.select(
  #     Sequel.function(:AVG, :rtt).as(:avg_rtt),
  #     Sequel.function(:MIN, :rtt).as(:min_rtt),
  #     Sequel.function(:MAX, :rtt).as(:max_rtt),
  #     percentile_expr,
  #     Sequel.function(:STDDEV, :rtt).as(:stddev_rtt),
  #     (Sequel.function(:SUM, Sequel.case({{packet_loss: true} => 1}, 0)) * 100.0 / Sequel.function(:COUNT, Sequel.lit('*'))).as(:loss_percentage)
  #   ).first
  #
  #   results.to_hash
  # end
end

