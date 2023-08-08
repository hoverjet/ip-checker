module V1
  module Entities
    class Ip < Grape::Entity
      expose :id
      expose :ip_address
      expose :enabled
    end
  end
end
