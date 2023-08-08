FactoryBot.define do
  factory :ip_enabled_history do
    ip
    enabled { false }
    changed_at { Time.now }
  end
end