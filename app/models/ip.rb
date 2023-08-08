class Ip < Sequel::Model
  plugin :dirty

  one_to_many :pings
  one_to_many :ip_enabled_histories

  dataset_module do
    def enabled
      where(enabled: true)
    end
  end

  def after_save
    if column_changed?(:enabled)
      IpEnabledHistory.create(
        ip_id: self.id,
        enabled: self.enabled,
        changed_at: Time.now
      )
    end

    super
  end
end
