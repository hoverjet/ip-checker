class Ip < Sequel::Model
  one_to_many :pings

  dataset_module do
    def enabled
      where(enabled: true)
    end
  end
end
