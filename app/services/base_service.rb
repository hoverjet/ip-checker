require 'dry/initializer'
require 'dry/monads'

class BaseService
  extend Dry::Initializer
  include Dry::Monads[:result]

  class << self
    def call(**options)
      new(**options).call
    end
  end

  def call
    raise NotImplementedError, 'Please implement the perform method in the derived class'
  end
end
