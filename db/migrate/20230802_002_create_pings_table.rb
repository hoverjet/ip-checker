Sequel.migration do
  change do
    create_table :pings do
      foreign_key :ip_id, :ips, null: false, on_delete: :cascade
      column :timestamp, :timestamptz, null: false
      numeric :rtt
      boolean     :packet_loss, null: false, default: false
    end
    run 'SELECT create_hypertable(\'pings\', \'timestamp\');'
    add_index :pings, [:ip_id, :timestamp]
  end
end
