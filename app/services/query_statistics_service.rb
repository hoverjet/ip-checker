class QueryStatisticsService < BaseService
  option :ip_id
  option :time_from
  option :time_to

  def call
    enabled_intervals = IpEnabledHistory
                              .select(:ip_id,
                                      Sequel.as(:changed_at, :start_interval),
                                      Sequel.as(Sequel.function(:LEAD, :changed_at).over(partition: :ip_id, order: :changed_at), :end_interval))
                              .where(ip_id: ip_id, enabled: true)
                              .where(Sequel.lit('changed_at >= ?', time_from))
                              .where(Sequel.lit('changed_at <= ?', time_to))
                              .as(:enabled_intervals)

    dataset = Ping.join_table(:inner, enabled_intervals, ip_id: :ip_id)
                  .where(Sequel.lit('pings.timestamp BETWEEN start_interval AND COALESCE(end_interval, ?)', time_to))
                  .where(Sequel[:pings][:ip_id] => ip_id)

    percentile_expr = Sequel.lit('PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rtt) AS median_rtt')
    results = dataset.select(
      Sequel.function(:AVG, :rtt).as(:avg_rtt),
      Sequel.function(:MIN, :rtt).as(:min_rtt),
      Sequel.function(:MAX, :rtt).as(:max_rtt),
      percentile_expr,
      Sequel.function(:STDDEV, :rtt).as(:stddev_rtt),
      (Sequel.function(:SUM, Sequel.case({{ packet_loss: true } => 1 }, 0)) * 100.0 / Sequel.function(:COUNT, Sequel.lit('*'))).as(:loss_percentage)
    ).first

    result = results.to_hash
    return Failure('No records found in statistics') if result.values.all?(&:nil?)

    Success(result)
  end
end
