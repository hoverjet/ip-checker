class QueryStatisticsService < BaseService
  option :ip_id
  option :time_from
  option :time_to

  def call
    percentile_expr = Sequel.lit('PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rtt) AS median_rtt')
    dataset = Ping.where(ip_id: ip_id)
                  .where(Sequel.lit('timestamp >= ?', time_from))
                  .where(Sequel.lit('timestamp <= ?', time_to))
    results = dataset.select(
      Sequel.function(:AVG, :rtt).as(:avg_rtt),
      Sequel.function(:MIN, :rtt).as(:min_rtt),
      Sequel.function(:MAX, :rtt).as(:max_rtt),
      percentile_expr,
      Sequel.function(:STDDEV, :rtt).as(:stddev_rtt),
      (Sequel.function(:SUM, Sequel.case({{ packet_loss: true } => 1 }, 0)) * 100.0 / Sequel.function(:COUNT, Sequel.lit('*'))).as(:loss_percentage)
    ).first

    result = results.to_hash
    # NOTE: for empty result all values will be nil
    return Failure('No records found in statistics') if result.values.all?(&:nil?)

    Success(result)
  end
end
