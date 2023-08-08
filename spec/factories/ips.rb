FactoryBot.define do
  factory :ip do
    ip_address { IPAddr.new(rand(2**32), Socket::AF_INET).to_s } # Random IPv4 address
    enabled { true }
  end
end
