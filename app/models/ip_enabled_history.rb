class IpEnabledHistory < Sequel::Model
  many_to_one :ip
end