class Ip < Sequel::Model
  plugin :dirty

  one_to_many :pings
  one_to_many :ip_enabled_histories

  dataset_module do
    def enabled
      where(enabled: true)
    end
  end

  def after_create
    save_history

    super
  end

  def after_update
    save_history if column_changed?(:enabled)

    super
  end

  private

  def save_history
    IpEnabledHistory.create(
      ip_id: self.id,
      enabled: self.enabled,
      changed_at: Time.now
    )
  end
end
