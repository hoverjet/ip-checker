class PingWorker
  include Sidekiq::Worker

  def perform(ip_id)
    p "PingWorker== #{ip_id}"
    result = PingService.call(ip_id: ip_id)
    puts result
  end
end