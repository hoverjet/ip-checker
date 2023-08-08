class PingWorker
  include Sidekiq::Worker

  def perform(ip_id)
    PingService.call(ip_id: ip_id)
  end
end