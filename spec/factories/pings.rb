FactoryBot.define do
  factory :ping do
    ip
    timestamp { Time.now }
    rtt { rand(100.0..200.0) }
    packet_loss { false }
  end

  trait :packet_loss do
    rtt { nil }
    packet_loss { true }
  end
end
