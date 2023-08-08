require 'open3'

class PingService < BaseService
  include Dry::Monads::Do.for(:call)

  option :ip_id, type: proc(&:to_i)
  option :timeout, type: proc(&:to_i), default: -> { 1 }

  def call
    ip = yield find_ip
    rtt, packet_loss = yield ping_process(ip.ip_address)
    save_ping(ip_id, rtt, packet_loss)
  end

  private

  def find_ip
    ip = Ip[ip_id]
    ip ? Success(ip) : Failure("IP not found")
  end

  def ping_process(ip_address)
    command = "ping -c 1 -W #{timeout} #{ip_address}"
    output, _ = Open3.capture2(command)

    packet_loss = output.include?("100% packet loss")
    rtt = nil

    unless packet_loss
      rtt_match = output.match(/time=(\d+\.\d+)/)
      rtt = rtt_match ? rtt_match[1].to_f : nil
    end

    Success([rtt, packet_loss])
  end

  def save_ping(ip_id, rtt, packet_loss)
    ping = Ping.create(
      ip_id: ip_id,
      timestamp: Time.now,
      rtt: rtt,
      packet_loss: packet_loss
    )

    Success(ping)
  end
end
