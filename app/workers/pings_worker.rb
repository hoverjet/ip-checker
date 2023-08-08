class PingsWorker
  include Sidekiq::Worker

  def perform
    Ip.enabled.each do |ip|
      puts "ip #{ip.ip_address}"
      PingWorker.perform_async(ip.id)
    end
  end
end